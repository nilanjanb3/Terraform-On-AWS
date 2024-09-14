locals {
  owner = var.owner
  env   = var.environment
  bu    = var.business_unit

  common_tags = {
    Owner       = local.owner
    Environment = local.env
    BU          = local.bu
  }
}
