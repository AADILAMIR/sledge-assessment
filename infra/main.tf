terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  environment = terraform.workspace
  account_id  = data.aws_caller_identity.current.account_id
  account_ids = {
    dev     = local.account_id
    staging = local.account_id
    prod    = local.account_id
  }
  tags = {
    Environment = local.environment
    Product     = var.project_name
    ManagedBy   = "terraform"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

module "networking" {
  source = "./networking"

  project_name = var.project_name
  services     = var.services
}

module "storage" {
  source = "./storage"

  project_name                  = var.project_name
  aws_account_id_by_environment = local.account_ids
  services                      = var.services
}

module "core" {
  source = "./core"

  project_name                  = var.project_name
  image_tag                     = var.bootstrap_image_tag
  aws_account_id_by_environment = local.account_ids
  github_org                    = var.github_org
  github_repo                   = var.github_repo
  services                      = var.services

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  app_bucket_arn      = module.storage.bucket_arn
  secret_arns         = module.storage.secret_arns
  ecr_repository_arns = module.storage.ecr_repository_arns
  ecr_repository_urls = module.storage.ecr_repository_urls
}

module "monitoring" {
  source = "./monitoring"

  project_name              = var.project_name
  alb_arn_suffix            = module.core.alb_arn_suffix
  target_group_arn_suffixes = module.core.target_group_arn_suffixes
}
