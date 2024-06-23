
##Create network
resource "yandex_vpc_network" "devops_project" {
  name = "devops-project"
}
## Публичная сеть с выходом в интернет 
resource "yandex_vpc_subnet" "dev_public_a" {
  name           = "dev_public_a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.devops_project.id}"
}
resource "yandex_vpc_subnet" "dev_public_b" {
  name           = "dev_public_b"
  v4_cidr_blocks = ["192.168.40.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.devops_project.id}"
}
resource "yandex_vpc_subnet" "dev_public_d" {
  name           = "dev_public_d"
  v4_cidr_blocks = ["192.168.60.0/24"]
  zone           = "ru-central1-d"
  network_id     = "${yandex_vpc_network.devops_project.id}"
}