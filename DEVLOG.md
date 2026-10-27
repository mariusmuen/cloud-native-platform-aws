# DEVLOG

Three lines per session: **Done · Learned · Blocked**. Newest entries first.

---

## 2026-10-27 · Week 2 · Configurable NAT topology, prod network, module docs

- **Done:** `single_nat_gateway` variable in the VPC module: one shared NAT and route table (dev, 18 resources) or one NAT and route table per AZ (prod, 24 resources). Moved all network values from `main.tf` into variables and `terraform.tfvars`, so `envs/dev` and `envs/prod` now have identical code; prod uses `10.20.0.0/16` with a NAT per AZ. Module README generated with terraform-docs. Both environments planned successfully (nothing applied).
- **Learned:** Conditional expressions (`cond ? a : b`) work in `count` and in index positions – `aws_route_table.private[var.single_nat_gateway ? 0 : count.index]` maps every subnet to the shared table or to its own. Turning a single resource into a `count` resource changes its address (`aws_eip.nat` → `aws_eip.nat[0]`); on live infrastructure that means destroy/recreate unless a `moved` block is added. A cost-safe default is acceptable for a feature toggle, while environment-specific values stay required. Good variable descriptions pay off twice: in code review and in generated docs.
- **Blocked:** –

## 2026-10-23 · Week 2 · VPC module (part 2): NAT gateway and private routing

- **Done:** Applied the VPC module from `main` (12 resources) and verified it in the console. Added an Elastic IP, a NAT gateway in the first public subnet and a dedicated private route table (`0.0.0.0/0 → NAT`) with explicit associations for all private subnets. Incremental `apply` added 6 resources without touching the existing 12; a follow-up `plan` showed no drift. Screenshot of the resource map added to the README; everything destroyed afterwards (18 resources).
- **Learned:** Without an explicit association, subnets fall back to the VPC's main route table – an explicit private route table keeps routing visible in code. Route targets use different arguments (`gateway_id` for the IGW, `nat_gateway_id` for a NAT) and `validate` can't tell them apart. Terraform orders resources by references (implicit dependencies); the NAT gateway needs the IGW but doesn't reference it, so `depends_on` makes the dependency explicit – also for the reverse order on `destroy`. A running `apply` holds the state lock, so a parallel `plan` fails as expected.
- **Blocked:** –

## 2026-10-22 · Week 2 · VPC module (part 1)

- **Done:** First reusable module `terraform/modules/vpc`: VPC with DNS support/hostnames, 3 public and 3 private subnets across 3 AZs (with EKS load balancer tags), Internet Gateway, public route table and associations. Called from `envs/dev` with the CIDRs from ADR 0003. `plan`: 12 to add. NAT gateway and private routing follow next.
- **Learned:** A module is like a function – variables in, resources, outputs out – and has no `provider` or `backend` block; it inherits the caller's provider (and region). Environment-specific inputs get no defaults so callers must set them. `count` + `count.index` create one block per list element; `length()` keeps the count in sync with the input list. `resource[*].id` returns all IDs as a list, `resource[count.index].id` exactly one – the type error *string required, but have tuple* tells you which one is needed. Module resources are addressed as `module.vpc.aws_subnet.public[0]`. `default_tags` show up in `tags_all` without a single tag line in the module.
- **Blocked:** –

## 2026-10-21 · Week 2 · Linting setup

- **Done:** Added a repository-wide `.tflint.hcl` (Terraform `recommended` preset, AWS ruleset 0.49.0, documented variables/outputs, naming convention). First run found 4 issues; fixed the missing `required_version` and an undocumented output in `bootstrap`. Lint commands documented in the README.
- **Learned:** `tflint --recursive` lints every root module with one shared config; plugins are pinned like providers. The remaining warnings (`local.name_prefix` declared but not used in dev/prod) are expected – they resolve once the VPC module consumes the prefix.
- **Blocked:** –

## 2026-10-20 · Week 2 · Network design

- **Done:** Network concept for the EKS VPC as [ADR 0003](docs/adr/0003-network-design.md) (proposed) and a [network diagram](docs/diagrams/network.md): non-overlapping CIDRs per environment, 3 AZs, small public and large private subnets, single NAT gateway in dev.
- **Learned:** EKS-specific sizing: with the AWS VPC CNI every pod gets an IP from the node's subnet, so private subnets need far more address space than in a classic EC2 setup (`/20` per AZ). EKS discovers subnets for load balancers via the tags `kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`. The NAT topology will be a variable (`single_nat_gateway`) so dev and prod can differ without code changes.
- **Blocked:** –

## 2026-10-19 · Week 1 · Variables, tags, naming, prod environment

- **Done:** `variables.tf` (`project`, `environment` without default, `region`), `terraform.tfvars` per environment, provider `default_tags` (`Project`, `Environment`, `ManagedBy`), `local.name_prefix` (`cnp-dev`). Created `envs/prod` mirroring dev – the two environments differ in exactly two lines (state key and `environment`), which fulfils F-03. Conventions documented in the README.
- **Learned:** `variables.tf` declares, `terraform.tfvars` assigns, `main.tf` uses (`var.x` or `"${var.x}"` inside strings) – no imports needed. A required variable without default makes `plan` fail until it is set. Locals are for derived values. Provider `default_tags` replace per-resource tag blocks. `terraform validate` only checks syntax – a malformed interpolation like `"{$var.x}"` is still a valid literal string, so plans and reviews remain essential. Provider, variables and locals create nothing, so `plan` shows "No changes" until resources exist.
- **Blocked:** –

## 2026-10-19 · Week 1 · Remote backend with state locking

- **Done:** `terraform/envs/dev` split into `versions.tf`, `backend.tf`, `main.tf`; S3 backend (`key = envs/dev/terraform.tfstate`, `encrypt = true`, `use_lockfile = true`). Migrated a local test state to S3 with `terraform init -migrate-state`. Tested locking with two terminals: the second `plan` failed with *Error acquiring the state lock* while the first `apply` was waiting for confirmation (F-02 ✅). Removed the test resource afterwards.
- **Learned:** Terraform merges all `.tf` files in a folder; each folder is its own root module with its own state – `apply` only sees the current directory. Backend blocks can't use variables. S3 native locking writes a `.tflock` object with a conditional write (HTTP 412 *PreconditionFailed* if it already exists) – no DynamoDB needed. Every state-touching command holds the lock only while it runs; stuck locks → `terraform force-unlock`. Bucket versioning kept every state revision (11 versions after the test).
- **Blocked:** –

## 2026-10-19 · Week 1 · Bootstrap: Terraform state bucket

- **Done:** `terraform/bootstrap` creates the state bucket `cnp-tfstate-<account-id>` with versioning, SSE-KMS (customer managed key with rotation, S3 Bucket Key), full public access block and `prevent_destroy`. Applied successfully (5 resources).
- **Learned:** In the AWS provider, many S3 settings are separate resources that reference the bucket (versioning, encryption, public access block). Provider docs examples are not secure defaults – e.g. the public access block example sets all four flags to `false` – so every copied value needs review. Nested blocks have their own arguments (`bucket_key_enabled` belongs to `rule`). KMS CMK vs. SSE-S3 → [ADR 0002](docs/adr/0002-state-bucket-kms-encryption.md). The bootstrap state stays local (chicken-and-egg).
- **Blocked:** –

## 2026-10-14 · Week 1 (ahead of schedule) · Terraform basics

- **Done:** S3 bucket exercise covering provider, variable, data source (`aws_caller_identity`), resource and outputs; full lifecycle `init → fmt → validate → plan → apply → destroy`.
- **Learned:** A resource is created and managed; a data source is read-only. Arguments (input) vs. attributes (output, often "known after apply"). How the provider docs are structured: Argument Reference vs. Attribute Reference. The state maps code to real resources and may contain secrets in plain text. Immutable properties (e.g. bucket name) lead to `-/+ replace`, i.e. destroy and recreate → always check a plan for `to destroy` and `forces replacement`; protect critical resources with `prevent_destroy` and use `moved` blocks for renames.
- **Blocked:** –

## 2026-10-14 · Week 0 · Securing AWS + repository

- **Done:** Verified root MFA; IAM group `admins` + user `marius-admin` with MFA, no access keys; CLI sign-in via `aws login` (temporary credentials), region `eu-central-1`; AWS Budget with alerts at 11/27 USD (actual) and 27 USD (forecasted), credits excluded; GitHub CLI connected, repository created with folder structure and `.gitignore`; branch protection for `main` via ruleset (no deletion, no force push, pull request required); forked Online Boutique. **Week 0 complete.**
- **Learned:** Free-plan accounts lose their credits as soon as they join AWS Organizations → no IAM Identity Center (see [ADR 0001](docs/adr/0001-aws-access-iam-user.md)). Budgets must exclude credits, otherwise they never alert. `aws login` gives the CLI short-lived credentials from a console session – no access keys on disk. Never rewrite history on shared branches; if a secret leaks, rotate it first – cleaning the history alone is not enough.
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
| 2026-10-19 | `aws login` in WSL ended with *400 Bad Request* in the browser | Selecting the existing (stale) console session offered on the sign-in page | `aws login --remote` and choose "Sign into new session" | Temporary credentials expire by design; when re-authenticating, start a fresh session |
| 2026-10-14 | Default CLI region was `us-east-1` instead of `eu-central-1` | `aws login` falls back to a default region if none is set | `aws configure set region eu-central-1` | Always set the region explicitly; mixed regions are a major source of forgotten resources |
