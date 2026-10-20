# Network – dev environment

VPC `10.10.0.0/16` in `eu-central-1`, three Availability Zones. See [ADR 0003](../adr/0003-network-design.md).

```mermaid
flowchart TB
    internet((Internet))
    igw[Internet Gateway]
    internet <--> igw

    subgraph vpc["VPC cnp-dev · 10.10.0.0/16"]
        subgraph aza["AZ eu-central-1a"]
            puba["Public 10.10.0.0/24<br/>NAT Gateway · Load Balancer"]
            priva["Private 10.10.16.0/20<br/>EKS nodes · pods"]
        end
        subgraph azb["AZ eu-central-1b"]
            pubb["Public 10.10.1.0/24<br/>Load Balancer"]
            privb["Private 10.10.32.0/20<br/>EKS nodes · pods"]
        end
        subgraph azc["AZ eu-central-1c"]
            pubc["Public 10.10.2.0/24<br/>Load Balancer"]
            privc["Private 10.10.48.0/20<br/>EKS nodes · pods"]
        end
    end

    igw <--> puba & pubb & pubc
    priva & privb & privc -- "outbound via NAT" --> puba
```

## Traffic flows

- **Customer → shop:** Internet → Internet Gateway → Load Balancer (public subnets) → frontend pods (private subnets)
- **Node → internet** (image pulls, AWS APIs): private subnet → NAT Gateway (AZ a) → Internet Gateway
- **Pod → pod:** directly inside the VPC, every pod has a VPC IP (AWS VPC CNI)

## Route tables

| Route table | Associated with | Default route `0.0.0.0/0` |
|---|---|---|
| public | all public subnets | Internet Gateway |
| private | all private subnets | NAT Gateway (dev: one shared) |
