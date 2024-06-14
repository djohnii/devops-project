
##Create network
resource "yandex_vpc_network" "devops-project" {
  name = "devops-project"
}
## Публичная сеть с выходом в интернет 
resource "yandex_vpc_subnet" "dev-public" {
  name           = "dev-public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.devops-project.id}"
}
