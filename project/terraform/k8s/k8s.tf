
## Зональный кластер
# resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
#   name        = "kube-cluster-devops"
#   description = "k8s cluster for netology devops project"
#   network_id = "${yandex_vpc_network.devops-project.id}"
#   master {
#     version = "1.27"
#     zonal {
#         zone      = "${yandex_vpc_subnet.dev-public.zone}"
#         subnet_id = "${yandex_vpc_subnet.dev-public.id}"
#       }
#     public_ip = true
#     maintenance_policy {
#       auto_upgrade = true
#       maintenance_window {
#         day        = "monday"
#         start_time = "15:00"
#         duration   = "3h"
#       }
#     }
#     master_logging {
#       enabled = true
#       kube_apiserver_enabled = true
#       cluster_autoscaler_enabled = true
#       events_enabled = true
#       audit_enabled = true
#     }
#   }
#   service_account_id      = "aje90hrr5dr49i32nvqr"
#   node_service_account_id = "aje90hrr5dr49i32nvqr"
#   release_channel = "STABLE"
# }

## Региональный кластер
# Create a Kubernetes cluster

          # zone = yandex_vpc_subnet.dev_public_c.zone
          # subnet_id = yandex_vpc_subnet.dev_public_c.id
# Create a Kubernetes cluster
resource "yandex_kubernetes_cluster" "regional_cluster" {
  name        = "regional-k8s-cluster"
  description = "regional kubernetes cluster"

  network_id = "${yandex_vpc_network.devops_project.id}"

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = "${yandex_vpc_subnet.dev_public_a.zone}"
        subnet_id = "${yandex_vpc_subnet.dev_public_a.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.dev_public_b.zone}"
        subnet_id = "${yandex_vpc_subnet.dev_public_b.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.dev_public_d.zone}"
        subnet_id = "${yandex_vpc_subnet.dev_public_d.id}"
      }
    }
    version   = "1.27"
    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }

      maintenance_window {
        day        = "friday"
        start_time = "10:00"
        duration   = "4h30m"
      }
    }
    
    master_logging {
      enabled = true
      kube_apiserver_enabled = true
      cluster_autoscaler_enabled = true
      events_enabled = true
      audit_enabled = true
    }
  }

  service_account_id      = "aje90hrr5dr49i32nvqr"
  node_service_account_id = "aje90hrr5dr49i32nvqr"

  # labels = {
  #   my_key       = "my_value"
  #   my_other_key = "my_other_value"
  # }

  release_channel = "STABLE"
}

# # Create a Kubernetes node group
# resource "yandex_kubernetes_node_group" "devops_node_group" {
#   name                = "devops-node-group"
#   cluster_id          = yandex_kubernetes_cluster.devops_cluster.id
#   node_template {
#     platform_id = "standard-v1"
#   }
#   scale {
#     fixed_scale {
#       size = 3
#     }
#   }
#   node_labels = {
#     role = "worker-01"
#     environment = "testing"
#   }
# }

# # Create another Kubernetes node group
# resource "yandex_kubernetes_node_group" "devops_node_group_02" {
#   name                = "devops-node-group-02"
#   cluster_id          = yandex_kubernetes_cluster.devops_cluster.id
#   node_template {
#     platform_id = "standard-v1"
#   }
#   scale {
#     auto_scale {
#       min = 2
#       max = 4
#       initial = 2
#     }
#   }
#   node_locations = [
#     {
#       zone = "ru-central1-b"
#       subnet_id = yandex_vpc_subnet.dev_public_b.id
#     }
#   ]
#   node_labels = {
#     role = "worker-02"
#     environment = "dev"
#   }
# }