# Specify Terraform required providers and version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98"  # Match your installed provider version
    }
  }
  required_version = ">= 1.12.1"
}

# Configure AWS Provider (set your region here)
provider "aws" {
  region = "us-east-1"
}

# Create an IAM user
resource "aws_iam_user" "my_user" {
  name = "terraform-user"
  path = "/"
  tags = {
    "CreatedBy" = "Terraform"
  }
}
