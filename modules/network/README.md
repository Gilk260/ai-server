# Network Module

Creates Proxmox virtual network bridges.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.98.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_network_linux_bridge.bridge](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_network_linux_bridge) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bridges"></a> [bridges](#input\_bridges) | n/a | <pre>list(object({<br/>    name    = string<br/>    address = string<br/>    comment = optional(string, "")<br/>  }))</pre> | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bridge_names"></a> [bridge\_names](#output\_bridge\_names) | n/a |
| <a name="output_bridges"></a> [bridges](#output\_bridges) | n/a |
<!-- END_TF_DOCS -->
