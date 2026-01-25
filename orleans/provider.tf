provider "proxmox" {
  username = var.virtual_environment_username
  password = var.virtual_environment_password

  endpoint = var.virtual_environment_endpoint

  insecure = true

  ssh {
    agent = true
  }
}

provider "adguard" {
  host     = "${var.sinkhole_ip}:80"
  username = "admin"
  password = var.adguard_password
  scheme   = "http"
}

provider "kubernetes" {
  host        = "https://${var.control_plane_ip}:6443"
  config_path = "~/.kube/config"
}

provider "wireguard" {
}

# provider "helm" {
#   kubernetes = {
#     config_path = "~/.kube/config"
#   }
# }
