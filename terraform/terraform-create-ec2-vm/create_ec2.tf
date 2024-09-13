resource "aws_vpc" "awsplatform_vpc" {
  cidr_block = "172.32.0.0/16"

  tags = {
    Name = "awsplatform-env"
  }
}

resource "aws_subnet" "awsplatform_subnet" {
  vpc_id            = aws_vpc.awsplatform_vpc.id
  cidr_block        = "172.32.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "awsplatform-env"
  }
}

resource "aws_internet_gateway" "awsplatform_igw" {
  vpc_id = aws_vpc.awsplatform_vpc.id

  tags = {
    Name = "awsplatform-env"
  }
}

resource "aws_route_table" "awsplatform_rt" {
  vpc_id = aws_vpc.awsplatform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.awsplatform_igw.id
  }

  tags = {
    Name = "awsplatform-env"
  }
}

resource "aws_route_table_association" "awsplatform_rta" {
  subnet_id      = aws_subnet.awsplatform_subnet.id
  route_table_id = aws_route_table.awsplatform_rt.id

}

resource "aws_security_group" "awsplatform_sg" {
  name        = "awsplatform-security-group"
  description = "Security group with SSH access"
  vpc_id      = aws_vpc.awsplatform_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update this to restrict access to known IP addresses
  }
  
  ingress {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "awsplatform-env"
  }
}

resource "aws_instance" "awsplatform_ec2" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.awsplatform_subnet.id
  vpc_security_group_ids = [aws_security_group.awsplatform_sg.id]
  
  root_block_device {
   volume_size = 20  # Size in GiB
   volume_type = "gp3"  # General Purpose SSD, adjust as needed
   delete_on_termination = true  # Optional: Automatically delete the volume when the instance is terminated
  }

  key_name = "aws_upgrad_labkey"
  tags = {
    Name = "awsplatform-env"
  }
}
