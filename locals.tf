data "oci_core_services" "these" {}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  network_entity_ids = merge(
    { for k, v in module.internet_gateways : "ig_${k}" => v.id },
    { for k, v in module.nat_gateways : "ng_${k}" => v.id },
    { for k, v in module.service_gateways : "sg_${k}" => v.id }
  )

  services = {
    for svc in data.oci_core_services.these.services :
    (startswith(lower(svc.cidr_block), "all-") ? "services" : "objectstorage") => {
      cidr_block = svc.cidr_block
      id         = svc.id
    }
  }

  availability_domains = {
    for idx, ad in data.oci_identity_availability_domains.ads.availability_domains : idx + 1 => ad.name
  }

  route_tables = {
    for k, v in var.route_tables : k => merge(v, {
      route_rules = [
	for rr in v.route_rules : {
	  description       = rr.description
	  destination       = try(local.services[rr.destination].cidr_block, rr.destination)
	  destination_type  = rr.destination_type
	  network_entity_id = local.network_entity_ids[rr.network_entity_name]
	}
      ]
    })
  }

  nsg_rules = {
    for k, v in var.nsg_rules : k => {
      network_security_group_name = v.network_security_group_name
      description                 = v.description
      direction                   = v.direction
      protocol                    = v.protocol
      stateless                   = v.stateless
      source                      = v.source_type == "NETWORK_SECURITY_GROUP" ? module.nsgs[v.source].id : v.source
      source_type                 = v.source_type
      destination                 = v.destination_type == "NETWORK_SECURITY_GROUP" ? module.nsgs[v.destination].id : try(local.services[v.destination].cidr_block, v.destination)
      destination_type            = v.destination_type
      tcp_options                 = v.tcp_options
      udp_options                 = v.udp_options
      icmp_options                = v.icmp_options
    }
  }

  instances = {
    for k, v in var.instances : k => merge(v, {
      availability_domain = local.availability_domains[v.availability_domain]
      create_vnic_details = merge(v.create_vnic_details, {
	subnet_id = try(module.subnets[v.create_vnic_details.subnet_name].id, v.create_vnic_details.subnet_id)
	nsg_ids   = [for nsg_name in v.create_vnic_details.nsg_names : module.nsgs[nsg_name].id]
      })
      source_details = merge(v.source_details, {
	source_id = var.source_ids[v.source_details.source_name]
      })
      ssh_public_keys = join("\n", v.ssh_public_keys)
    })
  }

  clusters = {
    for k, v in var.clusters : k => merge(v, {
      endpoint_config = merge(v.endpoint_config, {
	subnet_id = module.subnets[v.endpoint_config.subnet_name].id
	nsg_ids   = [for name in try(v.endpoint_config.nsg_names, []) : module.nsgs[name].id]
      })
      options = v.options != null ? merge(v.options, {
	service_lb_subnet_ids = [for name in try(v.options.service_lb_subnet_names, []) : module.subnets[name].id]
      }) : null
    })
  }

  node_pools = {
    for k, v in var.node_pools : k => merge(v, {
      image_id = var.oke_worker_node_image_ids[v.node_source_details.image_name]
      secondary_vnics = [
        for sv in try(v.secondary_vnics, []) : merge(sv, {
          create_vnic_details = merge(sv.create_vnic_details, {
            subnet_id = module.subnets[sv.create_vnic_details.subnet_name].id
            nsg_ids   = [for name in try(sv.create_vnic_details.nsg_names, []) : module.nsgs[name].id]
          })
        })
      ]
      node_config_details = merge(v.node_config_details, {
        placement_configs = [
          for pc in v.node_config_details.placement_configs : {
            availability_domain     = local.availability_domains[pc.availability_domain]
            fault_domains           = try([for fd in pc.fault_domains : "FAULT-DOMAIN-${fd}"], null)
            subnet_id               = module.subnets[pc.subnet_name].id
            capacity_reservation_id = pc.capacity_reservation_id
          }
        ]
        node_pool_pod_network_option_details = v.node_config_details.node_pool_pod_network_option_details == null ? null : merge(v.node_config_details.node_pool_pod_network_option_details, {
          pod_subnet_ids = try(v.node_config_details.node_pool_pod_network_option_details.pod_subnet_names, null) == null ? null : [
            for name in v.node_config_details.node_pool_pod_network_option_details.pod_subnet_names : module.subnets[name].id
          ]
        })
        nsg_ids = [for name in try(v.node_config_details.nsg_names, []) : module.nsgs[name].id]
      })
    })
  }
}
