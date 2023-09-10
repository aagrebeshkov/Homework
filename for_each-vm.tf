data "yandex_compute_image" "ubuntu_back" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "back" {
  depends_on  = [yandex_compute_instance.web]
  count       = length(var.vm_resources_back)
  name        = "${var.vm_resources_back[count.index].vm_name}"
  platform_id = var.vm_web_platform_id
  resources {
    #cores         = lookup(var.vm_resources_back[1], "cpu", null)
    cores         = "${var.vm_resources_back[count.index].cpu}"
    memory        = "${var.vm_resources_back[count.index].ram}"
    core_fraction = "${var.vm_resources_back[count.index].core_fraction}"
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = "${var.vm_resources_back[count.index].disk}"
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

