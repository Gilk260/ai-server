# OPNsense Module

Creates the OPNsense firewall VM and manages firewall rules, NAT, and WireGuard keys.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opnsense"></a> [opnsense](#provider\_opnsense) | 0.16.1 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.98.1 |
| <a name="provider_wireguard"></a> [wireguard](#provider\_wireguard) | 0.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [opnsense_firewall_filter.allow_lan_dns](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_filter.allow_lan_http](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_filter.allow_lan_https](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_filter.allow_lan_outbound](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_filter.allow_wan_opnsense_api](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_filter.allow_wan_outbound](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_filter.allow_wireguard_wan](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_filter) | resource |
| [opnsense_firewall_nat.lan_to_wan](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_nat) | resource |
| [proxmox_virtual_environment_vm.opnsense](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [wireguard_asymmetric_key.vpn](https://registry.terraform.io/providers/OJFord/wireguard/latest/docs/resources/asymmetric_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_lan_bridge"></a> [lan\_bridge](#input\_lan\_bridge) | LAN bridge name (e.g., vmbr1) | `string` | `"vmbr1"` | no |
| <a name="input_network_subnet"></a> [network\_subnet](#input\_network\_subnet) | Private LAN CIDR (e.g., 10.0.0.0/16) | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | n/a | `string` | n/a | yes |
| <a name="input_opnsense_iso_file_id"></a> [opnsense\_iso\_file\_id](#input\_opnsense\_iso\_file\_id) | Proxmox file ID of the OPNsense ISO | `string` | n/a | yes |
| <a name="input_opnsense_vm"></a> [opnsense\_vm](#input\_opnsense\_vm) | n/a | <pre>object({<br/>    vmid      = number<br/>    cores     = number<br/>    memory    = number<br/>    disk_size = number<br/>  })</pre> | n/a | yes |
| <a name="input_wireguard_port"></a> [wireguard\_port](#input\_wireguard\_port) | n/a | `number` | `51820` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
