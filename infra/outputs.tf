output "alb_dns_name" {
  value = module.core.alb_dns_name
}

output "deploy_role_arn" {
  value = module.core.deploy_role_arn
}

output "ecs_cluster_name" {
  value = module.core.ecs_cluster_name
}

output "ecs_service_names" {
  value = module.core.ecs_service_names
}

output "ecr_repository_names" {
  value = module.storage.ecr_repository_names
}

output "secret_arns" {
  value = module.storage.secret_arns
}

output "app_task_role_arns" {
  value = module.core.app_task_role_arns
}

output "service_5xx_alarm_names" {
  value = module.monitoring.service_5xx_alarm_names
}

output "ecs_service_name" {
  value = module.core.ecs_service_name
}

output "ecr_repository_name" {
  value = module.storage.ecr_repository_names[module.core.default_service_key]
}

output "api_5xx_alarm_name" {
  value = module.monitoring.service_5xx_alarm_names[module.core.default_service_key]
}
