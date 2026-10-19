# ADR 0002: Encrypt the Terraform state bucket with a customer managed KMS key

- **Date:** 2026-10-19
- **Status:** Accepted

## Context

Terraform state is the most sensitive artifact of the infrastructure: it maps every resource and can contain secrets in plain text (e.g. database passwords). It is stored in a dedicated S3 bucket (`cnp-tfstate-<account-id>`) created by `terraform/bootstrap`. The bucket must be encrypted, versioned, private and protected against accidental deletion (F-02).

## Options

1. **SSE-S3 (`AES256`)** – keys fully managed by S3, free, zero configuration. No separate access control or audit trail for decryption.
2. **SSE-KMS with the AWS managed key (`aws/s3`)** – audit in CloudTrail, but the key policy cannot be changed.
3. **SSE-KMS with a customer managed key (CMK)** – own key with key policy, rotation, audit, and the ability to disable access instantly. ~1 USD/month plus API calls.

## Decision

Option 3. A dedicated KMS key with automatic rotation and a 20-day deletion window. S3 Bucket Keys are enabled to cut KMS request costs. The key policy delegates access to IAM (`arn:aws:iam::<account>:root`); who may decrypt is controlled through IAM policies.

The bucket additionally has versioning (recover a corrupted state), a full public access block and `prevent_destroy`.

## Consequences

- ✅ Reading the state requires both `s3:GetObject` **and** `kms:Decrypt` – a misconfigured S3 permission alone does not expose it.
- ✅ Every decryption is logged in CloudTrail; access can be revoked by disabling the key.
- ⚠️ ~1 USD/month for the key (covered by credits).
- ⚠️ CI roles need explicit `kms:Decrypt`/`kms:GenerateDataKey` permissions on this key.
- ⚠️ Deleting the key makes all state versions permanently unreadable – the deletion window and `prevent_destroy` on the bucket mitigate this.
- ⚠️ The bootstrap project keeps its own state locally (chicken-and-egg). Losing it does not delete anything; the resources can be re-imported with `terraform import`.

**In a company** I would keep this setup and additionally restrict the key policy to specific roles (CI, platform admins), enforce TLS-only access via a bucket policy, and place the state bucket in a separate, tightly controlled account.
