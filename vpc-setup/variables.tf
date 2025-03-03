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

# Varibale vpc tenancy
variable "vpc_name"{
 type = string
 default = "login"
 }

# Varibale public subnet 
variable "public_subent_cidrs"{
 type = map(string)
  default = {
    frontend = "10.0.0.0/24"
    backend = "10.0.1.0/24"
  }
 }
