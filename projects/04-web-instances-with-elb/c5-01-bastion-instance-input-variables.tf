variable "bastion_host_sg_rules" {
  type = map(string)
  default = {
    "SSH" = "22"
    "RDP" = "3389"
  }

}

variable "instance_type" {
  type        = string
  description = "value of instance_type"
  default     = "t2.micro"

}

variable "bastion_key_pair_name" {
  type        = string
  description = "value of key_pair_name"
  default     = "bastion-key-pair"

}
