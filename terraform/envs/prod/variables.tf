variable "project" {
  type        = string
  default     = "cnp"
  description = "name of the project"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev or prod)"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "region of the project"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones to spread the subnets across"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks of the public subnets, one per AZ"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks of the private subnets, one per AZ"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use one shared NAT gateway instead of one per AZ"
}
