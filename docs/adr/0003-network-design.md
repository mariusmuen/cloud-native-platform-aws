# ADR 0003: VPC network design for EKS

- **Date:** 2026-10-20
- **Status:** Proposed

## Context

The EKS cluster needs a VPC created by the `vpc` module (week 2). Requirements:

- EKS requires subnets in at least two Availability Zones.
- With the AWS VPC CNI every pod receives an IP address from its subnet – address space in node subnets is consumed quickly (Online Boutique alone runs ~12 pods, plus monitoring, Argo CD, etc.).
- Nodes must not be reachable from the internet but need outbound access (pull images, AWS APIs).
- Budget: the environment runs only during work sessions; NAT gateways are the main fixed network cost.
- dev and prod may need to be connected later (peering, VPN, Transit Gateway).

## Decision

| Aspect | Decision |
|---|---|
| VPC CIDR | dev `10.10.0.0/16`, prod `10.20.0.0/16` – non-overlapping |
| Availability Zones | 3 (`eu-central-1a/b/c`) |
| Public subnets | one `/24` per AZ – load balancers and NAT gateway only |
| Private subnets | one `/20` per AZ (4,096 IPs) – EKS nodes and pods |
| Internet access | Internet Gateway for public subnets; NAT gateway for private subnets |
| NAT gateways | dev: **one** shared NAT (`single_nat_gateway = true`); prod: one per AZ |
| EKS subnet tags | public: `kubernetes.io/role/elb = 1`; private: `kubernetes.io/role/internal-elb = 1` |

Subnet ranges for dev:

| | AZ a | AZ b | AZ c |
|---|---|---|---|
| Public `/24` | `10.10.0.0/24` | `10.10.1.0/24` | `10.10.2.0/24` |
| Private `/20` | `10.10.16.0/20` | `10.10.32.0/20` | `10.10.48.0/20` |

See [network diagram](../diagrams/network.md).

## Options considered

- **2 vs. 3 AZs:** 2 AZs meet the EKS minimum; 3 AZs cost nothing extra for subnets, match the common production pattern and improve Spot capacity availability.
- **Nodes in public subnets:** simpler (no NAT needed) but exposes nodes with public IPs – rejected.
- **One NAT per AZ in dev:** highest availability, but ~3× the cost (~100 USD/month if running continuously) – rejected for dev.
- **No NAT (VPC endpoints only):** cheapest at runtime but needs many endpoints (ECR, S3, STS, EC2, logs …) and still blocks public images – rejected for now.

## Consequences

- ✅ Nodes and pods are private; only load balancers and the NAT are internet-facing.
- ✅ Large private subnets leave room for pod IPs and autoscaling.
- ✅ dev and prod can be connected later without re-addressing.
- ⚠️ dev has a single point of failure for outbound traffic: if AZ a fails, private subnets in b and c lose internet access. Cross-AZ traffic to the NAT incurs data transfer charges. Acceptable for dev.
- ⚠️ The NAT gateway costs ~0.045 USD/h + 0.045 USD/GB and must be destroyed after each session.

**In a company** prod would use one NAT gateway per AZ, VPC endpoints for S3/ECR to reduce NAT traffic, VPC flow logs, and an IP address plan coordinated with on-premises networks.
