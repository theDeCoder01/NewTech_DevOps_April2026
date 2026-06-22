variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. lab, dev, prod)"
  type        = string
  default     = "lab"
}

variable "project_name" {
  description = "Project name used in resource tags"
  type        = string
  default     = "lab4"
}
