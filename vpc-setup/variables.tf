# Varibales
variable "aws_access_key"{
 type = string
 }
 
variable "aws_secret_key"{
 type = string
 }

# Varibale vpc cidr
variable "vpc_cidr"{
 type = string
 default = "10.0.0.0/16"
 }

# Varibale vpc tenancy
variable "vpc_tenancy"{
 type = string
 default = "default"
 }

# Varibale vpc 
variable "vpc_name"{
 type = string
 default = "login"
 }

# Varibale public subnet 
variable "public_subnet_cidrs"{
 type = map(string)
  default = {
    frontend = "10.0.0.0/24"
    backend = "10.0.1.0/24"
  }
 }

# Varibale private subnet
variable "private_subnet_cidr"{
 type = string
 default = "10.0.2.0/24"
 }

# Varibales fe ports
variable "web_ingress_ports" {
  description = "ports allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    {port = 22, cidr = "0.0.0.0/0"},
    {port = 80, cidr = "0.0.0.0/0"}
  ]
}

# Varibales be ports
variable "app_ingress_ports" {
  description = "ports allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    {port = 22, cidr = "0.0.0.0/0"},
    {port = 8080, cidr = "0.0.0.0/0"}
  ]
}

# Varibales db ports
variable "db_ingress_ports" {
  description = "ports allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    {port = 22, cidr = "0.0.0.0/0"},
    {port = 5432, cidr = "0.0.0.0/0"}
  ]
}

# Varibale common outboud
variable "common_egress_rule"{
  default = {
    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = "-1" # semantically equivalent to all ports
  }
 }