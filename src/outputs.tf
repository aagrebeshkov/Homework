output "web_external_ip" {
  value = yandex_compute_instance.platform.network_interface.0.nat_ip_address
}

output "db_external_ip" {
  value = yandex_compute_instance.platform_db.network_interface.0.nat_ip_address
}
