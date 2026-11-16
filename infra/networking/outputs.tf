output "environment" {
  value = local.environment
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "ALB subnets only"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "ECS task subnets (no public IPs)"
  value       = module.vpc.private_subnets
}

output "alb_security_group_id" {
  value = module.alb_sg.security_group_id
}

output "ecs_security_group_id" {
  value = module.ecs_sg.security_group_id
}

output "service_ports" {
  description = "Distinct container ports allowed ALB → ECS"
  value       = [for p in local.service_ports : tonumber(p)]
}
