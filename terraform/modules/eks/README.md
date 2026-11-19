# Module: eks

Creates an EKS cluster with a managed node group in the given (private) subnets. Rationale for building it instead of using the community module: [ADR 0006](../../../docs/adr/0006-own-eks-module.md).

- **Cluster role** – lets the EKS service manage network interfaces and load balancers (`AmazonEKSClusterPolicy`)
- **Node role** – lets worker nodes join the cluster, assign pod IPs and pull images from ECR
- **Cluster** – authentication mode `API`; whoever creates the cluster gets admin access
- **Managed node group** – `t3.medium` Spot instances, 2 nodes by default (min 1, max 3)
- **Add-ons** – `vpc-cni` (pod IPs from the VPC), `coredns` (service discovery), `kube-proxy` (service routing); created after the node group because they run as pods

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  name               = "cnp-dev"
  kubernetes_version = "1.37"
  subnet_ids         = module.vpc.private_subnet_ids
}
```

Connect `kubectl` after apply:

```bash
aws eks update-kubeconfig --name cnp-dev --region eu-central-1
kubectl get nodes
```

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
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.cluster_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| kubernetes\_version | Kubernetes version of the cluster, e.g. 1.34 | `string` | n/a | yes |
| name | Prefix for all resource names, e.g. cnp-dev | `string` | n/a | yes |
| subnet\_ids | Private subnet IDs for the cluster and the worker nodes | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| cluster\_endpoint | URL of the Kubernetes API server |
| cluster\_name | Name of the EKS cluster |
<!-- END_TF_DOCS -->
