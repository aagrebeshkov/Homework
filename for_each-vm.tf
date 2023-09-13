data "yandex_compute_image" "ubuntu_back" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "back" {
  depends_on  = [yandex_compute_instance.web]
  for_each    = {
    "main" = {
      vm_name       = "main" #var.vm_resources_main.vm_name
      cpu           = var.vm_resources_main.cpu
      ram           = var.vm_resources_main.ram
      disk          = var.vm_resources_main.disk
      core_fraction = var.vm_resources_main.core_fraction
    }
    "replica" = {
      vm_name       = "replica" #var.vm_resources_replica.vm_name
      cpu           = var.vm_resources_replica.cpu
      ram           = var.vm_resources_replica.ram
      disk          = var.vm_resources_replica.disk
      core_fraction = var.vm_resources_replica.core_fraction
    }

  }
  #count       = length(var.vm_resources_back)
  #name        = "${var.vm_resources_back[count.index].vm_name}"
  name        = each.value.vm_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = each.value.cpu #"${var.vm_resources_back[count.index].cpu}"
    memory        = each.value.ram #"${var.vm_resources_back[count.index].ram}"
    core_fraction = each.value.core_fraction #"${var.vm_resources_back[count.index].core_fraction}"
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = each.value.disk #"${var.vm_resources_back[count.index].disk}"
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${file("/Users/aleksandrgrebeshkov/.ssh/yacloud.pub")}"
  }
}

