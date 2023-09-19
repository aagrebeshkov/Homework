terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

#создаем облачную сеть
module "vpc_network" {
  source         = "./vpc_network"
  default_zone   = var.default_zone
  network_name   = var.network_name
  v4_cidr_blocks = var.v4_cidr_blocks
}

module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name        = "develop"
  network_id      = module.vpc_network.network_id   #yandex_vpc_network.develop.id
  subnet_zones    = ["ru-central1-a"]
  subnet_ids      = [ module.vpc_network.subnet_id ]    #[ yandex_vpc_subnet.develop.id ]
  instance_name   = "web"
  instance_count  = 1
  image_family    = "ubuntu-2004-lts"
  public_ip       = true
  
  metadata = {
      user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
      serial-port-enable = 1
  }

}

#Передача cloud-config в ВМ
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
 vars = {
    ssh_public_key     = file(var.ssh_public_key)
  }
}

