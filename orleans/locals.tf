locals {
  # This maps the string from tfvars to the actual Resource ID
  image_map = {
    "alpine"   = proxmox_virtual_environment_download_file.alpine_iso.id,
    "opnsense" = proxmox_virtual_environment_download_file.opnsense_iso.id,
    "ubuntu" = proxmox_virtual_environment_download_file.ubuntu_jammy.id
  }
}
