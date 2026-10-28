# Module: ecr

Creates one ECR repository per service, named `<name>/<service>`.

- **Immutable tags** – a tag (the Git commit SHA) can never be overwritten, so every deployed version is traceable and rollbacks are reliable
- **Scan on push** – every pushed image is scanned for known vulnerabilities
- **Lifecycle policy** – untagged images expire after 1 day; only the last `keep_last_images` images are kept
- **`force_delete`** – repositories can be destroyed even if they contain images (acceptable for this project; in production this would be a deliberate decision)

Repositories are created with `for_each`, so each one is addressed by its service name (`this["frontend"]`) and removing a service from the list does not affect the others.

## Usage

```hcl
module "ecr" {
  source = "../../modules/ecr"

  name         = "cnp"
  repositories = ["frontend", "cartservice", "checkoutservice"]
}
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
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Prefix for the repository names, e.g. cnp → cnp/frontend | `string` | n/a | yes |
| repositories | Service names to create a repository for, e.g. ["frontend", "cartservice"] | `list(string)` | n/a | yes |
| keep\_last\_images | Number of images to keep per repository; older ones are expired by the lifecycle policy | `number` | `10` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repository\_arns | Map of service name to repository ARN, used to scope IAM permissions for CI |
| repository\_urls | Map of service name to repository URL, used by CI to push and by Helm to pull images |
<!-- END_TF_DOCS -->
