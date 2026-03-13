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

provider "opnsense" {
  uri        = var.opnsense_endpoint
  api_key    = var.opnsense_api_key
  api_secret = var.opnsense_api_secret
}

provider "wireguard" {}
