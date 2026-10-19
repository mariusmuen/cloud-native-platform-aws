terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "bucket_prefix" {
  type        = string
  default     = "cnp-tfstate"
  description = "Prefix for the state bucket name (account ID is appended)"

}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "cnp-tfstate"
    Project = "cloud-native-platform"
    Purpose = "terraform-state"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "tfstate" {
  description             = "Encrypts the Terraform state bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },

    ]
  })
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstate.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "bucket_name" {
  description = "Name of the bucket"
  value       = aws_s3_bucket.tfstate.id
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.tfstate.arn
}
