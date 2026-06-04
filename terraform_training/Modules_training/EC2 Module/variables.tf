variable "region" {
  type        = string
  description = "The region to deploy the resources"
  default     = "us-east-1"
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

variable "name" {
  type        = string
  description = "The name to deploy the resources"
  default     = "terraform-training"
}

# The ID of the subnet (from the VPC module) where the instance will be launched.
# Using a public subnet allows the instance to receive a public IP.
variable "subnet_id" {
  type        = string
  description = "The subnet ID in which to launch the EC2 instance"
}

# The security group ID created by the SecurityGroup module.
# Passed in as a list item to vpc_security_group_ids on the aws_instance resource.
variable "security_group_id" {
  type        = string
  description = "The ID of the security group to attach to the EC2 instance"
}