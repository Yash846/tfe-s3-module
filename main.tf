# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create a unique bucket name by appending a random suffix
resource "random_pet" "suffix" {
  length = 2
}

# The main S3 bucket resource
resource "aws_s3_bucket" "this" {
  # Bucket names must be globally unique.
  bucket = "${var.bucket_prefix}-${random_pet.suffix.id}"

  tags = merge(
    { "ManagedBy" = "Terraform" },
    var.tags
  )
}

# Configure the bucket for public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure the bucket for website hosting
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}