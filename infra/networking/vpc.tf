module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr_by_environment[local.environment]

  azs             = var.availability_zones_by_environment[local.environment]
  public_subnets  = var.public_subnet_cidrs_by_environment[local.environment]
  private_subnets = var.private_subnet_cidrs_by_environment[local.environment]

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway_by_environment[local.environment]
  one_nat_gateway_per_az = !var.single_nat_gateway_by_environment[local.environment]
  enable_dns_hostnames   = true
  enable_dns_support     = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    Tier = "public"
    Role = "load-balancer"
  }

  private_subnet_tags = {
    Tier = "private"
    Role = "ecs"
  }

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${local.name_prefix}-s3-endpoint"
      }
    }

    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.vpc_endpoints_sg.security_group_id]
      tags = {
        Name = "${local.name_prefix}-secretsmanager-endpoint"
      }
    }

    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.vpc_endpoints_sg.security_group_id]
      tags = {
        Name = "${local.name_prefix}-logs-endpoint"
      }
    }

    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.vpc_endpoints_sg.security_group_id]
      tags = {
        Name = "${local.name_prefix}-ecr-api-endpoint"
      }
    }

    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.vpc_endpoints_sg.security_group_id]
      tags = {
        Name = "${local.name_prefix}-ecr-dkr-endpoint"
      }
    }
  }

  tags = {
    Name = "${local.name_prefix}-vpc-endpoints"
  }
}

module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name            = "${local.name_prefix}-vpce"
  use_name_prefix = false
  description     = "Interface VPC endpoints — HTTPS from private ECS only"
  vpc_id          = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "HTTPS from ECS tasks"
      source_security_group_id = module.ecs_sg.security_group_id
    },
  ]

  egress_rules = ["https-443-tcp"]

  tags = {
    Name = "${local.name_prefix}-vpce-sg"
  }
}
