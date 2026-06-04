# Outputs let other modules or your root config consume values from this module.

output "bucket_name" {
  value       = aws_s3_bucket.this.bucket # The actual bucket name (same as var.bucket_name)
  description = "The name of the S3 bucket"
}

output "bucket_arn" {
  # ARN = Amazon Resource Name, a unique identifier used in IAM policies
  # e.g. arn:aws:s3:::my-bucket-name
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the S3 bucket"
}

output "bucket_id" {
  # For S3, the ID is the same as the bucket name — useful for linking sub-resources
  value       = aws_s3_bucket.this.id
  description = "The ID of the S3 bucket"
}
