project_name        = "sledge-api"
aws_region          = "us-east-1"
bootstrap_image_tag = "bootstrap"
github_org          = "EXAMPLE_GITHUB_ORG"
github_repo         = "sledge-assessment"

services = {
  api = {
    port         = 3000
    path_pattern = "/*"
    health_path  = "/health"
    priority     = 100
    cpu          = 256
    memory       = 512
  }
}
