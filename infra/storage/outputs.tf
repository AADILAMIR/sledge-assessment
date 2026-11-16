output "environment" {
  value = local.environment
}

output "bucket_id" {
  value = module.app_bucket.s3_bucket_id
}

output "bucket_arn" {
  value = module.app_bucket.s3_bucket_arn
}

output "secret_arns" {
  description = "Secrets Manager ARNs keyed by service name"
  value       = { for k, s in aws_secretsmanager_secret.service : k => s.arn }
}

output "secret_names" {
  description = "Secrets Manager names keyed by service name"
  value       = { for k, s in aws_secretsmanager_secret.service : k => s.name }
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs keyed by service name"
  value       = { for k, m in module.ecr : k => m.repository_arn }
}

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by service name"
  value       = { for k, m in module.ecr : k => m.repository_url }
}

output "ecr_repository_names" {
  description = "ECR repository names keyed by service name"
  value       = { for k, _ in var.services : k => "${k}-registry-${local.environment}" }
}
