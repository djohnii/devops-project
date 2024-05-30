##create service account
resource "yandex_iam_service_account" "devops-sa-bucket" {
    name                               = "devops-sa-bucket"
    }

##added role to service account bucket-account
resource "yandex_resourcemanager_folder_iam_member" "service-editor2" {
    folder_id                         = var.folder_id
    role                              = "editor"
    member                            = "serviceAccount:${yandex_iam_service_account.devops-sa-bucket.id}"
}
##create static key 
resource "yandex_iam_service_account_static_access_key" "static-key-bucket" {
    service_account_id                = yandex_iam_service_account.devops-sa-bucket.id
    description                       = "static key for bukcet account"
}

    resource "yandex_kms_symmetric_key" "key-bucket" {
        name          = "devops-sa-bucket-key"
        description   = "key for bucket"
        default_algorithm = "AES_128"
        rotation_period   = "8760h"
        lifecycle {
            prevent_destroy = false
        }
    }
resource "yandex_storage_bucket" "bucket-static-site" {
    access_key    = yandex_iam_service_account_static_access_key.static-key-bucket.access_key
    secret_key    = yandex_iam_service_account_static_access_key.static-key-bucket.secret_key
    bucket        = "devops-bucket"
    max_size   = 1048576
    # acl           = "public-read"

    # website {
    #     index_document = "index.html"
    #     error_document = "error.html"
    # }
    anonymous_access_flags {
        read = false
        list = false
    }
    # server_side_encryption_configuration {
    #     rule {
    #         apply_server_side_encryption_by_default {
    #             kms_master_key_id = yandex_kms_symmetric_key.key-bucket.id
    #             sse_algorithm     = "aws:kms"
    #         }
    #     }
    # }

}

# resource "yandex_storage_object" "index" {
#     access_key    = yandex_iam_service_account_static_access_key.static-key-bucket.access_key
#     secret_key    = yandex_iam_service_account_static_access_key.static-key-bucket.secret_key
#     bucket        = yandex_storage_bucket.bucket-static-site.id
#     source        = "${path.module}/index.html"
#     key           = "index.html"
# }
# resource "yandex_storage_object" "error" {
#     access_key    = yandex_iam_service_account_static_access_key.static-key-bucket.access_key
#     secret_key    = yandex_iam_service_account_static_access_key.static-key-bucket.secret_key
#     bucket        = yandex_storage_bucket.bucket-static-site.id
#     source        = "${path.module}/error.html"
#     key           = "error.html"
# }