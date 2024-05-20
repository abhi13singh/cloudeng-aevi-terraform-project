terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
  required_version = "~> 1.8.3"
}
provider "aws" {
  region = "us-east-1"
  profile = "account_1_profile"
}

# Define S3 bucket for storing terraform state file, enable versioning and server side encryption
# and create a folder inside the bucket
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "aevi-test-remote-backend"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Backend-Bucket"
    Environment = "test"
  }
}

resource "aws_s3_object" "backend_bucket_folder" {
  bucket  = module.s3_bucket.s3_bucket_id
  key     = "state-file/"
  content = ""
}

output "s3_bucket_id" {
  value = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}


# Define the DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}