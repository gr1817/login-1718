#vpc
resource "aws_vpc" "login-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "login-vpc"
  }
}

#Subnet for frontend
resource "aws_subnet" "login-fe-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-frontend-subnet"
  }
}

#Subnet for backendend
resource "aws_subnet" "login-be-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-backend-subnet"
  }
}

#Subnet for database
resource "aws_subnet" "login-db-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "login-database-subnet"
  }
}

# Inetrnet Gateway
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "login-internet-gateway"
  }
}

# public route table 
resource "aws_route_table" "login-public-rt" {
  vpc_id = aws_vpc.login-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.login-igw.id
  }

  tags = {
    Name = "login-public-route"
  }
}

#public association for frontend
resource "aws_route_table_association" "login-public-asc-1" {
  subnet_id      = aws_subnet.login-fe-subnet.id
  route_table_id = aws_route_table.login-public-rt.id
}

#public association for backend
resource "aws_route_table_association" "login-public-asc-2" {
  subnet_id      = aws_subnet.login-be-subnet.id
  route_table_id = aws_route_table.login-public-rt.id
}

# private route table 
resource "aws_route_table" "login-private-rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "login-private-route"
  }
}