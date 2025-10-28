# outputs.tf
output "bucket_name" {
  description = "The final, globally unique name of the S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "website_endpoint" {
  description = "The public website endpoint URL for the bucket."
  value       = aws_s3_bucket_website_configuration.this.website_endpoint
}