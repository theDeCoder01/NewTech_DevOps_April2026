# Outputs expose values from this module so other modules or the root config can use them.
# For example, the EC2 module can reference this SG ID to attach it to an instance.

output "security_group_id" {
  value       = aws_security_group.this.id # The unique AWS-generated ID (e.g. sg-0abc1234)
  description = "The ID of the security group"
}

output "security_group_name" {
  value       = aws_security_group.this.name # The name we gave it via var.name
  description = "The name of the security group"
}
