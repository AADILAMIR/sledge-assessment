terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  environment    = terraform.workspace
  aws_region     = var.aws_region_by_environment[local.environment]
  aws_account_id = var.aws_account_id_by_environment[local.environment]
  name_prefix    = "${var.project_name}-${local.environment}"

  bucket_name = "${var.project_name}-files-${local.environment}-${local.aws_account_id}"

  tags = {
    Environment = local.environment
    Product     = var.project_name
    ManagedBy   = "terraform"
    Layer       = "storage"
  }
}
