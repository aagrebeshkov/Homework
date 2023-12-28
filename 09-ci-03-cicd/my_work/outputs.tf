output "sonar-01" {
  value = [join(",", yandex_compute_instance.VM[*].sonar-01.network_interface.0.nat_ip_address)]
}
output "nexus-01" {
  value = [join(",", yandex_compute_instance.VM[*].nexus-01.network_interface.0.nat_ip_address)]
}
