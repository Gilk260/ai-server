resource "proxmox_virtual_environment_download_file" "ubuntu_noble" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name    = "ubuntu-24.04-cloudimg-amd64.img"
}

# OPNsense ISO (verify URL at https://opnsense.org/download/)
resource "proxmox_virtual_environment_download_file" "opnsense_iso" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = data.proxmox_virtual_environment_node.server.node_name
  url                     = "https://pkg.opnsense.org/releases/26.1/OPNsense-26.1-dvd-amd64.iso.bz2"
  file_name               = "OPNsense-26.1-dvd-amd64.iso"
  decompression_algorithm = "bz2"
  overwrite               = false
}

# Debian 12 LXC template for Pi-hole
resource "proxmox_virtual_environment_download_file" "debian_lxc" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name
  url          = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
  file_name    = "debian-13-standard_13.1-2_amd64.tar.zst"
}
