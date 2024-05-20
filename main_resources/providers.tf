terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
  backend "s3" {
    bucket         = "aevi-test-remote-backend"
    key            = "state-file/test.tfstate"
    region         = "us-east-1"
    profile        = "account_1_profile"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
  required_version = "~> 1.8.3"
}

provider "aws" {
  region = var.region
  profile = "account_A_profile" # Add the named profile for this first account
}
provider "aws" {
  alias  = "remote"
  region = var.region
  profile = "account_B_profile" # Add the named profile for this second account
}

# to get all AZs in the region
data "aws_availability_zones" "available" {}
