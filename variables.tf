# variables.tf
variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket name. A random suffix will be added to ensure uniqueness."
  
  validation {
    condition     = length(var.bucket_prefix) > 3 && length(var.bucket_prefix) < 50
    error_message = "The bucket prefix must be between 4 and 49 characters."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the bucket (e.g., { project = \"demo\", env = \"dev\" })."
  default     = {}
}