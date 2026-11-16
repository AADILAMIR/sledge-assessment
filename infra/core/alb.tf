module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_security_group_id]

  create_security_group = false

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = local.default_service_key
      }
      rules = {
        for name, svc in var.services : name => {
          priority = svc.priority
          actions = [
            {
              type             = "forward"
              target_group_key = name
            }
          ]
          conditions = [
            {
              path_pattern = {
                values = [svc.path_pattern]
              }
            }
          ]
        }
        if svc.path_pattern != "/*"
      }
    }
  }

  target_groups = {
    for name, svc in var.services : name => {
      name_prefix       = "${substr(name, 0, 3)}-"
      protocol          = "HTTP"
      port              = svc.port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = svc.health_path
        protocol            = "HTTP"
        matcher             = "200"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 30
        timeout             = 5
      }
    }
  }

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}
