output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.app_storage.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.app_storage.arn
}

output "bucket_region" {
  description = "AWS region where the bucket was created"
  value       = aws_s3_bucket.app_storage.region
}
