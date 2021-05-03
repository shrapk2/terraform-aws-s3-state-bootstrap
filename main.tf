# Bootstrap a Terraform environment using AWS S3 as the Terraform state backend.

# This is a standalone provider to keep the Terraform state data outside of the infrastructure state.
#  This helps ensure removal of the infrastructure doesn't remove the Terraform state data.

## You must specify the following environment variables
# export AWS_ACCESS_KEY_ID="anaccesskey"
# export AWS_SECRET_ACCESS_KEY="asecretkey"
# export AWS_DEFAULT_REGION="us-yee-ha"

terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}


## Create S3 Bucket and Dynamo Database
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  acl    = "private"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Little too much reach, but worth mentioning
# resource "aws_s3_account_public_access_block" "all_s3" {
#   block_public_acls   = true
#   block_public_policy = true
# }

resource "aws_s3_bucket_public_access_block" "terraform_s3" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_object" "s3_key" {
  key                    = "terraform.tfstate"
  bucket                 = aws_s3_bucket.terraform_state.id
  server_side_encryption = "AES256"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamo_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "time_sleep" "s3_sleeper_1" {
  create_duration = "45s"
  triggers = {
    s3_policy = aws_s3_bucket_public_access_block.terraform_s3.id
  }
}

resource "time_sleep" "s3_sleeper_2" {
  create_duration = "45s"
  triggers = {
    s3_key = aws_s3_bucket_object.s3_key.id
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = <<POLICY
{
  "Id": "TerraformProtectionPolicy",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "s3:DeleteBucket"
      ],
      "Resource": "${aws_s3_bucket.terraform_state.arn}",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "role_tf_admins" {
  name = var.tf_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Sid": ""
    }
  ]
}
EOF

  tags = var.asset_tags
}

data "aws_caller_identity" "current_session" {}
