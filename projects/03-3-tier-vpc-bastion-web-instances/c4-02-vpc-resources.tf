data "aws_availability_zones" "available" {}

locals {
  azs                      = slice(data.aws_availability_zones.available.names, 0, 2)
  vpc_network_tier_bracket = 100
}

# AWS VPC
resource "aws_vpc" "poc_vpc" {
  cidr_block           = var.vpc_cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }


}

# Public Subnets - WEB Tier
resource "aws_subnet" "poc_web_public_subnet" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_range, 8, count.index)
  availability_zone = local.azs[count.index]

}

# Private Subnets - APP Tier
resource "aws_subnet" "poc_app_private_subnet" {
  count = length(local.azs)

  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_range, 8, count.index + local.vpc_network_tier_bracket)
  availability_zone = local.azs[count.index]

}

# Private Subnets - DB Tier
resource "aws_subnet" "poc_db_private_subnet" {
  count = length(local.azs)

  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_range, 8, count.index + 2 * local.vpc_network_tier_bracket)
  availability_zone = local.azs[count.index]
}

# Internet Gateway
resource "aws_internet_gateway" "poc_vpc_igw" {
  vpc_id = aws_vpc.poc_vpc.id

  tags = local.common_tags

}

# Elastic IP for NAT Gateway

resource "aws_eip" "poc_vpc_ngw_eip" {
  domain = "vpc"

}

# NAT Gateway
resource "aws_nat_gateway" "poc_vpc_ngw" {
  subnet_id     = aws_subnet.poc_web_public_subnet[0].id
  allocation_id = aws_eip.poc_vpc_ngw_eip.id
}



# Public Route Table - WEB Tier
resource "aws_route_table" "poc_vpc_public_rt" {
  vpc_id = aws_vpc.poc_vpc.id

}


# Private Route Table - APP Tier
resource "aws_route_table" "poc_vpc_private_app_rt" {
  vpc_id = aws_vpc.poc_vpc.id

}

# Private Route Table - DB Tier
# resource "aws_route_table" "poc_vpc_private_db_rt" {
#   vpc_id = aws_vpc.poc_vpc.id

# }

# Public Route Table Association
resource "aws_route_table_association" "poc_vpc_public_rt_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.poc_web_public_subnet[count.index].id
  route_table_id = aws_route_table.poc_vpc_public_rt.id

}

# Private Route Table Association - APP Tier
resource "aws_route_table_association" "poc_vpc_private_app_rt_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.poc_app_private_subnet[count.index].id
  route_table_id = aws_route_table.poc_vpc_private_app_rt.id
}

# Private Route Table Association - DB Tier
resource "aws_route_table_association" "poc_vpc_private_db_rt_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.poc_db_private_subnet[count.index].id
  route_table_id = aws_vpc.poc_vpc.default_route_table_id

}

# Public Route
resource "aws_route" "aws_public_route" {
  route_table_id         = aws_route_table.poc_vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.poc_vpc_igw.id

}

# Private Route - APP Tier
resource "aws_route" "aws_private_route" {
  route_table_id         = aws_route_table.poc_vpc_private_app_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.poc_vpc_ngw.id
}

# Private Route - DB Tier
# resource "aws_route" "aws_private_db_route" {
#   route_table_id = aws_vpc.poc_vpc.default_route_table_id
#   #   destination_cidr_block = "0.0.0.0/0"

# }

