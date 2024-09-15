# locals {
#   web_elb_sg_rules = ["80", "443"]
# }

# resource "aws_security_group" "web_elb_sg" {
#   name        = "web_elb_sg"
#   description = "Security group for ELB"
#   vpc_id      = aws_vpc.poc_vpc.id
#   dynamic "ingress" {
#     for_each = local.web_elb_sg_rules
#     content {
#       from_port   = ingress.value
#       to_port     = ingress.value
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }

#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "web_elb_sg"
#   }
# }

# resource "aws_elb" "web_elb" {
#   name               = "web-elb"
#   availability_zones = local.azs

#   listener {
#     instance_port     = 80
#     instance_protocol = "HTTP"
#     lb_port           = 80
#     lb_protocol       = "HTTP"
#   }
#   dynamic "listener" {
#     for_each = local.web_elb_sg_rules
#     content {
#       instance_port     = listener.value
#       instance_protocol = listener.value == 80 ? "HTTP" : "HTTPS"
#       lb_port           = listener.value
#       lb_protocol       = listener.value == 80 ? "HTTP" : "HTTPS"
#     }

#   }
#   health_check {
#     target              = "HTTP:80/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   instances = aws_instance.web_instance[*].id

#   security_groups = [aws_security_group.web_elb_sg.id]

#   tags = {
#     Name = "web-elb"
#   }
# }


resource "aws_lb" "web_nlb" {
  name               = "web-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.poc_web_public_subnet[*].id

  enable_deletion_protection = true

  tags = {
    Name = "web-nlb"
  }

}


resource "aws_lb_target_group" "web_nlb_tg" {
  name     = "web-nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.poc_vpc.id

  health_check {
    interval            = 30
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
  }

  tags = {
    Name = "web-nlb-target-group"
  }
}


resource "aws_lb_listener" "web_nlb_listener" {
  load_balancer_arn = aws_lb.web_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_nlb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_nlb_tg_attachment" {
  count            = var.web_instance_count
  target_group_arn = aws_lb_target_group.web_nlb_tg.arn
  target_id        = element(aws_instance.web_instance[*].id, count.index)
  port             = 80
}
