terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
#   required_version = ">= 0.13"
#   backend "s3" {
#   endpoint = "storage.yandexcloud.net"
#   bucket = "devops-bucket"
#   region = "ru-central1"
#   key    = "terraform.tfstate"
#   skip_region_validation      = true
#   skip_credentials_validation = true
#   access_key         = "YCAJEsPrrCss6EfA767n79nKz"
#   secret_key = "YCOO6O3u0E_eX52daAyhMuFj2wVqE8Y2I_LoKjDt"
#   ## terraform init -backend-config="access_key=" backend-config="secret_key="
# }
}

provider "yandex" {
    token     = var.token
    cloud_id  = var.cloud_id
    folder_id = var.folder_id
    zone      = var.default_zone
}