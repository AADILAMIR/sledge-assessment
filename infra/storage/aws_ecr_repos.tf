module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  for_each = var.services

  repository_name = "${each.key}-registry-${local.environment}"

  repository_image_tag_mutability = "IMMUTABLE"
  repository_force_delete         = true
  repository_image_scan_on_push   = true

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    app       = each.key
    env       = terraform.workspace
    terraform = "true"
  }
}
