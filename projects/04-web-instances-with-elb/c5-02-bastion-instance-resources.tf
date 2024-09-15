# resource "aws_security_group" "poc_bastion_sg" {
#   name        = "poc_bastion_sg"
#   description = "Security group for bastion host"
#   vpc_id      = aws_vpc.poc_vpc.id

# }

# resource "aws_security_group_rule" "poc_bastion_ssh_ingress" {

#   security_group_id = aws_security_group.poc_bastion_sg.id
#   type              = "ingress"
#   from_port         = var.bastion_host_sg_rules["SSH"]
#   to_port           = var.bastion_host_sg_rules["SSH"]
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]

# }

# resource "aws_ec2" "name" {

# }
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
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

resource "aws_security_group" "poc_bastion_sg" {
  vpc_id = aws_vpc.poc_vpc.id

  dynamic "ingress" {
    for_each = var.bastion_host_sg_rules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "bastion_eip" {
  domain = "vpc"
}

resource "aws_key_pair" "bastion_kp" {
  key_name   = var.bastion_key_pair_name
  public_key = file("${path.module}/ssh-keys/terraform-aws.pub")

}
resource "aws_instance" "bastion_instance" {
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.poc_web_public_subnet[0].id
  key_name      = aws_key_pair.bastion_kp.key_name

  vpc_security_group_ids = aws_security_group.poc_bastion_sg.*.id

  # user_data = filebase64("${path.module}/scripts/install-httpd.sh")

}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion_instance.id
  allocation_id = aws_eip.bastion_eip.id

}
