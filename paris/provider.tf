terraform {
  required_version = "= 1.10.6"

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

provider "proxmox" {
  username  = var.virtual_environment_username
  password  = var.virtual_environment_password

  endpoint = var.virtual_environment_endpoint

  insecure = true

  ssh {
    agent = true
  }
}

