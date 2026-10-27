variable "name" {
  type        = string
  description = "Prefix for all resource names, e.g. cnp-dev"
}

variable "cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones to spread the subnets across (EKS needs at least two)"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks of the public subnets, one per AZ (load balancers, NAT gateways)"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks of the private subnets, one per AZ (EKS nodes and pods)"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use one shared NAT gateway (lower cost, dev) instead of one per AZ (high availability, prod)"
}
