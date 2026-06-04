variable "region" {
  type        = string
  description = "The region to deploy the resources"
  default     = "eu-central-1"
}

variable "project_name" {
  type        = string
  description = "Name prefix applied to all resources in this project"
  default     = "mini-project"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the security group will be created"
}

variable "ami" {
  type        = string
  description = "The AMI to deploy the resources"
  default     = "ami-036bdae36143a955f"
}

variable "instance_type" {
  type        = string
  description = "The instance type to deploy the resources"
  default     = "t3.micro"
}