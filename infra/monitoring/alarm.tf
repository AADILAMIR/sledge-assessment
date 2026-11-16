resource "aws_sns_topic" "ops" {
  name = "${local.name_prefix}-ops-alerts"

  tags = {
    Name = "${local.name_prefix}-ops-alerts"
  }
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  for_each = var.target_group_arn_suffixes

  alarm_name          = "${local.name_prefix}-${each.key}-target-5xx"
  alarm_description   = "ALB target 5xx errors for ${each.key} on ${local.alb_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
    TargetGroup  = each.value
  }

  alarm_actions = [aws_sns_topic.ops.arn]
  ok_actions    = [aws_sns_topic.ops.arn]

  tags = {
    Name = "${local.name_prefix}-${each.key}-target-5xx"
    app  = each.key
  }
}
