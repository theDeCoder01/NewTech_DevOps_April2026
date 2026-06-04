terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "devopsclassapril26"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

# Fetch all subnets that belong to the VPC above.
# We'll use the first one as the subnet for the EC2 instance.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Call the SecurityGroup module.
# This creates the SG resource and exposes its ID as an output
# that other modules (like EC2) can reference.
module "security_group" {
  source = "../SecurityGroup_Module"

  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = data.aws_vpc.default.id
}

# Call the EC2 module.
# subnet_id is taken from the data source above ([0] picks the first subnet).
# security_group_id is the output from the security_group module above —
# this is the key link that attaches the SG to the instance.
module "ec2" {
  source = "../EC2 Module"

  ami               = var.ami
  instance_type     = var.instance_type
  name              = var.project_name
  subnet_id         = data.aws_subnets.default.ids[0]
  security_group_id = module.security_group.security_group_id
}

