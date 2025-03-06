#vpc
resource "aws_vpc" "login-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.vpc_tenancy

  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.login-vpc.id
  for_each                = var.public_subnet_cidrs
  cidr_block              = each.value
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.vpc_name}-db-subnet"
  }
}

# Inetrnet Gateway
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
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
    Name = "${var.vpc_name}-public-route"
  }
}

# private route table 
resource "aws_route_table" "login-private-rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-private-route"
  }
}

#public subnet association 
resource "aws_route_table_association" "login-public-asc" {
  for_each       = var.public_subnet_cidrs 
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.login-public-rt.id
}

# private association database
resource "aws_route_table_association" "login-private-asc" {
  subnet_id      = aws_subnet.private_subnet.id  # Corrected reference here
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
    Name = "${var.vpc_name}-nacl"
  }
}

# Security group fe
resource "aws_security_group" "login-fe-sg" {
  name        = "login-fe-sg"
  description = "Allow frontend traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-fe-sg"
  }
}

#Security group rules fe ports
resource "aws_vpc_security_group_ingress_rule" "login-web-ingress" {
  count             = length(var.web_ingress_ports)
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = var.web_ingress_ports[count.index].cidr
  from_port         = var.web_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.web_ingress_ports[count.index].port
}

# Security group be
resource "aws_security_group" "login-app-sg" {
  name        = "login-app-sg"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-be-sg"
  }
}

#Security group rules be/app ports
resource "aws_vpc_security_group_ingress_rule" "login-app-ingress" {
  count             = length(var.app_ingress_ports)
  security_group_id = aws_security_group.login-app-sg.id
  cidr_ipv4         = var.app_ingress_ports[count.index].cidr
  from_port         = var.app_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.app_ingress_ports[count.index].port
}

# Security group database
resource "aws_security_group" "login-db-sg" {
  name        = "login-db-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

#Security group rules database ports
resource "aws_vpc_security_group_ingress_rule" "login-db-ingress" {
  count             = length(var.db_ingress_ports)
  security_group_id = aws_security_group.login-db-sg.id
  cidr_ipv4         = var.db_ingress_ports[count.index].cidr
  from_port         = var.db_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.db_ingress_ports[count.index].port
}

# Locals for easier access
locals {
  security_groups = {
    web = aws_security_group.login-fe-sg.id
    app = aws_security_group.login-app-sg.id
    db  = aws_security_group.login-db-sg.id
  }
}

#egress / outbound rule
resource "aws_vpc_security_group_egress_rule" "common_egress" {
  for_each          = local.security_groups
  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}