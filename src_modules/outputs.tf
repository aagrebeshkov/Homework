output "web_external_ip" {
  value = [for s in yandex_compute_instance.web[*]: "${s.name} = ${s.network_interface.0.nat_ip_address}"]
}

output "map" {
  value = [for i in yandex_compute_instance.web[*]: "name = ${i.name}, fqdn = ${i.fqdn}, id = ${i.id}, ip = ${i.network_interface.0.nat_ip_address}"]
}

### From Terraform console ###
#[for s in yandex_compute_instance.web[*]: "${s.name} = ${s.network_interface.0.nat_ip_address}"]

#yc compute instance list
