locals {
  ssh_key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"

}