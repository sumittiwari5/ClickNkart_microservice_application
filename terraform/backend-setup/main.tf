# WHY THIS FILE IS SEPARATE FROM EVERYTHING ELSE:
# Terraform needs somewhere to store its "state" (a JSON file tracking what
# it already created) BEFORE it can manage anything else - that's a
# chicken-and-egg problem if the state bucket itself was managed by the
# same Terraform config that needs the bucket to run. So this one small
# config is run ONCE, manually, with purely local state, just to create
# the S3 bucket + DynamoDB table. Every other module then points at this
# bucket as its *remote* backend.
#
# S3 bucket: stores the actual state file (what exists, its IDs, its
#   current config) - this is what lets you run `terraform plan` from any
#   machine and get the real picture, not just what's on your laptop.
# DynamoDB table: used purely for STATE LOCKING - it stops two people (or
#   two Jenkins jobs) running `terraform apply` at the exact same time and
#   corrupting the state file. Terraform writes a lock row before it starts
#   and removes it when done; a second run sees the lock and waits/fails
#   instead of racing.

terraform {
    required_version = ">= 1.6.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

variable "aws_region" {
    description = "AWS region for all resources"
    type        = string
    default     = "ap-south-1"
}

variable "state_bucket_name" {
    description = "Name of the S3 bucket to store Terraform state"
    type        = string
    default     = "clicknkart-terraform-state-12345"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = var.state_bucket_name

    # Prevents `terraform destroy` (run against the WRONG config, by mistake)
    # from being able to delete the bucket that every other module depends on.
    lifecycle {
        prevent_destroy = true
    }
}
    
resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        # If a bad `apply` corrupts the state file, versioning lets you recover
        # the previous good copy from S3's version history - this has saved
        # real production deployments before, it's not a theoretical nicety.
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
    name         = "clicknkart-terraform-lock"
    billing_mode = "PAY_PER_REQUEST" # no idle cost - you're only billed per lock read/write, not for a provisioned table sitting there unused
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    # Prevents `terraform destroy` (run against the WRONG config, by mistake)
    # from being able to delete the table that every other module depends on.
    lifecycle {
        prevent_destroy = true
    }
}

output "state_bucket_name" {
    value       = aws_s3_bucket.terraform_state.bucket
    description = "The name of the S3 bucket used for Terraform state"
}

output "lock_table_name" {
    value       = aws_dynamodb_table.terraform_lock.name
    description = "The name of the DynamoDB table used for Terraform state locking"
}




