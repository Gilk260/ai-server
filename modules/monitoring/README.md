# Monitoring Module

Creates Proxmox monitoring user/token, K8s namespaces, exporter secrets, Grafana credentials, and VictoriaMetrics metrics server.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.98.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.victoria_metrics](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.grafana_admin_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.opnsense_exporter_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.proxmox_exporter_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [proxmox_virtual_environment_metrics_server.victoria_metrics](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_metrics_server) | resource |
| [proxmox_virtual_environment_user.monitoring](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user) | resource |
| [proxmox_virtual_environment_user_token.monitoring](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user_token) | resource |
| [random_password.grafana_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_opnsense_api_key"></a> [opnsense\_api\_key](#input\_opnsense\_api\_key) | n/a | `string` | n/a | yes |
| <a name="input_opnsense_api_secret"></a> [opnsense\_api\_secret](#input\_opnsense\_api\_secret) | n/a | `string` | n/a | yes |
| <a name="input_victoria_metrics_port"></a> [victoria\_metrics\_port](#input\_victoria\_metrics\_port) | n/a | `number` | `30428` | no |
| <a name="input_victoria_metrics_target_ip"></a> [victoria\_metrics\_target\_ip](#input\_victoria\_metrics\_target\_ip) | IP where VictoriaMetrics is reachable (usually K3s mgmt IP) | `string` | `null` | no |
| <a name="input_virtual_environment_endpoint"></a> [virtual\_environment\_endpoint](#input\_virtual\_environment\_endpoint) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitoring_namespace"></a> [monitoring\_namespace](#output\_monitoring\_namespace) | n/a |
| <a name="output_proxmox_exporter_token_id"></a> [proxmox\_exporter\_token\_id](#output\_proxmox\_exporter\_token\_id) | n/a |
<!-- END_TF_DOCS -->
