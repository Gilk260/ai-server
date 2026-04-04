output "blocky_ip" {
  value = var.blocky_ct.ip
}

output "container_id" {
  value = proxmox_virtual_environment_container.blocky.vm_id
}
