
##Create network
resource "yandex_vpc_network" "jenkins" {
  name = "jenkins"
}
## Публичная сеть с выходом в интернет 
resource "yandex_vpc_subnet" "jenkins-public" {
  name           = "jenkins-public"
  v4_cidr_blocks = ["192.168.100.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.jenkins.id}"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
resource "yandex_compute_instance" "jenkins-host" {
  name        = "jenkins-host"
  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.jenkins-public.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = local.ssh_key
  }

}