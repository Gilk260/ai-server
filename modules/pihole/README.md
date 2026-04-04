# Pi-hole Module

Creates a Pi-hole LXC container with automated unattended installation.

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
| [proxmox_virtual_environment_container.pihole](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_container) | resource |
| [terraform_data.pihole_install](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_gateway_ip"></a> [gateway\_ip](#input\_gateway\_ip) | n/a | `string` | n/a | yes |
| <a name="input_lan_bridge"></a> [lan\_bridge](#input\_lan\_bridge) | n/a | `string` | `"vmbr1"` | no |
| <a name="input_lxc_template_file_id"></a> [lxc\_template\_file\_id](#input\_lxc\_template\_file\_id) | Proxmox file ID of the Debian LXC template | `string` | n/a | yes |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Private network CIDR (for IP address mask) | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | n/a | `string` | n/a | yes |
| <a name="input_pihole_ct"></a> [pihole\_ct](#input\_pihole\_ct) | n/a | <pre>object({<br/>    vmid   = number<br/>    cores  = number<br/>    memory = number<br/>    disk   = number<br/>    ip     = string<br/>  })</pre> | n/a | yes |
| <a name="input_proxmox_ip"></a> [proxmox\_ip](#input\_proxmox\_ip) | Proxmox host IP for SSH provisioner (pct exec) | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | n/a | yes |
| <a name="input_vm_datastore_id"></a> [vm\_datastore\_id](#input\_vm\_datastore\_id) | n/a | `string` | `"local-lvm"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | n/a |
| <a name="output_pihole_ip"></a> [pihole\_ip](#output\_pihole\_ip) | n/a |
<!-- END_TF_DOCS -->
