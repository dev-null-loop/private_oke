oke_worker_node_image_ids = {
  "Oracle-Linux-8.10-2026.04.30-3-OKE-1.36.0-1462" = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaarsyv3dwaim2hmetvqodbu3iereolqqgt3knnge6wgzn2uhej34aq"
}

clusters = {
  c = {
    compartment_name   = "dev"
    name               = "cluster"
    vcn_name           = "vcn"
    kubernetes_version = "v1.36.0"
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
    kubernetes_version = "v1.36.0"
    name               = "pool"
    freeform_tags = {
      oke-cluster-autoscaler = "true"
    }
    node_source_details = {
      image_name = "Oracle-Linux-8.10-2026.04.30-3-OKE-1.36.0-1462"
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

addons = {
  cert_manager = {
    cluster_name  = "c"
    addon_name    = "CertManager"
    addon_version = "v1.20.2"
    configurations = {
      numOfReplicas = "1"
    }
  }
  cluster_autoscaler = {
    cluster_name     = "c"
    addon_name       = "ClusterAutoscaler"
    addon_version    = "v1.34.3"
    compartment_name = "dev"
    node_pool_name   = "n"
    min_nodes        = 1
    max_nodes        = 3
    node_pool_tags = {
      oke-cluster-autoscaler = "true"
    }
    configurations = {
      numOfReplicas                    = "1"
      authType                         = "instance"
      scaleDownDelayAfterAdd           = "10m"
      scaleDownDelayAfterDelete        = "10s"
      scaleDownDelayAfterFailure       = "3m"
      scaleDownUnneededTime            = "10m"
      scaleDownUnreadyTime             = "20m"
      scaleDownUtilizationThreshold    = "0.5"
      scaleDownNonEmptyCandidatesCount = "30"
      scaleDownCandidatesPoolRatio     = "0.1"
      scaleDownCandidatesPoolMinCount  = "50"
      unremovableNodeRecheckTimeout    = "5m"
    }
  }
  csi_driver_smb = {
    cluster_name  = "c"
    addon_name    = "CsiDriverSmb"
    addon_version = "v1.19.1"
  }
  istio = {
    cluster_name  = "c"
    addon_name    = "Istio"
    addon_version = "v1.28.5"
    configurations = {
      numOfReplicas        = "1"
      profile              = "oke-default"
      enableIngressGateway = "false"
      customizeConfigMap   = "false"
    }
  }
  kubernetes_dashboard = {
    cluster_name  = "c"
    addon_name    = "KubernetesDashboard"
    addon_version = "v2.7.0-multiarch-1.25-2"
    configurations = {
      numOfReplicas = "1"
    }
  }
  native_ingress_controller = {
    cluster_name              = "c"
    addon_name                = "NativeIngressController"
    addon_version             = "v1.4.4"
    compartment_name          = "dev"
    load_balancer_subnet_name = "svcs_lb"
    configurations = {
      numOfReplicas = "1"
      authType      = "instance"
    }
  }
  oracle_database_operator = {
    cluster_name  = "c"
    addon_name    = "OracleDatabaseOperator"
    addon_version = "v2.1.0"
    configurations = {
      numOfReplicas = "1"
    }
  }
  weblogic_kubernetes_operator = {
    cluster_name  = "c"
    addon_name    = "WeblogicKubernetesOperator"
    addon_version = "v4.3.0"
    configurations = {
      numOfReplicas = "1"
    }
  }
}
