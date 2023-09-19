data "yandex_compute_image" "ubuntu_back" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "back" {
  depends_on  = [yandex_compute_instance.web]
for_each = { for i in var.vm_resources : i.vm_name => i } 
  name          = each.value.vm_name
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = each.value.disk
    }
  }
  platform_id = var.vm_web_platform_id
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
