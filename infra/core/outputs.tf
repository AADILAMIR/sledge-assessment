output "environment" {
  value = local.environment
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

output "alb_arn_suffix" {
  value = module.alb.arn_suffix
}

output "default_service_key" {
  description = "Catch-all service (path_pattern /*) used as the ALB default target"
  value       = local.default_service_key
}

output "target_group_arn_suffixes" {
  description = "ALB target group arn_suffix values keyed by service name"
  value       = { for k, tg in module.alb.target_groups : k => tg.arn_suffix }
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_names" {
  description = "ECS service names keyed by service map key"
  value       = { for k, s in aws_ecs_service.service : k => s.name }
}

output "ecr_image_uris" {
  description = "Resolved bootstrap image URIs keyed by service name"
  value       = local.resolved_container_images
}

output "app_task_role_arns" {
  description = "Per-service task role ARNs"
  value       = { for k, r in aws_iam_role.app_task : k => r.arn }
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "deploy_role_arn" {
  description = "GitHub Actions OIDC deploy role ARN"
  value       = aws_iam_role.deploy.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.service[local.default_service_key].name
}

output "target_group_arn_suffix" {
  value = module.alb.target_groups[local.default_service_key].arn_suffix
}
