terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98"
    }
  }
  required_version = ">= 1.12.1"
}

provider "aws" {
  region = "us-east-1"
}

# Read the users.txt file and split by new line into a list
locals {
  users_raw = split("\n", file("${path.module}/users.txt"))

  # Trim whitespace characters including \r and \n by specifying cutset
  users_list = [for u in local.users_raw : trim(u, "\r\n\t ") if length(trim(u, "\r\n\t ")) > 0]
}


# Create an IAM user resource for each username in users_list
resource "aws_iam_user" "bulk_users" {
  for_each = { for username in local.users_list : username => username }

  name = each.key
  path = "/"
  tags = {
    CreatedBy = "Terraform"
  }
}
