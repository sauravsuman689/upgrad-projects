# Create a VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "three-tier-app"
  }
}

# Create 1st Public subnet
resource "aws_subnet" "nginx_public_subnet1" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-app-pub-sub1"
  }
}

# Create 2nd Public subnet
resource "aws_subnet" "nginx_public_subnet2" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-app-pub-sub2"
  }
}

# Create 1st Private subnet
resource "aws_subnet" "nginx_private_subnet1" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-app-priv-sub1"
  }
}

# Create 2nd private subnet
resource "aws_subnet" "nginx_private_subnet2" {
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-app-priv-sub2"
  }
}

# Create a security group 
resource "aws_security_group" "nginx_private_sg" {
  vpc_id = aws_vpc.nginx_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-app"
  }
}

# Create an ubuntu instance and install nginx
resource "aws_instance" "nginx_app" {
  subnet_id     = aws_subnet.nginx_private_subnet1.id
  security_groups = [aws_security_group.nginx_private_sg.id]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y nginx
                sudo systemctl start nginx
                sudo systemctl enable nginx
                EOF

  tags = {
    Name = "three-tier-app"
  }
}

# Create the Security Group for Load balance
resource "aws_security_group" "nginx_lb_sg" {
  vpc_id = aws_vpc.nginx_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-app"
  }
}

# Create Load Balancer
resource "aws_lb" "nginx_app_lb" {
  name               = "nginx-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_lb_sg.id]
  subnets            = [aws_subnet.nginx_public_subnet1.id, aws_subnet.nginx_public_subnet2.id]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  idle_timeout = 60
  enable_http2 = true
}

# Create Load Balancer target group
resource "aws_lb_target_group" "nginx_app_tg" {
  name     = "nginx-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.nginx_vpc.id
}

# Create load Balancer listner
resource "aws_lb_listener" "nginx_http" {
  load_balancer_arn = aws_lb.nginx_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx_app_tg.arn
  }
}

# Create the load Balancer group attachment
resource "aws_lb_target_group_attachment" "nginx_app_tg_attachment" {
  target_group_arn = aws_lb_target_group.nginx_app_tg.arn
  target_id        = aws_instance.nginx_app.id
  port             = 80
}

# Create Internet Gateway
resource "aws_internet_gateway" "nginx_igw" { 
   vpc_id = aws_vpc.nginx_vpc.id
   
  tags = { 
   Name = "three-tier-app" 
 }
}

# Create 1st Elastic IP
resource "aws_eip" "nginx_nat_eip1" {
  instance = null
}

# Create 2nd Elastic IP
resource "aws_eip" "nginx_nat_eip2" {
  instance = null
}

# Create 1st NAT Gateway
resource "aws_nat_gateway" "nginx_nat_gateway1" {
  allocation_id = aws_eip.nginx_nat_eip1.id
  subnet_id = aws_subnet.nginx_public_subnet1.id
}

# Create 2nd NAT Gateway
resource "aws_nat_gateway" "nginx_nat_gateway2" {
  allocation_id = aws_eip.nginx_nat_eip2.id
  subnet_id = aws_subnet.nginx_public_subnet2.id
}

# Create 1st Public route table
resource "aws_route_table" "nginx_public_route_table1" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_igw.id
  } 
}

#Create 2nd Public route table
resource "aws_route_table" "nginx_public_route_table2" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_igw.id
  }
}

# Create 1st Private route table
resource "aws_route_table" "nginx_private_route_table1" {
  vpc_id = aws_vpc.nginx_vpc.id
}

# Create 2nd Private route table
  resource "aws_route_table" "nginx_private_route_table2" {
  vpc_id = aws_vpc.nginx_vpc.id
}

# Create 1st Route to private route table1
resource "aws_route" "nginx_private_route_nat1" {
  route_table_id = aws_route_table.nginx_private_route_table1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nginx_nat_gateway1.id
}

# Create 2nd Route to private route table2
resource "aws_route" "nginx_private_route_nat2" {
  route_table_id = aws_route_table.nginx_private_route_table2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nginx_nat_gateway2.id
}

# Create 1st Aws route table association for public subnet1
resource "aws_route_table_association" "nginx_public_subnet_association1" {
  subnet_id = aws_subnet.nginx_public_subnet1.id
  route_table_id = aws_route_table.nginx_public_route_table1.id
}

# Create 2nd Aws route table association for public subnet2
resource "aws_route_table_association" "nginx_public_subnet_association2" {
  subnet_id = aws_subnet.nginx_public_subnet2.id
  route_table_id = aws_route_table.nginx_public_route_table2.id
}

# Create 3rd Aws route table association for private subnet1
resource "aws_route_table_association" "nginx_private_subnet_association1" {
  subnet_id = aws_subnet.nginx_private_subnet1.id
  route_table_id = aws_route_table.nginx_private_route_table1.id
}

# Create 4th Aws route table association for private subnet2
resource "aws_route_table_association" "nginx_private_subnet_association2" {
  subnet_id = aws_subnet.nginx_private_subnet2.id
  route_table_id = aws_route_table.nginx_private_route_table2.id
}

