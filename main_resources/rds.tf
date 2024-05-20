provider "aws" {
  alias  = "remote"
  profile = "account_2_profile" # this is another AWS account where a RDS DB will be running
  region = var.region  # the region is same as that of ECS cluster
}

data "aws_availability_zones" "available" {}

locals {
  name   = "aevi-rds-instance"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Name       = local.name
    Example    = local.name
  }
}

# creating a VPC and subnets in this AWS account to launch a RDS DB
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  tags = local.tags
}

# creating a security group for the DB Instance
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "the db instance security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "the rds db access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

# get information about a database snapshot, assuming in this AWS account we have a snapshot from an existing DB which we are migrating here
data "aws_db_snapshot" "latest_db_snapshot" {
  db_snapshot_identifier = var.db_snapshot_identifier
  most_recent            = true
  snapshot_type          = "manual"
}

# launch an rds instance from the database snapshot
resource "aws_db_instance" "database_instance" {
  instance_class         = var.db_instance_class
  skip_final_snapshot    = false
  availability_zone      = data.aws_availability_zones.available.names[1]
  identifier             = var.db_instance_identifier # same identifier name as used to create db instance whose snapshot we use here
  snapshot_identifier    = data.aws_db_snapshot.latest_db_snapshot.id
  db_subnet_group_name   = module.vpc.database_subnet_group
  multi_az               = true # to create a redundant standby DB instance in another AZ
  vpc_security_group_ids = [module.security_group.security_group_id]
}

