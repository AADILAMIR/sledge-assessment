resource "aws_cloudwatch_log_group" "service" {
  for_each = var.services

  name              = "/ecs/${local.name_prefix}-${each.key}"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "main" {
  name = local.name_prefix

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

resource "aws_ecs_task_definition" "service" {
  for_each = var.services

  family                   = "${local.name_prefix}-${each.key}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(each.value.cpu)
  memory                   = tostring(each.value.memory)
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.app_task[each.key].arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = local.resolved_container_images[each.key]
      essential = true
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = local.aws_region
        },
        {
          name  = "PORT"
          value = tostring(each.value.port)
        },
        {
          name  = "APP_SECRET_ARN"
          value = var.secret_arns[each.key]
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service[each.key].name
          awslogs-region        = local.aws_region
          awslogs-stream-prefix = each.key
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  for_each = var.services

  name            = "${local.name_prefix}-${each.key}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = 0
  launch_type     = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups[each.key].arn
    container_name   = each.key
    container_port   = each.value.port
  }

  depends_on = [module.alb]

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = {
    Name = "${local.name_prefix}-${each.key}"
  }
}
