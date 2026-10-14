# ADR 0001: AWS access via IAM user with MFA and `aws login` instead of IAM Identity Center

- **Date:** 2026-10-14
- **Status:** Accepted

## Context

Day-to-day work (console, CLI, Terraform) needs an identity with admin permissions – not root, and without long-lived access keys on the workstation (NF-01).
Best practice would be IAM Identity Center (SSO). It requires AWS Organizations, however. The account is on the **free plan** with about 158 USD in credits (valid until 2027-05-04). Creating or joining an organization ends those credits immediately.

## Options

1. **IAM Identity Center + Organizations** – best practice, short-lived credentials, but all credits are lost.
2. **IAM user with access keys** – simple, but long-lived keys on disk; high risk if leaked (e.g. accidentally committed).
3. **IAM user with MFA + `aws login`** – the CLI obtains temporary credentials through the console sign-in; no access keys.

## Decision

Option 3. User `marius-admin` in group `admins` (policy `AdministratorAccess`), MFA enabled, no access keys. CLI sign-in via `aws login`. Root is protected with MFA and no longer used.

## Consequences

- ✅ No long-lived keys; stolen credentials expire quickly.
- ✅ Credits are preserved and are expected to cover the whole project.
- ✅ Permissions are attached to the group, not the user – easy to extend.
- ⚠️ IAM users are a single-account pattern; no central identity management.
- ⚠️ `AdministratorAccess` is deliberately broad because this user builds the entire platform.

**In a company** I would use a multi-account setup with AWS Organizations (separate accounts for dev/staging/prod) and IAM Identity Center connected to the existing identity provider (e.g. Entra ID), with role-based permission sets instead of blanket admin rights.
Machine identities (GitHub Actions, pods) use roles with temporary credentials in this project anyway (OIDC, IRSA) – see later ADRs.
