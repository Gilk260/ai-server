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
  config_path = fileexists("${path.module}/k3s-config.yaml") ? "${path.module}/k3s-config.yaml" : null
}

provider "helm" {
  kubernetes = {
    config_path = fileexists("${path.module}/k3s-config.yaml") ? "${path.module}/k3s-config.yaml" : null
  }
}

provider "opnsense" {
  uri        = var.opnsense_endpoint
  api_key    = var.opnsense_api_key != "" ? var.opnsense_api_key : "placeholder"
  api_secret = var.opnsense_api_secret != "" ? var.opnsense_api_secret : "placeholder"
}

provider "wireguard" {}
