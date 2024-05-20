variable "region" {
  type        = "string"
  description = "name of the region"
  default     = "us-east-1"
}

variable "project" {
  description = "name of the project"
  type        = string
  default     = "aevi-terraform"
}

variable "environment" {
  description = "The environment that is being built"
  type        = string
  default     = "test"
}

# vpc variables of main AWS account of the app ECS cluster
variable "vpc_cidr" {
  type        = string
  description = "This defines the size of the vpc"
  default     = "172.20.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["172.20.1.0/24", "172.20.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["172.20.3.0/24", "172.20.4.0/24"]
}

# rds variables
variable "db_snapshot_identifier" {
  description = "database snapshot name "
  type        = string
  default     = "aevi-db-snapshot"
}

variable "db_instance_class" {
  description = "database instance type "
  type        = string
  default     = "db.t4g.large"
}

variable "db_instance_identifier" {
  description = "database instance name"
  type        = string
  default     = "dev-rds-db"
}

# acm variables
variable "domain_name" {
  description = "domain name"
  type        = string
  default     = "cloudengaevi05.com"
}

variable "alternative_names" {
  description = "sub domain name"
  type        = string
  default     = "*.cloudengaevi05.com"
}

# ecs variables
variable "architecture" {
  description = "ecs cpu architecture"
  type        = string
  default     = "ARM64"
}

variable "conatainer_image" {
  description = "container image URI"
  type        = string
  default     = "651783246143.dkr.ecr.us-east-1.amazonaws.com/aevi-terraform"
}

# route53 variables
variable "record_name" {
  description = "sub domain name"
  type        = string
  default     = "WWW"
}

# cross account vpc peering variables
variable "b_vpc_id" {
  description = "vpc id of the peer VPC in AWS account B"
  type        = string
}

variable "b_owner_id" {
  description = "AWS Account id of the AWS account B"
  type        = string
}

variable "b_vpc_cidr" {
  type        = string
  description = "This defines the size of the vpc in Account B"
  default     = "10.0.0.0/16"
}

