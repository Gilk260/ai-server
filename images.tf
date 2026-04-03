locals {
  # Cross-product: every image on every node
  image_node_pairs = {
    for pair in flatten([
      for img_key, img in var.images : [
        for node in local.all_nodes : {
          key   = "${img_key}/${node}"
          image = img_key
          node  = node
        }
      ]
    ]) : pair.key => pair
  }

  # Keyed as "os_key/node_name" => file ID
  image_ids = { for k, v in proxmox_virtual_environment_download_file.image : k => v.id }
}

resource "proxmox_virtual_environment_download_file" "image" {
  for_each = local.image_node_pairs

  content_type            = var.images[each.value.image].content_type
  datastore_id            = var.images[each.value.image].datastore_id
  node_name               = each.value.node
  url                     = var.images[each.value.image].url
  file_name               = var.images[each.value.image].file_name
  decompression_algorithm = var.images[each.value.image].decompression_algorithm
  overwrite               = var.images[each.value.image].overwrite
}
