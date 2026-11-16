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

variable "alb_arn_suffix" {
  description = "ALB arn_suffix from the core module"
  type        = string
}

variable "target_group_arn_suffixes" {
  description = "Target group arn_suffix values keyed by service name"
  type        = map(string)
}
