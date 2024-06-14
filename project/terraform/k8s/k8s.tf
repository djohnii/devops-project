resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
  name        = "kube-cluster-devops"
  description = "k8s cluster for netology devops project"

  network_id = "${yandex_vpc_network.devops-project.id}"


  master {
    version = "1.27"
    zonal {
        zone      = "${yandex_vpc_subnet.dev-public.zone}"
        subnet_id = "${yandex_vpc_subnet.dev-public.id}"
      }




    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }

    }
    
    master_logging {
      enabled = true
    #   folder_id = "${data.yandex_resourcemanager_folder.folder_resource_name.id}"
      kube_apiserver_enabled = true
      cluster_autoscaler_enabled = true
      events_enabled = true
      audit_enabled = true
    }
  }

  service_account_id      = "aje90hrr5dr49i32nvqr"
  node_service_account_id = "aje90hrr5dr49i32nvqr"

#   labels = {
#     my_key       = "my_value"
#     my_other_key = "my_other_value"
#   }

  release_channel = "STABLE"
}

#   service_account_id      = "${yandex_iam_service_account.service_account_resource_name.id}"
#   node_service_account_id = "${yandex_iam_service_account.node_service_account_resource_name.id}"


