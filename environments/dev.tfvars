cluster_name    = "dev"
cluster_domain  = "dev.g.recouvreux.fr"
infra_node_name = "cp-dev-001"
network_subnet  = "10.0.0.0/16"
gateway_ip      = "10.0.0.1"

wireguard_subnet = "172.1.1.0/24"
k3s_version      = "v1.31.4+k3s1"

bridges = [
  {
    name    = "vmbr1"
    address = "10.0.0.3/16"
    comment = "Private LAN (OPNsense)"
  }
]

cloud_vms = {
  k3s-master = {
    node_name = "cp-dev-001"
    vmid      = 1000
    cores     = 4
    memory    = 8192
    ip        = "10.0.10.1"
    disk_size = 600
    os_key    = "noble"
    k3s_role  = "server"
  }
}

opnsense_vm = {
  vmid      = 100
  cores     = 2
  memory    = 2048
  disk_size = 32
}

pihole_ct = {
  vmid   = 101
  cores  = 1
  memory = 512
  disk   = 8
  ip     = "10.0.0.2"
}

iso_vms = {}

images = {
  noble = {
    content_type = "iso"
    url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    file_name    = "noble-server-cloudimg-amd64.img"
  }
  opnsense = {
    content_type            = "iso"
    url                     = "https://pkg.opnsense.org/releases/26.1/OPNsense-26.1-dvd-amd64.iso.bz2"
    file_name               = "OPNsense-26.1-dvd-amd64.iso"
    decompression_algorithm = "bz2"
  }
  debian-lxc = {
    content_type = "vztmpl"
    url          = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
    file_name    = "debian-13-standard_13.1-2_amd64.tar.zst"
  }
}
