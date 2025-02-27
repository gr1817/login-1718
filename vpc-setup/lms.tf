#vpc
resource "aws_vpc" "lms-vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "lms-vpc"
  }
}

#Subnet for frontend
resource "aws_subnet" "lms-fe-subnet" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-frontend-subnet"
  }
}

#Subnet for backendend
resource "aws_subnet" "lms-be-subnet" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-backend-subnet"
  }
}

#Subnet for database
resource "aws_subnet" "lms-db-subnet" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "lms-database-subnet"
  }
}

# Inetrnet Gateway
resource "aws_internet_gateway" "lms-igw" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-internet-gateway"
  }
}

# public route table 
resource "aws_route_table" "lms-public-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms-igw.id
  }

  tags = {
    Name = "lms-public-route"
  }
}

#public association frontend
resource "aws_route_table_association" "lms-public-asc-1" {
  subnet_id      = aws_subnet.lms-fe-subnet.id
  route_table_id = aws_route_table.lms-public-rt.id
}

#public association backend
resource "aws_route_table_association" "lms-public-asc-2" {
  subnet_id      = aws_subnet.lms-be-subnet.id
  route_table_id = aws_route_table.lms-public-rt.id
}

# private route table 
resource "aws_route_table" "lms-private-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-private-route"
  }
}

#private association database
resource "aws_route_table_association" "lms-private-asc" {
  subnet_id      = aws_subnet.lms-db-subnet.id
  route_table_id = aws_route_table.lms-private-rt.id
}

#Nacl  
resource "aws_network_acl" "lms-nacl" {
  vpc_id = aws_vpc.lms-vpc.id

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
    Name = "lms-nacl"
  }
}

# Security group frontend
resource "aws_security_group" "lms-fe-sg" {
  name        = "lms-fe-sg"
  description = "Allow frontend traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-frontend-securitygroup"
  }
}

#ssh rule
resource "aws_vpc_security_group_ingress_rule" "lms-fe-shh" {
  security_group_id = aws_security_group.lms-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http rule
resource "aws_vpc_security_group_ingress_rule" "lms-fe-http" {
  security_group_id = aws_security_group.lms-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#egress / outbound rule
resource "aws_vpc_security_group_egress_rule" "lms-fe-outbound" {
  security_group_id = aws_security_group.lms-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Security group backendend
resource "aws_security_group" "lms-be-sg" {
  name        = "lms-be-sg"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-backend-securitygroup"
  }
}

#ssh rule
resource "aws_vpc_security_group_ingress_rule" "lms-be-shh" {
  security_group_id = aws_security_group.lms-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http rule
resource "aws_vpc_security_group_ingress_rule" "lms-be-http" {
  security_group_id = aws_security_group.lms-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

#egress / outbound rule
resource "aws_vpc_security_group_egress_rule" "lms-be-outbound" {
  security_group_id = aws_security_group.lms-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Security group database
resource "aws_security_group" "lms-db-sg" {
  name        = "lms-db-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-database-securitygroup"
  }
}

#ssh rule
resource "aws_vpc_security_group_ingress_rule" "lms-db-shh" {
  security_group_id = aws_security_group.lms-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http rule
resource "aws_vpc_security_group_ingress_rule" "lms-db-postgress" {
  security_group_id = aws_security_group.lms-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

#egress / outbound rule
resource "aws_vpc_security_group_egress_rule" "lms-db-outbound" {
  security_group_id = aws_security_group.lms-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}