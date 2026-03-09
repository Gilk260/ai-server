provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password
  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}

provider "kubernetes" {
  config_path = "${path.module}/k3s-config.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/k3s-config.yaml"
  }
}
