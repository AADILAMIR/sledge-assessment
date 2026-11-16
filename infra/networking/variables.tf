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

variable "vpc_cidr_by_environment" {
  description = "VPC CIDR per environment"
  type        = map(string)
  default = {
    dev     = "10.20.0.0/16"
    staging = "10.30.0.0/16"
    prod    = "10.40.0.0/16"
  }
}

variable "public_subnet_cidrs_by_environment" {
  description = "Public subnet CIDRs (ALB only) per environment"
  type        = map(list(string))
  default = {
    dev     = ["10.20.1.0/24", "10.20.2.0/24"]
    staging = ["10.30.1.0/24", "10.30.2.0/24"]
    prod    = ["10.40.1.0/24", "10.40.2.0/24"]
  }
}

variable "private_subnet_cidrs_by_environment" {
  description = "Private subnet CIDRs (ECS tasks) per environment"
  type        = map(list(string))
  default = {
    dev     = ["10.20.11.0/24", "10.20.12.0/24"]
    staging = ["10.30.11.0/24", "10.30.12.0/24"]
    prod    = ["10.40.11.0/24", "10.40.12.0/24"]
  }
}

variable "availability_zones_by_environment" {
  description = "Two AZs per environment"
  type        = map(list(string))
  default = {
    dev     = ["us-east-1a", "us-east-1b"]
    staging = ["us-east-1a", "us-east-1b"]
    prod    = ["us-east-1a", "us-east-1b"]
  }
}

variable "single_nat_gateway_by_environment" {
  description = "Use one shared NAT (cheaper) vs one NAT per AZ (HA)"
  type        = map(bool)
  default = {
    dev     = true
    staging = true
    prod    = false
  }
}

variable "services" {
  description = "Services map; SG rules allow the distinct container ports"
  type = map(object({
    port         = number
    path_pattern = string
    health_path  = string
    priority     = number
    cpu          = number
    memory       = number
  }))
}
