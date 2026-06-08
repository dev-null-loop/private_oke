module "vcns" {
  source                 = "git@github.com:dev-null-loop/oci_core//vcn"
  for_each               = var.vcns
  compartment_id         = var.compartment_ids[each.value.compartment_name]
  cidr_blocks            = each.value.cidr_blocks
  dns_label              = each.value.dns_label
  display_name           = each.value.display_name
  is_ipv6enabled         = each.value.is_ipv6enabled
  lookup_dns_resolver_id = false
}

module "internet_gateways" {
  source         = "git@github.com:dev-null-loop/oci_core//internet_gateway"
  for_each       = var.internet_gateways
  display_name   = each.value.display_name
  compartment_id = module.vcns[each.value.vcn_name].compartment_id
  vcn_id         = module.vcns[each.value.vcn_name].id
}

module "nat_gateways" {
  source         = "git@github.com:dev-null-loop/oci_core//nat_gateway"
  for_each       = var.nat_gateways
  display_name   = each.value.display_name
  compartment_id = module.vcns[each.value.vcn_name].compartment_id
  vcn_id         = module.vcns[each.value.vcn_name].id
}

module "service_gateways" {
  source         = "git@github.com:dev-null-loop/oci_core//service_gateway"
  for_each       = var.service_gateways
  display_name   = each.value.display_name
  compartment_id = module.vcns[each.value.vcn_name].compartment_id
  service_id     = local.services[each.value.service_name].id
  vcn_id         = module.vcns[each.value.vcn_name].id
}

module "route_tables" {
  source         = "git@github.com:dev-null-loop/oci_core//route_table"
  for_each       = local.route_tables
  display_name   = each.value.display_name
  compartment_id = module.vcns[each.value.vcn_name].compartment_id
  vcn_id         = module.vcns[each.value.vcn_name].id
  route_rules    = each.value.route_rules
}

module "subnets" {
  source                     = "git@github.com:dev-null-loop/oci_core//subnet"
  for_each                   = var.subnets
  compartment_id             = var.compartment_ids[each.value.compartment_name]
  display_name               = each.value.display_name
  cidr_block                 = each.value.cidr_block
  vcn_id                     = module.vcns[each.value.vcn_name].id
  dns_label                  = each.value.dns_label
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  route_table_id             = each.value.route_table_name == null ? null : module.route_tables[each.value.route_table_name].id
  security_list_ids          = [module.vcns[each.value.vcn_name].default_security_list_id]
}

module "nsgs" {
  source         = "git@github.com:dev-null-loop/oci_core//network_security_group"
  for_each       = var.nsgs
  compartment_id = var.compartment_ids[each.value.compartment_name]
  display_name   = each.value.display_name
  vcn_id         = module.vcns[each.value.vcn_name].id
}

module "nsg_rules" {
  source                    = "git@github.com:dev-null-loop/oci_core//network_security_group_security_rule"
  for_each                  = local.nsg_rules
  description               = each.value.description
  destination               = each.value.destination
  destination_type          = each.value.destination_type
  direction                 = each.value.direction
  icmp_options              = each.value.icmp_options
  network_security_group_id = module.nsgs[each.value.network_security_group_name].id
  protocol                  = each.value.protocol
  rule_source               = each.value.source
  rule_source_type          = each.value.source_type
  stateless                 = each.value.stateless
  tcp_options               = each.value.tcp_options
  udp_options               = each.value.udp_options
}

module "instances" {
  source                     = "git@github.com:dev-null-loop/oci_core//instance"
  for_each                   = local.instances
  availability_domain        = each.value.availability_domain
  compartment_id             = var.compartment_ids[each.value.compartment_name]
  enable_vnic_lookup_outputs = false
  create_vnic_details        = each.value.create_vnic_details
  display_name               = each.value.display_name
  ssh_public_keys            = each.value.ssh_public_keys
  shape                      = each.value.shape
  shape_config               = each.value.shape_config
  source_details             = each.value.source_details
  cloud_init                 = each.value.cloud_init
}
