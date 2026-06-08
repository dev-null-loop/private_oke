oke_worker_node_image_ids = {
  "Oracle-Linux-8.10-2026.02.28-0-OKE-1.33.10-1402" = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaasa4pvuytqrw6yrbvu64546h5kveil6pi6a25jqt2w6pbu5mddcjq"
}

clusters = {
  c = {
    compartment_name   = "dev"
    name               = "cluster"
    vcn_name           = "vcn"
    kubernetes_version = "v1.33.10"
    cni_type           = "OCI_VCN_IP_NATIVE"
    endpoint_config = {
      subnet_name          = "api_endpoint"
      is_public_ip_enabled = false
      nsg_names            = ["api_endpoint"]
    }
    options = {
      service_lb_subnet_names = ["svcs_lb"]
    }
  }
}

node_pools = {
  n = {
    cluster_name       = "c"
    compartment_name   = "dev"
    kubernetes_version = "v1.33.10"
    name               = "pool"
    node_source_details = {
      image_name = "Oracle-Linux-8.10-2026.02.28-0-OKE-1.33.10-1402"
    }
    cloud_init = [
      {
	content_type = "text/cloud-config"
	filename     = "userdata/oke-copyfail-ksplice.yaml"
      }
    ]
    node_config_details = {
      nsg_names = ["nodes"]
      node_pool_pod_network_option_details = {
	cni_type          = "OCI_VCN_IP_NATIVE"
	max_pods_per_node = 31
	pod_subnet_names  = ["nodes"]
      }
      placement_configs = [
	{
	  availability_domain = 1
	  subnet_name         = "nodes"
	},
	{
	  availability_domain = 2
	  subnet_name         = "nodes"
	},
	{
	  availability_domain = 3
	  subnet_name         = "nodes"
	}
      ]
      size = 1
    }
    node_eviction_node_pool_settings = {
      eviction_grace_duration              = "PT1M"
      is_force_delete_after_grace_duration = true
    }
    node_shape = "VM.Standard.E3.Flex"
    node_shape_config = {
      ocpus         = 4
      memory_in_gbs = 16
    }
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+qUPnq3ELkvEXclIv27YnMsVFdEwVC9XmjpbWYcvIBq3sLF+UBat05PYNLUmvHJS5jA6bb5Wn323YLx2+CyUBD+7UfACNo/aCaliqtskGeDKfzOiFDP2kvfMNIDCOS4hKJpgqE8irOgcTcrL94GU7BjxsyC+JCN/qgWTcvKQNb3duiDz4lzvQI7Cb0ZeFfn6bUAYVe8D0Y9HGoWnmp/7Ku4RLNCQQSjBMmtiTL4q7q9hTG3VEmldOMbncPiEp3bBiepj0sg5dxX5jhYn7ftwNcSkkifaz68yNd13c85dNXq3Nf/8Bw0Jhx28uor3xz7nYAoXdkK7Jnzwjl/lwP0xTOhrBf1iZ8E4FZ1612tIKt2xoWLOn+0fveaGnu+LqNLidWOZ71WUH18Vg2n9UnWm2HQQyA+i9LrIXN/ZXo1osVno4cxVU4zFkaCQDYQ+Cl8BmT0NMvmvlPxsYdzRCreKQB3b1nPZUM6ReTukyrN64DP5eB3J+LDSplcFLgLE+7XU= bd"
  }
}
