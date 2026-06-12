output "clusters" {
  value = { for k, v in module.clusters :
    k => {
      id                        = v.id
      endpoints                 = v.endpoints
      kubernetes_network_config = v.kubernetes_network_config
      service_lb_subnet_ids     = v.service_lb_subnet_ids
      worker_nodes = zipmap(keys(module.node_pools), [
	for pool in values(module.node_pools) :
	[for node in pool.nodes : node.private_ip]
      ])
    }
  }
}

output "kubeconfig_commands" {
  value = {
    for k, v in module.clusters :
    k => "oci ce cluster create-kubeconfig --cluster-id ${v.id} --file $HOME/.kube/private-oke-${k} --region ${var.region} --token-version 2.0.0 --kube-endpoint PRIVATE_ENDPOINT"
  }
}

# output "addons" {
#   value = { for k, v in module.addons :
#     k => {
#       id         = v.id
#       addon_name = v.addon_name
#       state      = v.state
#       version    = v.version
#     }
#   }
# }
