data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "web" {
  count       = 1
  name        = "web-${format("%d", count.index + 1)}"
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_resources.vm_web_cores
    memory        = var.vm_web_resources.vm_web_memory
    core_fraction = var.vm_web_resources.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id          = module.vpc_network.subnet_id
    nat                = true
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${file("/Users/aleksandrgrebeshkov/.ssh/yacloud.pub")}"
  }
}
