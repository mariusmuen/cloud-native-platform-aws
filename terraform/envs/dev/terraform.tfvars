project     = "cnp"
environment = "dev"
region      = "eu-central-1"

vpc_cidr           = "10.10.0.0/16"
azs                = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
public_subnets     = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
private_subnets    = ["10.10.16.0/20", "10.10.32.0/20", "10.10.48.0/20"]
single_nat_gateway = true
