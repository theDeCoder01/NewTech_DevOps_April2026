resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type

  # Place the instance in a public subnet so it can be reached from the internet.
  # This value comes from the VPC module's public_subnet_ids output.
  subnet_id = var.subnet_id

  # Attach the security group created by the SecurityGroup module.
  # vpc_security_group_ids expects a list, so we wrap the single ID in brackets.
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = var.name # The instance's display name in the AWS console comes from this tag
  }
}