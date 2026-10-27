# Module: vpc

Creates the network for an EKS cluster: a VPC with one public and one private subnet per Availability Zone, an Internet Gateway, NAT gateway(s) and route tables. Design rationale: [ADR 0003](../../../docs/adr/0003-network-design.md).

- **Public subnets** – load balancers and NAT gateways; tagged `kubernetes.io/role/elb = 1`
- **Private subnets** – EKS nodes and pods; tagged `kubernetes.io/role/internal-elb = 1`; outbound internet via NAT
- **NAT topology** – `single_nat_gateway = true` creates one shared NAT gateway (dev); `false` creates one per AZ with its own route table (prod)

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "cnp-dev"
  cidr               = "10.10.0.0/16"
  azs                = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets     = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
  private_subnets    = ["10.10.16.0/20", "10.10.32.0/20", "10.10.48.0/20"]
  single_nat_gateway = true
}
```

The provider (region, default tags) is configured by the calling root module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10 |
| aws | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| azs | Availability Zones to spread the subnets across (EKS needs at least two) | `list(string)` | n/a | yes |
| cidr | CIDR block of the VPC | `string` | n/a | yes |
| name | Prefix for all resource names, e.g. cnp-dev | `string` | n/a | yes |
| private\_subnets | CIDR blocks of the private subnets, one per AZ (EKS nodes and pods) | `list(string)` | n/a | yes |
| public\_subnets | CIDR blocks of the public subnets, one per AZ (load balancers, NAT gateways) | `list(string)` | n/a | yes |
| single\_nat\_gateway | Use one shared NAT gateway (lower cost, dev) instead of one per AZ (high availability, prod) | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| private\_subnet\_ids | IDs of the private subnets, in the order of var.azs (used by EKS) |
| public\_subnet\_ids | IDs of the public subnets, in the order of var.azs |
| vpc\_id | ID of the VPC |
<!-- END_TF_DOCS -->
