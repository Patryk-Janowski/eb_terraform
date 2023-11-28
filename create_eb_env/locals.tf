locals {
  public_subnets       = { for k, subnet in aws_subnet.subnets : k => subnet.id if can(regex("public", k)) }
  public_subnets_list  = values(local.public_subnets)
  private_subnets      = { for k, subnet in aws_subnet.subnets : k => subnet.id if can(regex("private", k)) }
  private_subnets_list = values(local.private_subnets)
  db_subnets           = { for k, subnet in aws_subnet.subnets : k => subnet.id if can(regex("db", k)) }
  db_subnets_list      = values(local.db_subnets)
  public_2_priv        = { for k, subnet in aws_subnet.subnets : k => subnet.id if can(regex("db", k)) }
  private_to_public    = { for k, subnet in local.private_subnets : k => "public_${substr(k, length(k) - 2, length(k))}" }
  app_name             = "${var.eb_app_name}-${random_string.suffix.id}"
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}
