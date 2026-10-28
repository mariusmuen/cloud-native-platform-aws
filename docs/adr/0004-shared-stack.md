# ADR 0004: Separate `shared` stack for long-lived, cross-environment resources

- **Date:** 2026-10-28
- **Status:** Accepted

## Context

The `dev` environment is destroyed after every work session to avoid paying for EKS and NAT gateways. Some resources must survive that cycle and are used by more than one environment:

- the container registry (ECR) – images built once must be deployable to dev and later to prod
- the CI identity (GitHub OIDC provider and IAM role) – the pipeline must be able to push images even when no cluster is running

## Options

1. **Put them into `envs/dev`** – simple, but every `terraform destroy` would delete all repositories and images; prod would need its own registry and rebuild images.
2. **Put them into `bootstrap`** – already long-lived, but bootstrap keeps local state and should stay minimal (state bucket only).
3. **A separate root module `envs/shared`** with its own remote state (`envs/shared/terraform.tfstate`).

## Decision

Option 3. `terraform/envs/shared` holds long-lived resources used by all environments. It follows the same conventions as dev/prod (S3 backend with locking, `default_tags` with `Environment = shared`) and is not destroyed after sessions.

## Consequences

- ✅ `dev` can be destroyed and recreated freely without losing images.
- ✅ "Build once, deploy many": the same image digest moves from dev to prod.
- ✅ Separate state = smaller blast radius; a mistake in dev cannot touch the registry.
- ⚠️ One more root module to apply; outputs (e.g. repository URLs) have to be passed to other stacks or the pipeline.
- ⚠️ Costs are negligible: ECR charges only for stored image data (~0.10 USD per GB-month).

**In a company** the registry and CI identities would typically live in a dedicated "shared services" or "tooling" AWS account, with cross-account pull permissions for the workload accounts.
