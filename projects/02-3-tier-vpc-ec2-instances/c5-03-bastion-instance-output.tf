output "bastion_instance_id" {
  value = aws_instance.bastion_instance.id

}

output "bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip

}
