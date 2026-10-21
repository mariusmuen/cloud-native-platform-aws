# tflint configuration for all Terraform root modules and modules.
# Run from the repository root:
#   tflint --init --config "$(pwd)/.tflint.hcl"
#   tflint --recursive --config "$(pwd)/.tflint.hcl"

config {
  call_module_type = "local"
}

# Core Terraform language rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS-specific rules: invalid instance types, deprecated arguments, etc.
plugin "aws" {
  enabled = true
  version = "0.49.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Every variable and output must be described – keeps modules self-documenting
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

# Consistent snake_case naming for resources, variables, outputs and locals
rule "terraform_naming_convention" {
  enabled = true
}
