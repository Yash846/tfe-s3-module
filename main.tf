# ---------------------------------------------------------
# Terraform Configuration & Provider
# ---------------------------------------------------------
terraform {
  required_version = ">= 1.0"
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

# ---------------------------------------------------------
# Input Variables (Visible in No-Code UI)
# ---------------------------------------------------------
variable "bucket_name" {
  description = "Name of the S3 bucket (Must be globally unique)"
  type        = string
  default     = "wxo-mcp-bucket"
}

variable "aws_region" {
  description = "AWS Region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment tag (e.g. demo, prod)"
  type        = string
  default     = "demo"
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable default encryption (AES256)"
  type        = bool
  default     = true
}

# ---------------------------------------------------------
# Resources
# ---------------------------------------------------------

# 1. S3 Bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name
  
  # Force destroy allows deleting the bucket even if it has files (Useful for Demos)
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform-No-Code"
  }
}

# 2. Versioning
resource "aws_s3_bucket_versioning" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# 3. Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "demo_bucket" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Public Access Block (Security)
resource "aws_s3_bucket_public_access_block" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. Lifecycle Rule (Cleanup)
resource "aws_s3_bucket_lifecycle_configuration" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    expiration {
      days = 90
    }

    # We only add this rule if versioning is actually enabled
    dynamic "noncurrent_version_expiration" {
      for_each = var.enable_versioning ? [1] : []
      content {
        noncurrent_days = 30
      }
    }
  }
}

# ---------------------------------------------------------
# Outputs (Returned to the UI)
# ---------------------------------------------------------
output "bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.demo_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.arn
}

output "bucket_region" {
  description = "Region where bucket is created"
  value       = aws_s3_bucket.demo_bucket.region
}