data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    sid     = "EcsTasksAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${local.name_prefix}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "${local.name_prefix}-ecs-execution"
  }
}

data "aws_iam_policy_document" "ecs_execution" {
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPullOwnRepos"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = values(var.ecr_repository_arns)
  }

  statement {
    sid    = "WriteTaskLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      for name in keys(var.services) :
      "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:/ecs/${local.name_prefix}-${name}:*"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_execution" {
  name   = "${local.name_prefix}-ecs-execution"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution.json
}

resource "aws_iam_role" "app_task" {
  for_each = var.services

  name               = "${local.name_prefix}-${each.key}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "${local.name_prefix}-${each.key}-task"
    app  = each.key
  }
}

data "aws_iam_policy_document" "app_task" {
  for_each = var.services

  statement {
    sid       = "ReadPrivateObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${local.bucket_arn}/*"]
  }

  statement {
    sid    = "ReadOwnSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [var.secret_arns[each.key]]
  }
}

resource "aws_iam_role_policy" "app_task" {
  for_each = var.services

  name   = "${local.name_prefix}-${each.key}-task"
  role   = aws_iam_role.app_task[each.key].id
  policy = data.aws_iam_policy_document.app_task[each.key].json
}
