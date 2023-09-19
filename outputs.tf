output "web_external_ip" {
  value = [for s in yandex_compute_instance.web[*]: "${s.name} = ${s.network_interface.0.nat_ip_address}"]
}

#output "back_external_ip" {
#  value = [for s in yandex_compute_instance.back[*]: "${s.name} = ${s.network_interface.0.nat_ip_address}"]
#}

output "storage" {
  value = [for s in yandex_compute_instance.storage[*]: "${s.name} = ${s.network_interface.0.nat_ip_address}"]
}

output "map" {
  value = [for i in yandex_compute_instance.web[*]: "name = ${i.name}, fqdn = ${i.fqdn}, id = ${i.id}, ip = ${i.network_interface.0.nat_ip_address}"]
}

