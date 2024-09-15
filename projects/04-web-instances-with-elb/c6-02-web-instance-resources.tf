data "aws_ami" "ubuntulinux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["*/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_security_group" "poc_web_sg" {
  vpc_id = aws_vpc.poc_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.web_host_sg_rules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ingress.key == "SSH" ? ["${aws_instance.bastion_instance.private_ip}/32"] : ["0.0.0.0/0"]
    }
  }
}

# resource "aws_eip" "web_eip" {
#   count  = var.web_instance_count
#   domain = "vpc"
# }

resource "aws_key_pair" "web_kp" {
  key_name   = var.web_key_pair_name
  public_key = file("${path.module}/ssh-keys/terraform-aws.pub")

}
resource "aws_instance" "web_instance" {
  count         = var.web_instance_count
  ami           = data.aws_ami.ubuntulinux.id
  instance_type = var.web_instance_type
  subnet_id     = element(aws_subnet.poc_web_public_subnet[*].id, count.index)
  key_name      = aws_key_pair.web_kp.key_name

  # vpc_security_group_ids = aws_security_group.poc_bastion_sg.*.id
  vpc_security_group_ids = [element(aws_security_group.poc_web_sg[*].id, count.index)]

  user_data = filebase64("${path.module}/scripts/install-nginx.sh")

}

# resource "aws_eip_association" "web_eip_assoc" {
#   count         = var.web_instance_count
#   instance_id   = element(aws_instance.web_instance[*].id, count.index)
#   allocation_id = element(aws_eip.web_eip[*].id, count.index)

# }
