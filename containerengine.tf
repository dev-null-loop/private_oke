module "clusters" {
  source             = "git@github.com:dev-null-loop/oci_containerengine//cluster"
  for_each           = local.clusters
  compartment_id     = var.compartment_ids[each.value.compartment_name]
  name               = each.value.name
  kubernetes_version = each.value.kubernetes_version
  vcn_id             = module.vcns[each.value.vcn_name].id
  cluster_pod_network_options = {
    cni_type = each.value.cni_type
  }
  endpoint_config = each.value.endpoint_config
  options         = each.value.options
}

module "node_pools" {
  source                           = "git@github.com:dev-null-loop/oci_containerengine//node_pool"
  for_each                         = local.node_pools
  cluster_id                       = module.clusters[each.value.cluster_name].id
  compartment_id                   = var.compartment_ids[each.value.compartment_name]
  kubernetes_version               = each.value.kubernetes_version
  name                             = each.value.name
  node_source_details              = each.value.node_source_details
  image_id                         = each.value.image_id
  cloud_init                       = each.value.cloud_init
  node_config_details              = each.value.node_config_details
  node_eviction_node_pool_settings = each.value.node_eviction_node_pool_settings
  node_shape                       = each.value.node_shape
  node_shape_config                = each.value.node_shape_config
  freeform_tags                    = each.value.freeform_tags
  secondary_vnics                  = each.value.secondary_vnics
  ssh_public_key                   = each.value.ssh_public_key
}
