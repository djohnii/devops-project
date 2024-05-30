output "access_key" {
  value    = yandex_iam_service_account_static_access_key.static-key-bucket.access_key
}
output "key" {
  value    = yandex_iam_service_account_static_access_key.static-key-bucket.secret_key
  sensitive = true
}