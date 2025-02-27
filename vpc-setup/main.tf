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

#public association frontend
resource "aws_route_table_association" "login-public-asc-1" {
  subnet_id      = aws_subnet.login-fe-subnet.id
  route_table_id = aws_route_table.login-public-rt.id
}

#public association backend
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

#private association database
resource "aws_route_table_association" "login-private-asc" {
  subnet_id      = aws_subnet.login-db-subnet.id
  route_table_id = aws_route_table.login-private-rt.id
}

#Nacl  
resource "aws_network_acl" "login-nacl" {
  vpc_id = aws_vpc.login-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/00"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/00"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "login-nacl"
  }
}

# Security group frontend
resource "aws_security_group" "login-fe-sg" {
  name        = "login-fe-sg"
  description = "Allow frontend traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "login-frontend-securitygroup"
  }
}

#ssh rule
resource "aws_vpc_security_group_ingress_rule" "login-fe-shh" {
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http rule
resource "aws_vpc_security_group_ingress_rule" "login-fe-http" {
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#egress / outbound rule
resource "aws_vpc_security_group_egress_rule" "login-fe-outbound" {
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Security group backendend
resource "aws_security_group" "login-be-sg" {
  name        = "login-be-sg"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "login-backend-securitygroup"
  }
}

#ssh rule
resource "aws_vpc_security_group_ingress_rule" "login-be-shh" {
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http rule
resource "aws_vpc_security_group_ingress_rule" "login-be-http" {
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#egress / outbound rule
resource "aws_vpc_security_group_egress_rule" "login-be-outbound" {
  security_group_id = aws_security_group.login-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}