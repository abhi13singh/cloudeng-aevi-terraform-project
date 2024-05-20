# Define S3 bucket for storing files like our app project environment files, enable versioning and server side encryption
# and create a folder inside the bucket
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "${var.project}-${var.environment}-env-file-bucket"

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

resource "aws_s3_object" "env_files_folder" {
  bucket  = module.s3_bucket.s3_bucket_id
  key     = "env-files/"
  content = ""
}