data "yandex_compute_image" "centos7" {
  family = var.vm_family
}

resource "yandex_compute_instance" "VM" {
for_each = { for i in var.vm_resources : i.vm_name => i }
  name          = each.value.vm_name
  hostname      = each.value.vm_name
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos7.image_id
      size = each.value.disk
    }
  }
  platform_id = var.vm_platform_id
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id          = module.vpc_network.subnet_id
    nat                = true
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "centos7:${file("/Users/aleksandrgrebeshkov/.ssh/yacloud.pub")}"
  }
}
