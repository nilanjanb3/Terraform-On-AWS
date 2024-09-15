output "web_elb_dns" {
  value       = aws_lb.web_nlb.dns_name
  description = "value of web_elb_dns"

}
