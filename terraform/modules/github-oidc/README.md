# Module: github-oidc

Lets GitHub Actions authenticate to AWS without access keys ([ADR 0005](../../../docs/adr/0005-github-oidc.md)).

- **OIDC provider** for `token.actions.githubusercontent.com`
- **IAM role** `<name>-github-actions` – trust policy accepts only tokens with audience `sts.amazonaws.com` from the `main` branch of `github_repository`
- **Inline policy** – push to the given ECR repositories only (plus `ecr:GetAuthorizationToken`, which AWS does not allow to scope)

## Usage

```hcl
module "github_oidc" {
  source = "../../modules/github-oidc"

  name                = "cnp"
  github_repository   = "mariusmuen/cloud-native-platform-aws"
  ecr_repository_arns = values(module.ecr.repository_arns)
}
```

In the workflow:

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ vars.AWS_ROLE_ARN }}
      aws-region: eu-central-1
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
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| ecr\_repository\_arns | ARNs of the ECR repositories the role may push to | `list(string)` | n/a | yes |
| github\_repository | GitHub repository (owner/name) whose main branch may assume the role | `string` | n/a | yes |
| name | Prefix for resource names; the role is called <name>-github-actions | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| role\_arn | attribute .arn of the role |
<!-- END_TF_DOCS -->
