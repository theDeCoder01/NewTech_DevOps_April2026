# Outputs expose key values so other modules can reference this VPC's resources.
# For example, the EC2 and Security Group modules both need the vpc_id.

output "vpc_id" {
  value       = aws_vpc.this.id # The AWS-generated ID (e.g. vpc-0abc1234)
  description = "The ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block # The IP range of the VPC (e.g. 10.0.0.0/16)
  description = "The CIDR block of the VPC"
}

output "public_subnet_ids" {
  # The [*] is a splat expression — it collects the "id" attribute from every subnet in the list
  value       = aws_subnet.public[*].id
  description = "The IDs of the public subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id # Useful if you need to reference the IGW elsewhere
  description = "The ID of the internet gateway"
}
