resource "yandex_compute_disk" "disks" {
  count       = 3
  name        = "disk-${format("%d", count.index + 1)}"
  description = "secondary disk-${format("%d", count.index + 1)}"
  type        = "network-hdd"
  zone        = var.default_zone
  size        = var.disk_size_vm
  block_size  = var.disk_block_size_vm
}

resource "yandex_compute_instance" "storage" {
  count       = 1
  name        = "storage-${format("%d", count.index + 1)}"
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

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disks.*.id
    content {
      disk_id = secondary_disk.value
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
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
