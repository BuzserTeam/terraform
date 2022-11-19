variable "region" {
  default = "us-west-2"
}

variable "main_vpc_cidr" {
     default = "0.0.0.0/16" 
}

variable "public_subnet" {
    default = "0.0.0.0/24"
}

variable "private_subnet" {
    default = "0.0.0.0/16"
}