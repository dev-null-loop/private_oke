variable "clusters" {
  type = map(object({
    compartment_name   = string
    name               = string
    kubernetes_version = string
    vcn_name           = string
    cni_type           = string
    endpoint_config = object({
      subnet_name          = string
      is_public_ip_enabled = bool
      nsg_names            = optional(list(string), [])
    })
    options = optional(object({
      service_lb_subnet_names = optional(list(string))
    }))
  }))
  default = {}
}

variable "node_pools" {
  type = map(object({
    compartment_name = string
    cluster_name     = string
    name             = string
    node_shape       = string
    node_shape_config = object({
      ocpus         = number
      memory_in_gbs = number
    })
    kubernetes_version = string
    ssh_public_key     = string
    node_config_details = object({
      placement_configs = list(object({
	availability_domain = number
	subnet_name         = string
      }))
      size      = number
      nsg_names = optional(list(string), [])
      node_pool_pod_network_option_details = object({
	cni_type          = string
	max_pods_per_node = optional(number)
	pod_subnet_names  = optional(list(string))
      })
    })
    node_source_details = object({
      image_name  = string
      source_type = optional(string)
    })
    cloud_init = optional(list(object({
      filename     = optional(string)
      content      = optional(string)
      content_type = optional(string)
      vars         = optional(map(string))
    })), [])
    node_eviction_node_pool_settings = optional(object({
      eviction_grace_duration              = optional(string)
      is_force_delete_after_grace_duration = optional(bool)
    }))
  }))
  default = {}
}

variable "oke_worker_node_image_ids" {
  description = "(Optional) map of OKE worker node images and ocids"
  type        = map(string)
  default     = {}
}
