data "aws_availability_zones" "available" {}

locals {
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
  name = "vpc-dev"
  cidr = "10.0.0.0/16"
}

output "azs" {
  value = { for k, v in local.azs : "${k}" => "${v}" }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = local.name # vpc-dev
  cidr = local.cidr # 10.0.0.0/16
  azs  = local.azs  # ["us-east-1a", "us-east-1b"]

  private_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 100)]

  private_subnet_names = [for k, v in local.azs : "private-subnet-${v}"]
  public_subnet_names  = [for k, v in local.azs : "public-subnet-${v}"]

  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  database_subnets                   = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 200)]
  database_subnet_names              = [for k, v in local.azs : "db-subnet-${v}"]



  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name = "public-subnet"
  }

  private_subnet_tags = {
    Name = "private-subnet"

  }

  database_subnet_tags = {
    Name = "database-subnet"
  }

  tags = {
    Owner = "Nilanjan"
    Env   = "DEV"
  }

  vpc_tags = {
    Name = "VPC-DEV"
  }


}

