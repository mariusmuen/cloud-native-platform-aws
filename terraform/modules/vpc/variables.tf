variable "name" {
  type        = string
  description = "prefix for all ressource names"
}

variable "cidr" {
  type        = string
  description = "cidr block of vpc"
}

variable "azs" {
  type        = list(string)
  description = "availability zones"
}

variable "public_subnets" {
  type        = list(string)
  description = "cidr of public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "cidr block of private subnets"
}