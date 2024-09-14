variable "web_host_sg_rules" {
  type = map(string)
  default = {
    "HTTP"  = "80"
    "HTTPS" = "443"
    "SSH"   = "22"
  }

}

variable "web_instance_type" {
  default     = "t2.micro"
  description = "value of instance_type"
  type        = string

}
variable "web_instance_count" {
  type        = number
  description = "value of instance_count"
  default     = 2

}

variable "web_key_pair_name" {
  type        = string
  description = "value of key_pair_name"
  default     = "web-key-pair"

}


