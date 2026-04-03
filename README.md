# ai-server
Server managed with OpenTofu used for AI's inference

## Usage

All OpenTofu operations go through the Makefile, which handles workspace selection, var files, and safety guards.

```bash
make plan dev                    # Plan and save to .plan-dev.tfplan
make apply dev                   # Apply the saved plan (confirmation required)
make validate dev                # Validate config
make output dev                  # Show outputs
make state-list dev              # List state resources
make fmt                         # Format code (no env needed)
make help                        # Show all targets
```

### Workflow

1. `make plan <env>` — saves a binary plan file (`.plan-<env>.tfplan`)
2. Review the output
3. `make apply <env>` — applies the exact saved plan, then removes the plan file

Destructive actions (`apply`, `destroy`) require typing the environment name to confirm.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3.0 |
| <a name="requirement_opnsense"></a> [opnsense](#requirement\_opnsense) | ~> 0.16 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.98 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7 |
| <a name="requirement_wireguard"></a> [wireguard](#requirement\_wireguard) | ~> 0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./modules/argocd | n/a |
| <a name="module_cloud_vms"></a> [cloud\_vms](#module\_cloud\_vms) | ./modules/cloud_vms | n/a |
| <a name="module_iso_vms"></a> [iso\_vms](#module\_iso\_vms) | ./modules/iso_vms | n/a |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ./modules/monitoring | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_opnsense"></a> [opnsense](#module\_opnsense) | ./modules/opnsense | n/a |
| <a name="module_pihole"></a> [pihole](#module\_pihole) | ./modules/pihole | n/a |

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_node.infra](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/data-sources/virtual_environment_node) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bridges"></a> [bridges](#input\_bridges) | Proxmox network bridges to create | <pre>list(object({<br/>    name    = string<br/>    address = string<br/>    comment = optional(string, "")<br/>  }))</pre> | n/a | yes |
| <a name="input_cloud_vms"></a> [cloud\_vms](#input\_cloud\_vms) | --- Cloud-init VMs --- | <pre>map(object({<br/>    node_name    = string<br/>    vmid         = number<br/>    cores        = number<br/>    memory       = number<br/>    ip           = string<br/>    mgmt_ip      = optional(string)<br/>    disk_size    = number<br/>    os_key       = string<br/>    datastore_id = optional(string)<br/>    k3s_role     = optional(string)<br/>    on_boot      = optional(bool, true)<br/>    packages     = optional(list(string), [])<br/>    runcmd       = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | Domain for cluster services (e.g., dev.g.recouvreux.fr) | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name (must match workspace name: dev or prod) | `string` | n/a | yes |
| <a name="input_gateway_ip"></a> [gateway\_ip](#input\_gateway\_ip) | OPNsense LAN gateway IP (e.g., 10.0.0.1) | `string` | n/a | yes |
| <a name="input_infra_node_name"></a> [infra\_node\_name](#input\_infra\_node\_name) | Proxmox node for shared infrastructure (OPNsense, Pi-hole, bridges) | `string` | n/a | yes |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | --- K3s --- | `string` | n/a | yes |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Private network CIDR for VM IPs (e.g., 10.0.0.0/16) | `string` | n/a | yes |
| <a name="input_opnsense_api_key"></a> [opnsense\_api\_key](#input\_opnsense\_api\_key) | n/a | `string` | n/a | yes |
| <a name="input_opnsense_api_secret"></a> [opnsense\_api\_secret](#input\_opnsense\_api\_secret) | n/a | `string` | n/a | yes |
| <a name="input_opnsense_endpoint"></a> [opnsense\_endpoint](#input\_opnsense\_endpoint) | OPNsense API endpoint URL (e.g., https://10.0.0.1) | `string` | n/a | yes |
| <a name="input_opnsense_vm"></a> [opnsense\_vm](#input\_opnsense\_vm) | --- OPNsense --- | <pre>object({<br/>    vmid      = number<br/>    cores     = number<br/>    memory    = number<br/>    disk_size = number<br/>  })</pre> | n/a | yes |
| <a name="input_pihole_ct"></a> [pihole\_ct](#input\_pihole\_ct) | --- Pi-hole --- | <pre>object({<br/>    vmid   = number<br/>    cores  = number<br/>    memory = number<br/>    disk   = number<br/>    ip     = string<br/>  })</pre> | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | --- SSH --- | `string` | n/a | yes |
| <a name="input_virtual_environment_endpoint"></a> [virtual\_environment\_endpoint](#input\_virtual\_environment\_endpoint) | --- Proxmox connection (sensitive) --- | `string` | n/a | yes |
| <a name="input_virtual_environment_password"></a> [virtual\_environment\_password](#input\_virtual\_environment\_password) | n/a | `string` | n/a | yes |
| <a name="input_virtual_environment_username"></a> [virtual\_environment\_username](#input\_virtual\_environment\_username) | n/a | `string` | n/a | yes |
| <a name="input_wireguard_client_public_key"></a> [wireguard\_client\_public\_key](#input\_wireguard\_client\_public\_key) | n/a | `string` | n/a | yes |
| <a name="input_wireguard_subnet"></a> [wireguard\_subnet](#input\_wireguard\_subnet) | WireGuard VPN subnet (e.g., 172.1.1.0/24) | `string` | n/a | yes |
| <a name="input_images"></a> [images](#input\_images) | OS images, ISOs, and LXC templates to download | <pre>map(object({<br/>    content_type            = string<br/>    url                     = string<br/>    file_name               = optional(string)<br/>    datastore_id            = optional(string, "local")<br/>    decompression_algorithm = optional(string)<br/>    overwrite               = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_iso_vms"></a> [iso\_vms](#input\_iso\_vms) | --- ISO VMs (optional) --- | <pre>map(object({<br/>    node_name    = string<br/>    vmid         = number<br/>    cores        = number<br/>    memory       = number<br/>    disk_size    = number<br/>    os_key       = string<br/>    datastore_id = optional(string)<br/>    bridges      = list(string)<br/>    passthrough  = optional(bool, false)<br/>    pci_id       = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_vm_datastore_id"></a> [vm\_datastore\_id](#input\_vm\_datastore\_id) | n/a | `string` | `"local-lvm"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_namespace"></a> [argocd\_namespace](#output\_argocd\_namespace) | n/a |
| <a name="output_cloud_vm_ips"></a> [cloud\_vm\_ips](#output\_cloud\_vm\_ips) | n/a |
| <a name="output_k3s_server_ip"></a> [k3s\_server\_ip](#output\_k3s\_server\_ip) | n/a |
| <a name="output_monitoring_namespace"></a> [monitoring\_namespace](#output\_monitoring\_namespace) | n/a |
| <a name="output_pihole_ip"></a> [pihole\_ip](#output\_pihole\_ip) | n/a |
| <a name="output_wireguard_server_public_key"></a> [wireguard\_server\_public\_key](#output\_wireguard\_server\_public\_key) | n/a |
<!-- END_TF_DOCS -->