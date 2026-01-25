resource "proxmox_virtual_environment_download_file" "alpine_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name
  url          = "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-3.19.1-x86_64.iso"
  file_name    = "alpine-3.19.iso"
}

resource "proxmox_virtual_environment_download_file" "opnsense_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name
  # Using a reliable mirror. Note: bz2 decompression happens automatically by Proxmox if supported, 
  # but straight ISO is safer for automation if available.
  # This URL is an example. Verify the latest link from OpnSense site.
  url          = "https://pkg.opnsense.org/releases/25.7/OPNsense-25.7-dvd-amd64.iso.bz2"
  file_name    = "OPNsense-25.7-dvd-amd64.iso"
  decompression_algorithm = "bz2"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_jammy" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "ubuntu-22.04-cloud-init.img"
}
