output "vm_public_ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "vm_private_ip" {
  value = yandex_compute_instance.vm.network_interface[0].ip_address
}
