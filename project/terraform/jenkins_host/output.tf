output "jenkins_network_id" {
  value = yandex_vpc_network.jenkins.id
}

output "jenkins_public_subnet_id" {
  value = yandex_vpc_subnet.jenkins-public.id
}

output "jenkins_host_ip" {
  value = yandex_compute_instance.jenkins-host.network_interface.0.ip_address
}

output "jenkins_host_white_ip" {
  value = yandex_compute_instance.jenkins-host.network_interface.0.nat_ip_address
}