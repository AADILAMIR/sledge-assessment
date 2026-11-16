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
  description = "Services map from the root module; drives per-service ECR and secrets"
  type = map(object({
    port         = number
    path_pattern = string
    health_path  = string
    priority     = number
    cpu          = number
    memory       = number
  }))
}
