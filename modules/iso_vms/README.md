# ISO VMs Module

Creates VMs that boot from ISO for manual OS installation. Supports PCI passthrough.

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
| [proxmox_virtual_environment_vm.iso](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_image_ids"></a> [image\_ids](#input\_image\_ids) | Map of 'os\_key/node\_name' => Proxmox file ID for ISO images | `map(string)` | n/a | yes |
| <a name="input_iso_vms"></a> [iso\_vms](#input\_iso\_vms) | n/a | <pre>map(object({<br/>    node_name    = string<br/>    vmid         = number<br/>    cores        = number<br/>    memory       = number<br/>    disk_size    = number<br/>    os_key       = string<br/>    datastore_id = optional(string)<br/>    bridges      = list(string)<br/>    passthrough  = optional(bool, false)<br/>    pci_id       = optional(string)<br/>    on_boot      = optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_vm_datastore_id"></a> [vm\_datastore\_id](#input\_vm\_datastore\_id) | n/a | `string` | `"local-lvm"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ids"></a> [vm\_ids](#output\_vm\_ids) | n/a |
<!-- END_TF_DOCS -->
