
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
## Приватная сеть с выходом в интернет 
resource "yandex_vpc_subnet" "dev-private" {
  name           = "dev-private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.devops-project.id}"
  route_table_id = yandex_vpc_route_table.route.id
}
## Create route table for internet access in privat
resource "yandex_vpc_route_table" "route" {
  network_id = yandex_vpc_network.devops-project.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
## Приватная закрытая сеть

}

resource "yandex_vpc_subnet" "dev-private-close" {
  name           = "dev-private-close"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.devops-project.id}"
}