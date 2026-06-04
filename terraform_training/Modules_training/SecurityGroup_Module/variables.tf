# The display name for the security group
variable "name" {
  type        = string
  description = "Name of the security group"
  default     = "terraform-sg"
}

# A short note describing what this SG is used for
variable "description" {
  type        = string
  description = "Description of the security group"
  default     = "Managed by Terraform"
}

# Required — the SG must live inside a VPC, so we need its ID
# No default means the caller MUST supply this value
variable "vpc_id" {
  type        = string
  description = "The VPC ID where the security group will be created"
}

# A list of inbound traffic rules. Each rule is an object with 4 fields.
# Using a list lets us add/remove rules without changing the resource block.
variable "ingress_rules" {
  type = list(object({
    from_port   = number       # First port in the allowed range
    to_port     = number       # Last port in the allowed range
    protocol    = string       # "tcp" or "udp" (use "-1" for all)
    cidr_blocks = list(string) # List of allowed source IP ranges
  }))
  description = "List of ingress rules"
  # Default opens HTTP (80), HTTPS (443), and SSH (22) from anywhere
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Open to the entire internet
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # In production, restrict this to your IP!
    }
  ]
}
