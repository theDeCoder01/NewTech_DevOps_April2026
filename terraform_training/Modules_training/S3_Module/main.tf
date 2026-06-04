# Create the S3 bucket itself — this is the core resource
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name # Bucket names must be globally unique across ALL AWS accounts

  tags = {
    Name = var.bucket_name
  }
}

# Versioning keeps a history of every object version in the bucket.
# This lets you recover files that were accidentally deleted or overwritten.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id # Reference the bucket we created above

  versioning_configuration {
    # Ternary expression: if var.versioning_enabled is true → "Enabled", else → "Suspended"
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Server-Side Encryption (SSE) — AWS automatically encrypts every object at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # AES-256 is AWS's built-in managed key encryption (free)
                               # Alternative: "aws:kms" uses your own KMS key
    }
  }
}

# Block ALL public access to this bucket — security best practice for most use cases.
# Each setting covers a different way the public could accidentally gain access.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true # Ignore any ACL that grants public access
  block_public_policy     = true # Reject any bucket policy that grants public access
  ignore_public_acls      = true # Ignore existing public ACLs already on objects
  restrict_public_buckets = true # Prevent cross-account access via policies
}
