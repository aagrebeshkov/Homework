module "vpc_network" {
  source         = "./vpc_network"
  default_zone   = var.default_zone
  network_name   = var.network_name
  v4_cidr_blocks = var.v4_cidr_blocks
}

#Передача cloud-config в ВМ
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
 vars = {
    ssh_public_key     = file(var.ssh_public_key)
  }
}
