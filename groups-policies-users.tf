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

# Load S3 group users
locals {
  s3_users_raw = split("\n", file("${path.module}/group1-users.txt"))
  s3_users     = [for u in local.s3_users_raw : trim(u, "\r\n\t ") if length(trim(u, "\r\n\t ")) > 0]

  ec2_users_raw = split("\n", file("${path.module}/group2-users.txt"))
  ec2_users     = [for u in local.ec2_users_raw : trim(u, "\r\n\t ") if length(trim(u, "\r\n\t ")) > 0]
}

# Create S3 group and attach policy
resource "aws_iam_group" "s3_group" {
  name = "S3ReadOnlyGroup"
}

resource "aws_iam_group_policy_attachment" "s3_readonly" {
  group      = aws_iam_group.s3_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Create EC2 group and attach policy
resource "aws_iam_group" "ec2_group" {
  name = "EC2ReadOnlyGroup"
}

resource "aws_iam_group_policy_attachment" "ec2_readonly" {
  group      = aws_iam_group.ec2_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Create S3 users and assign to group
resource "aws_iam_user" "s3_users" {
  for_each = { for u in local.s3_users : u => u }

  name = each.key
  path = "/"
  tags = {
    Group = "S3"
  }
}

resource "aws_iam_user_group_membership" "s3_group_membership" {
  for_each = aws_iam_user.s3_users

  user = each.key
  groups = [aws_iam_group.s3_group.name]
}

# Create EC2 users and assign to group
resource "aws_iam_user" "ec2_users" {
  for_each = { for u in local.ec2_users : u => u }

  name = each.key
  path = "/"
  tags = {
    Group = "EC2"
  }
}

resource "aws_iam_user_group_membership" "ec2_group_membership" {
  for_each = aws_iam_user.ec2_users

  user = each.key
  groups = [aws_iam_group.ec2_group.name]
}
