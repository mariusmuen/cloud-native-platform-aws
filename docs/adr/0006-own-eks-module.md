# ADR 0006: Own EKS module instead of `terraform-aws-modules/eks`

- **Date:** 2026-11-19
- **Status:** Accepted

## Context

The platform needs an EKS cluster with a managed node group and the core add-ons. Two common ways to build it with Terraform:

1. the community module [`terraform-aws-modules/eks/aws`](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws), widely used in companies
2. an own module built from the AWS provider resources

A primary goal of this project is to understand every building block well enough to explain and debug it.

## Options

1. **Community module** – battle-tested, covers many edge cases (IRSA, access entries, KMS encryption, launch templates, Karpenter), new EKS features arrive via version bumps. But hundreds of inputs, a lot of hidden logic, and major version upgrades can force refactoring.
2. **Own module** – only what this project needs (~100 lines): cluster role, node role, cluster, managed node group, add-ons. Every resource is visible and explainable; maintenance is on me.

## Decision

Option 2. `terraform/modules/eks` contains:

- IAM role for the control plane (`AmazonEKSClusterPolicy`)
- IAM role for the worker nodes (`AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`)
- `aws_eks_cluster` with API authentication mode and admin access for the creator
- `aws_eks_node_group` in the private subnets
- add-ons `vpc-cni`, `coredns`, `kube-proxy`

## Consequences

- ✅ Full understanding of IAM roles, node group and add-ons; easier to debug.
- ✅ Small, readable code that matches the project scope.
- ⚠️ Features have to be added by hand when needed (access entries, cluster OIDC provider for IRSA, autoscaling).
- ⚠️ Upgrades and best practices must be tracked manually.
- ⚠️ Node role permissions are reachable by pods on the node; application permissions will be granted via IRSA instead (week 13).

**In a company** I would usually use the community module with a pinned version, because it lowers maintenance effort considerably – and having built the pieces myself, I can still read and debug what it creates.
