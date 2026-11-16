resource "aws_secretsmanager_secret" "service" {
  for_each = var.services

  name                    = "${var.project_name}/${local.environment}/${each.key}"
  description             = "Runtime secrets for ${each.key} (${local.environment})"
  recovery_window_in_days = 0

  tags = {
    Name      = "${local.name_prefix}-${each.key}-secret"
    app       = each.key
    env       = local.environment
    terraform = "true"
  }
}

resource "aws_secretsmanager_secret_version" "service" {
  for_each = var.services

  secret_id = aws_secretsmanager_secret.service[each.key].id
  secret_string = jsonencode({
    bucketName = module.app_bucket.s3_bucket_id
    apiKey     = "REPLACE_ME_OUT_OF_BAND"
    service    = each.key
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
