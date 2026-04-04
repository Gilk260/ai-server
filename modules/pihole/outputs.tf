output "pihole_ip" {
  value = var.pihole_ct.ip
}

output "container_id" {
  value = proxmox_virtual_environment_container.pihole.vm_id
}
