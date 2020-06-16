provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "jmc-terraform-up-and-running-state"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "jmc-terraform-up-and-running-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

# Can't use variables in backend config, see https://github.com/hashicorp/terraform/issues/13022

# variable "aws_region" {
#   description = "The AWS region that will be used for the s3 bucket and dynamodb"
#   type        = string
#   default     = "us-east-2"
# }

# variable "s3_bucket" {
#   description = "The s3 bucket name for storing state files"
#   type        = string
#   default     = "jmc-terraform-up-and-running-state"
# }

# variable "dynamodb_table" {
#   description = "The dynamodb table name used for locking writes to terraform state files"
#   type        = string
#   default     = "terraform-up-and-running-locks"

# }

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
