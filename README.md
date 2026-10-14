# Cloud-Native Platform on AWS

A production-style Kubernetes platform on AWS, built end to end as code: infrastructure with Terraform, CI with GitHub Actions and security scanning, GitOps delivery with Argo CD, and observability, backup and cost control on top. The workload is Google's [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo), an 11-service microservices shop.

> **Status:** 🚧 Work in progress (Oct 2026 – Jan 2027). See [Roadmap](#roadmap) and [DEVLOG](DEVLOG.md).

## Goals

- Provision all AWS infrastructure with Terraform – reproducible `apply` and `destroy`, two environments (dev, prod) from the same modules
- Ship code from `git push` to production without manual steps: build → scan → push → GitOps sync
- No long-lived credentials anywhere: OIDC for CI, IAM roles for pods, secrets from AWS Secrets Manager
- Operate the platform: metrics, logs, alerts, runbooks, backup & restore, cost monitoring

## Architecture

```
Developer ──git push──► GitHub ──► GitHub Actions: build · Trivy scan · push to ECR · bump image tag
                           │
                           └──► Argo CD (in EKS) pulls desired state from Git ──► Online Boutique (Helm)

AWS eu-central-1 (Terraform): VPC (public/private subnets) · EKS · ECR · IAM/OIDC · S3 · Secrets Manager · Lambda
In-cluster: Argo CD · Prometheus/Alertmanager · Grafana · Loki · Velero · External Secrets · NetworkPolicies
```

A detailed diagram will follow in [`docs/diagrams/`](docs/diagrams/).

## Tech Stack

| Area | Tools |
|---|---|
| Infrastructure as Code | Terraform, tflint, Checkov |
| Cloud | AWS – VPC, EKS, ECR, IAM, S3, Secrets Manager, Lambda, SNS |
| Containers & Orchestration | Docker, Kubernetes (EKS; kind for local development), Helm |
| CI / CD | GitHub Actions (OIDC to AWS), Trivy, Argo CD (GitOps) |
| Observability | Prometheus, Alertmanager, Grafana, Loki |
| Backup | Velero → S3 |
| Automation | Python (boto3) on AWS Lambda – daily cost report & cost watchdog |

## Roadmap

| Milestone | Target date | Scope | Status |
|---|---|---|---|
| M1 | 2026-11-20 | VPC, ECR, EKS via Terraform; Online Boutique reachable; clean destroy | ⏳ |
| M2 | 2026-12-04 | CI: images built & pushed automatically, Trivy blocks CRITICAL, Terraform plan in PRs | ⏳ |
| M3 | 2026-12-18 | GitOps with Argo CD, rollback via `git revert` | ⏳ |
| M4 | 2027-01-08 | Dashboards, logs, 3 alerts, first runbook | ⏳ |
| M5 | 2027-01-29 | Security (IRSA, secrets, NetworkPolicies), autoscaling, backup, cost reporting, final docs | ⏳ |

## Repository Structure

```
├── docs/                    # ADRs, runbooks, diagrams, postmortem
├── terraform/
│   ├── bootstrap/           # remote state bucket, GitHub OIDC provider
│   ├── modules/             # vpc, eks, ecr, iam, lambda
│   └── envs/{dev,prod}/     # environment root modules
├── apps/online-boutique/    # Helm chart + values per environment
├── platform/                # argocd, monitoring, logging, velero, external-secrets
├── automation/cost-report/  # Python Lambda
├── ansible/                 # optional: bastion
└── .github/workflows/       # CI pipelines
```

## Prerequisites

- AWS account with an admin IAM identity (MFA) and AWS CLI v2 (`aws login`)
- Terraform ≥ 1.9, kubectl, Helm, Docker, kind, GitHub CLI
- Region: `eu-central-1`

Setup and run instructions will be added with milestone M1.

## Cost Control

The EKS cluster runs only during working sessions and is destroyed afterwards. An AWS Budget alerts on actual spend (excluding credits) and on forecasted spend. Target: total project cost < 40 €.

## Decisions

Architecture Decision Records are in [`docs/adr/`](docs/adr/).
