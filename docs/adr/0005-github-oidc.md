# ADR 0005: GitHub Actions authenticates to AWS via OIDC – no access keys

- **Date:** 2026-10-29
- **Status:** Accepted

## Context

From week 6 the CI pipeline builds images and pushes them to ECR, so GitHub Actions needs AWS credentials. NF-01 forbids access keys or passwords in the repository.

## Options

1. **IAM user with access keys stored as GitHub secrets** – easy, but long-lived credentials: they never expire, must be rotated manually, and a leak (logs, compromised action, misconfigured fork) grants access until someone notices.
2. **Self-hosted runner with an instance profile** – no keys, but a permanently running EC2 instance to patch and pay for.
3. **OpenID Connect federation** – GitHub issues a signed, short-lived token per workflow run; AWS STS exchanges it for temporary credentials of an IAM role (`AssumeRoleWithWebIdentity`).

## Decision

Option 3, implemented in `terraform/modules/github-oidc` and deployed in the `shared` stack:

- IAM OIDC provider for `token.actions.githubusercontent.com` with audience `sts.amazonaws.com`
- IAM role `cnp-github-actions` whose trust policy requires
  - `aud = sts.amazonaws.com`
  - `sub = repo:mariusmuen/cloud-native-platform-aws:ref:refs/heads/main`
- Inline policy with least privilege: `ecr:GetAuthorizationToken` (cannot be scoped) plus push actions **only** on the project's three ECR repositories
- The role ARN is stored as a GitHub repository *variable* (not secret) – it is useless without a valid token

## Consequences

- ✅ No stored credentials anywhere; tokens expire after about an hour.
- ✅ The `sub` condition restricts access to reviewed code on `main`: other repositories, forks, feature branches and pull requests cannot assume the role. Without it, *any* GitHub workflow could assume the role, because the OIDC provider trusts all GitHub-issued tokens.
- ✅ Every role session is visible in CloudTrail with the repository and workflow as context.
- ⚠️ Workflows on other branches cannot reach AWS – checks needing AWS on pull requests (e.g. `terraform plan`, week 7) will need an additional, read-only role trusted for `pull_request` tokens.
- ⚠️ The pipeline cannot be tested from a feature branch; it runs successfully only after merge.

**In a company** I would add separate roles per purpose (build, plan, apply), use GitHub environments with required reviewers for deployment roles, and possibly restrict by `job_workflow_ref` so only a specific, reviewed workflow file may assume a role.
