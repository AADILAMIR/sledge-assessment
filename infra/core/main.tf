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

  bucket_arn = var.app_bucket_arn

  default_service_key = one([
    for k, v in var.services : k if v.path_pattern == "/*"
  ])

  resolved_container_images = {
    for name, service in var.services : name => "${var.ecr_repository_urls[name]}:${var.image_tag}"
  }

  github_org  = var.github_org
  github_repo = var.github_repo

  tags = {
    Environment = local.environment
    Product     = var.project_name
    ManagedBy   = "terraform"
    Layer       = "core"
  }
}
