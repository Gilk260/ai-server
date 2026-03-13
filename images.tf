resource "proxmox_virtual_environment_download_file" "image" {
  for_each = var.images

  content_type            = each.value.content_type
  datastore_id            = each.value.datastore_id
  node_name               = data.proxmox_virtual_environment_node.server.node_name
  url                     = each.value.url
  file_name               = each.value.file_name
  decompression_algorithm = each.value.decompression_algorithm
  overwrite               = each.value.overwrite
}
