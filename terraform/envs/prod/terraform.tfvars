project     = "cnp"
environment = "prod"
region      = "eu-central-1"

vpc_cidr           = "10.20.0.0/16"
azs                = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
public_subnets     = ["10.20.0.0/24", "10.20.1.0/24", "10.20.2.0/24"]
private_subnets    = ["10.20.16.0/20", "10.20.32.0/20", "10.20.48.0/20"]
single_nat_gateway = false
