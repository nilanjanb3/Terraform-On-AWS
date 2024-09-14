resource "null_resource" "key_upload" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_eip.bastion_eip.public_ip
    private_key = file("${path.module}/ssh-keys/terraform-aws.pem")
  }

  provisioner "file" {
    source      = "${path.module}/ssh-keys/terraform-aws.pem"
    destination = "/tmp/terraform-aws.pem"
    on_failure  = fail
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/terraform-aws.pem"
    ]
    on_failure = fail

  }

}
