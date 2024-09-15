output "availability_zones" {
  value = [for i, az in local.azs : az]

}

output "aws_vpc_id" {
  value = aws_vpc.poc_vpc.id

}

output "poc_web_public_subnet_ids" {
  value = aws_subnet.poc_web_public_subnet[*].id

}

output "poc_app_private_subnet_ids" {
  value = aws_subnet.poc_app_private_subnet[*].id

}

output "poc_db_private_subnet_ids" {
  value = aws_subnet.poc_db_private_subnet[*].id

}

output "db_subnet_default_route_table_id" {
  value = aws_vpc.poc_vpc.default_route_table_id

}
