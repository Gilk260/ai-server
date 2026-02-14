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
  config_path = "${path.module}/k3s-config.yaml"
}

provider "opnsense" {
  uri            = "https://192.168.1.20"
  api_key        = sensitive(chomp(file("./opnsense/api.key")))
  api_secret     = sensitive(chomp(file("./opnsense/api.secret")))
  allow_insecure = true
}

provider "wireguard" {
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/k3s-config.yaml"
  }
}
