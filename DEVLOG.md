# DEVLOG

Three lines per session: **Done · Learned · Blocked**. Newest entries first.

---

## 2026-10-14 · Week 1 (ahead of schedule) · Terraform basics

- **Done:** S3 bucket exercise covering provider, variable, data source (`aws_caller_identity`), resource and outputs; full lifecycle `init → fmt → validate → plan → apply → destroy`.
- **Learned:** A resource is created and managed; a data source is read-only. Arguments (input) vs. attributes (output, often "known after apply"). How the provider docs are structured: Argument Reference vs. Attribute Reference. The state maps code to real resources and may contain secrets in plain text. Immutable properties (e.g. bucket name) lead to `-/+ replace`, i.e. destroy and recreate → always check a plan for `to destroy` and `forces replacement`; protect critical resources with `prevent_destroy` and use `moved` blocks for renames.
- **Blocked:** –

## 2026-10-14 · Week 0 · Securing AWS + repository

- **Done:** Verified root MFA; IAM group `admins` + user `marius-admin` with MFA, no access keys; CLI sign-in via `aws login` (temporary credentials), region `eu-central-1`; AWS Budget with alerts at 11/27 USD (actual) and 27 USD (forecasted), credits excluded; GitHub CLI connected, repository created with folder structure and `.gitignore`; branch protection for `main` via ruleset (no deletion, no force push, pull request required); forked Online Boutique. **Week 0 complete.**
- **Learned:** Free-plan accounts lose their credits as soon as they join AWS Organizations → no IAM Identity Center (see [ADR 0001](docs/adr/0001-aws-access-iam-user.md)). Budgets must exclude credits, otherwise they never alert. Permissions belong to groups, not individual users (like AGDLP in Active Directory). Never rewrite history on shared branches; if a secret leaks, rotate it first – cleaning the history alone is not enough.
- **Blocked:** Free plan ends on 2026-11-04 → upgrade to paid plan before then (credits remain valid until 2027-05-04).

## 2026-10-13 · Week 0 · Workstation setup

- **Done:** WSL2 + Ubuntu 26.04, Docker Engine running natively in Ubuntu (instead of Docker Desktop); installed AWS CLI, Terraform, kubectl, Helm, kind, k9s, tflint, gh. First local cluster with kind.
- **Learned:** Roles of Terraform (infrastructure), Kubernetes (running containers), Helm (packaging), Docker (building images). Kubernetes continuously reconciles desired and actual state: a deleted pod is replaced immediately. On EKS a node is an EC2 instance and pods run via containerd – Docker is only used for building images.
- **Blocked:** –

---

## Error Log

Real errors with symptom → cause → fix. Source for the postmortem and interview stories.

| Date | Symptom | Cause | Fix | Lesson |
|---|---|---|---|---|
| 2026-10-14 | Default CLI region was `us-east-1` instead of `eu-central-1` | `aws login` falls back to a default region if none is set | `aws configure set region eu-central-1` | Always set the region explicitly; mixed regions are a major source of forgotten resources |
| 2026-10-14 | `terraform validate`: *Reference to undeclared input variable* / *undeclared resource* | Used `var.value` instead of the data source reference; copied an output from a docs example (`aws_instance.web`) | Pointed references to my own blocks | Values only come from `var.*`, `data.*` or resources; always adapt docs examples to your own code |
| 2026-10-14 | git commit email was the placeholder text | Copied a command with a placeholder without replacing it | `git config --global user.email` with GitHub noreply address | Check `git config --list` before the first commit |
