# Generic Variables
aws_region  = "ap-northeast-2"
environment = "stage"
division    = "jingood2"

##########

# VPC Variables
vpc_name                               = "vpc"
vpc_cidr_block                         = "10.3.0.0/16"
vpc_availability_zones                 = ["ap-northeast-2a", "ap-northeast-2c"]
vpc_public_subnets                     = ["10.3.101.0/24", "10.3.102.0/24"]
vpc_private_subnets                    = ["10.3.1.0/24", "10.3.2.0/24"]
vpc_database_subnets                   = ["10.3.151.0/24", "10.3.152.0/24"]
vpc_create_database_subnet_group       = false
vpc_create_database_subnet_route_table = false
vpc_enable_nat_gateway                 = true
vpc_single_nat_gateway                 = true
