# Cloud VMs Module

Creates cloud-init VMs with K3s hardening, template rendering, and kubeconfig fetch.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.98.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_file.cloud_config](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_vm.cloud](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [terraform_data.k3s_kubeconfig](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_vms"></a> [cloud\_vms](#input\_cloud\_vms) | n/a | <pre>map(object({<br/>    vmid      = number<br/>    cores     = number<br/>    memory    = number<br/>    ip        = string<br/>    mgmt_ip   = optional(string)<br/>    disk_size = number<br/>    os_key    = string<br/>    k3s_role  = optional(string)<br/>    on_boot   = optional(bool, true)<br/>    packages  = optional(list(string), [])<br/>    runcmd    = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_gateway_ip"></a> [gateway\_ip](#input\_gateway\_ip) | n/a | `string` | n/a | yes |
| <a name="input_image_ids"></a> [image\_ids](#input\_image\_ids) | Map of os\_key => Proxmox file ID for cloud images | `map(string)` | n/a | yes |
| <a name="input_k3s_mgmt_ip"></a> [k3s\_mgmt\_ip](#input\_k3s\_mgmt\_ip) | K3s server management IP (for kubeconfig fetch) | `string` | `null` | no |
| <a name="input_k3s_server_ip"></a> [k3s\_server\_ip](#input\_k3s\_server\_ip) | K3s server IP (for agent nodes to join) | `string` | `null` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | n/a | `string` | n/a | yes |
| <a name="input_kubeconfig_output_path"></a> [kubeconfig\_output\_path](#input\_kubeconfig\_output\_path) | Absolute path where k3s-config.yaml will be written | `string` | n/a | yes |
| <a name="input_lan_bridge"></a> [lan\_bridge](#input\_lan\_bridge) | n/a | `string` | `"vmbr1"` | no |
| <a name="input_mgmt_bridge"></a> [mgmt\_bridge](#input\_mgmt\_bridge) | Management NIC bridge (e.g., vmbr0) | `string` | `"vmbr0"` | no |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Private network CIDR (for IP address mask, e.g., 10.0.0.0/16) | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | n/a | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | n/a | yes |
| <a name="input_templates_path"></a> [templates\_path](#input\_templates\_path) | Absolute path to the templates/ directory | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_k3s_kubeconfig_ready"></a> [k3s\_kubeconfig\_ready](#output\_k3s\_kubeconfig\_ready) | n/a |
| <a name="output_k3s_server_ip"></a> [k3s\_server\_ip](#output\_k3s\_server\_ip) | n/a |
| <a name="output_vm_ips"></a> [vm\_ips](#output\_vm\_ips) | n/a |
<!-- END_TF_DOCS -->
