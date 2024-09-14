output "web_instance_ids" {
  value = aws_instance.web_instance[*].id

}

# output "bastion_public_ip" {
#   value = aws_eip.bastion_eip.public_ip

# }

output "web_instance_private_ips" {
  value = { for i, ec2 in aws_instance.web_instance : i => ec2.private_ip }

}
