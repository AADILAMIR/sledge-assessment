locals {
  service_ports = toset([for _, svc in var.services : tostring(svc.port)])
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name            = "${local.name_prefix}-alb"
  use_name_prefix = false
  description     = "Internet-facing ALB — HTTP(S) in, app ports out to ECS only"
  vpc_id          = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP ingress"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS ingress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    for port in local.service_ports : {
      from_port   = tonumber(port)
      to_port     = tonumber(port)
      protocol    = "tcp"
      description = "Forward to private ECS tasks on ${port}"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name            = "${local.name_prefix}-ecs"
  use_name_prefix = false
  description     = "Private ECS tasks — only ALB may connect on service ports"
  vpc_id          = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    for port in local.service_ports : {
      from_port                = tonumber(port)
      to_port                  = tonumber(port)
      protocol                 = "tcp"
      description              = "App port ${port} from ALB only"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS egress via NAT or VPC endpoints"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = "${local.name_prefix}-ecs-sg"
  }
}
