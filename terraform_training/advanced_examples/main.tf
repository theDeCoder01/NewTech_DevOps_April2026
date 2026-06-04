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

#count example
variable "server_count" {
  description = "Number of identical instances to create"
  type        = number
  default     = 3
}

resource "aws_instance" "web" {
  count         = var.server_count
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "terraform-training"
  }
}

# for_each example

variable "team_members" {
  type    = list(string)
  default = ["alice", "bob", "john"]
}

resource "aws_iam_user" "engineers" {
  # Convert the list to a set so Terraform tracks them by name, not index
  for_each = toset(var.team_members)
  
  # each.key and each.value are identical when using a set of strings
  name = each.value 
}

# For example:

# Here, we are not creating resources. We are taking the complex output of the for_each block above (which returns a massive map of objects) and using a for loop to extract exactly what we need into a clean, flat list.

output "all_user_arns" {
  description = "Extract just the ARNs from the created IAM users"
  
  # Loop over the map of user objects and return a list of their ARNs
  value = [for user in aws_iam_user.engineers : user.arn]
}