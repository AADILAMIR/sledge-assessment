variable "project_name" {
  description = "Short product name used in resource naming"
  type        = string
  default     = "sledge-api"
}

variable "aws_region_by_environment" {
  description = "AWS region per Terraform workspace"
  type        = map(string)
  default = {
    dev     = "us-east-1"
    staging = "us-east-1"
    prod    = "us-east-1"
  }
}

variable "aws_account_id_by_environment" {
  description = "AWS account ID per environment, supplied by the root module"
  type        = map(string)
}

variable "services" {
  description = "Services map from the root module"
  type = map(object({
    port         = number
    path_pattern = string
    health_path  = string
    priority     = number
    cpu          = number
    memory       = number
  }))
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs keyed by service name"
  type        = map(string)
}

variable "ecr_repository_urls" {
  description = "ECR repository URLs keyed by service name"
  type        = map(string)
}

variable "image_tag" {
  description = "Image tag pushed by CI (prefer git SHA)"
  type        = string
  default     = "latest"
}

variable "secret_arns" {
  description = "Secrets Manager ARNs keyed by service name"
  type        = map(string)
}

variable "app_bucket_arn" {
  description = "S3 bucket ARN from the storage module"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or user trusted by the deploy OIDC role"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository trusted by the deploy OIDC role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from networking outputs"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB (from networking outputs)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks (from networking outputs)"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB SG ID from networking outputs"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ECS SG ID from networking outputs"
  type        = string
}
