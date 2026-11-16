output "environment" {
  value = local.environment
}

output "service_5xx_alarm_names" {
  description = "5xx alarm names keyed by service"
  value       = { for k, a in aws_cloudwatch_metric_alarm.target_5xx : k => a.alarm_name }
}

output "ops_sns_topic_arn" {
  value = aws_sns_topic.ops.arn
}
