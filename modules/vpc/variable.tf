variable "vpc_cidr" {}
variable "env" {}
variable "region" {}
variable "az" {}
variable "tags" {
    type = map(string)
}


variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
