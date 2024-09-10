resource "aws_vpc" "this" {
  cidr_block       = "10.110.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "upgrad-terraform-vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.110.1.0/24"

  tags = {
    Name = "upgrad-public-subnet-1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.110.2.0/24"

  tags = {
    Name = "upgrad-public-subnet-2"
  }
}
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.110.3.0/24"

  tags = {
    Name = "upgrad-private-subnet-1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.110.4.0/24"

  tags = {
    Name = "upgrad-private-subnet-2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "upgrad-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "public-rt"
  }
}
