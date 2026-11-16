variable "project_name" {
  description = "Short product name used in resource naming"
  type        = string
  default     = "sledge-api"
}

variable "aws_region" {
  description = "AWS region for this stack"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "HTTP services deployed to ECS"
  type = map(object({
    port         = number
    path_pattern = string
    health_path  = string
    priority     = number
    cpu          = number
    memory       = number
  }))
  default = {
    api = {
      port         = 3000
      path_pattern = "/*"
      health_path  = "/health"
      priority     = 100
      cpu          = 256
      memory       = 512
    }
  }

  validation {
    condition     = length([for service in values(var.services) : service if service.path_pattern == "/*"]) == 1
    error_message = "Exactly one service must use the /* path pattern."
  }

  validation {
    condition = alltrue([
      for service in values(var.services) :
      service.port >= 1 && service.port <= 65535 &&
      service.priority >= 1 && service.priority <= 50000
    ])
    error_message = "Service ports and ALB listener priorities must be within valid ranges."
  }

  validation {
    condition     = length(distinct([for service in values(var.services) : service.priority])) == length(var.services)
    error_message = "Each service must use a unique ALB listener priority."
  }
}

variable "bootstrap_image_tag" {
  description = "Initial task-definition image tag; the service starts at zero tasks until CI deploys a SHA tag"
  type        = string
  default     = "bootstrap"
}

variable "github_org" {
  description = "GitHub organization or user that owns the repository"
  type        = string
  default     = "EXAMPLE_GITHUB_ORG"
}

variable "github_repo" {
  description = "GitHub repository trusted by the deploy role"
  type        = string
  default     = "sledge-assessment"
}
