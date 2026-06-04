# Used as a prefix for naming all resources created by this module (VPC, subnets, IGW, etc.)
variable "name" {
  type        = string
  description = "Name prefix for all VPC resources"
  default     = "terraform-vpc"
}

# The IP range for the entire VPC. /16 gives you 65,536 possible IP addresses.
# Subnets carve out smaller slices from this range.
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Each string in this list creates one public subnet with that IP range.
# /24 gives each subnet 256 addresses (251 usable — AWS reserves 5).
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# The number of AZs here must match the number of subnet CIDRs above.
# Spreading across AZs ensures your app stays up if one data center fails (High Availability).
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the subnets"
  default     = ["eu-central-1a", "eu-central-1b"]
}
