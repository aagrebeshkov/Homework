module "vpc_network" {
  source         = "./vpc_network"
  default_zone   = var.default_zone
  network_name   = var.network_name
  v4_cidr_blocks = var.v4_cidr_blocks
}
