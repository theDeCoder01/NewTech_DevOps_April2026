# S3 bucket names are globally unique — no two buckets in the world can share a name.
# There is no default here, so the caller MUST provide a value.
variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket (must be globally unique)"
}

# Toggle versioning on or off. Defaults to true (recommended for production).
# Set to false to save storage costs in dev/test environments.
variable "versioning_enabled" {
  type        = bool
  description = "Whether to enable versioning on the S3 bucket"
  default     = true
}
