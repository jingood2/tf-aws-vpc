################################################################################
# VPC Module 
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19"

  # VPC Basic Details
  name                    = "${local.name}-${var.vpc_name}"
  cidr                    = var.vpc_cidr_block
  azs                     = var.vpc_availability_zones
  public_subnets          = var.vpc_public_subnets
  private_subnets         = var.vpc_private_subnets
  map_public_ip_on_launch = false

  # Database Subnets
  database_subnets                   = var.vpc_database_subnets
  create_database_subnet_group       = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  # create_database_internet_gateway_route = true
  # create_database_nat_gateway_route = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
  }

  private_subnet_tags = {
    Type = "Private Subnets"
  }
  database_subnet_tags = {
    Type = "Private Database Subnets"
  }
}

################################################################################
# VPC Endpoint Module
################################################################################
module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"
  create = false

  vpc_id = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]
  
  tags     = local.common_tags

  timeouts = {
  }

  endpoints = {
    # Gateway Endpoint Example
    s3 = {
      service = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([module.vpc.private_route_table_ids])
      policy = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags    = { Name = "${local.name}-s3-gw-endpoint" }
    },

    # Interface Endpoint Example
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags    = { Name = "${local.name}-ecr-ekr-if-endpoint" }
    },
  }
}

################################################################################
# Supporting Resources
################################################################################

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

/* data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [module.vpc.vpc_id]
    }
  }
} */


# vpc가 아니면 모든 principals의 모든 permission을 deny
data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "${local.name}-vpc_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = module.vpc.vpc_id

  ingress = [ {
    cidr_blocks = [ module.vpc.vpc_cidr_block ]
    from_port = 443
    protocol = "tcp"
    #security_groups = [ "value" ]
    to_port = 443
  } ]

  tags = local.common_tags
  
}
