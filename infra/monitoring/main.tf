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
  environment = terraform.workspace
  aws_region  = var.aws_region_by_environment[local.environment]
  name_prefix = "${var.project_name}-${local.environment}"

  alb_name = "${local.name_prefix}-alb"

  alb_arn_suffix = var.alb_arn_suffix

  tags = {
    Environment = local.environment
    Product     = var.project_name
    ManagedBy   = "terraform"
    Layer       = "monitoring"
  }
}
