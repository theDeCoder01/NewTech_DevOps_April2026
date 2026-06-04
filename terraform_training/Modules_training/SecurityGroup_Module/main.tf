# Create an AWS Security Group — acts as a virtual firewall for your resources
resource "aws_security_group" "this" {
  name        = var.name        # The name that will appear in the AWS console
  description = var.description # Human-readable note about the SG's purpose
  vpc_id      = var.vpc_id      # Attach this SG to a specific VPC

  # "dynamic" lets us create multiple ingress blocks from a list,
  # instead of hardcoding one block per rule
  dynamic "ingress" {
    for_each = var.ingress_rules # Loop over each rule object in the list
    content {
      from_port   = ingress.value.from_port   # Start of the port range to allow
      to_port     = ingress.value.to_port     # End of the port range to allow
      protocol    = ingress.value.protocol    # "tcp", "udp", or "-1" for all
      cidr_blocks = ingress.value.cidr_blocks # IP ranges allowed (e.g. 0.0.0.0/0 = anywhere)
    }
  }

  # Egress = outbound traffic. Allow ALL outbound by default (best practice)
  egress {
    from_port   = 0             # 0 means any port
    to_port     = 0             # 0 means any port
    protocol    = "-1"          # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound to any IP
  }

  tags = {
    Name = var.name # Tag the SG so it's easy to identify in the AWS console
  }
}
