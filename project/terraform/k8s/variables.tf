###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "region" {
  type    = string
  default = "ru-central1"
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "public_subnet_cidr" {
  type    = string
  default = "192.168.10.0/24"
}

variable "public_ip_address" {
  type    = string
  default = "192.168.10.2"
}

variable "nat_instance_name" {
  type    = string
  default = "nat-instance"
}

variable "vm_instance_name" {
  type    = string
  default = "vm-instance"
}

variable "image_id" {
  type    = string
  default = "fd80mrhj8fl2oe87o4e1"
}