terraform {
  required_version = ">= 0.12.0"

}

locals {
    credentials              = {for cred in var.credentials: cred => data.vault_generic_secret.vault[0].data[cred]}
    secret_files             = {for cred in var.secret_files: cred => data.vault_generic_secret.vault[0].data[cred]}
    certificates             = {for cert, value in var.certificates: cert => {
                                    cert = data.vault_generic_secret.vault[0].data[value.cert_key]
                                    key  = data.vault_generic_secret.vault[0].data[value.key_key]
                                }}
    values                   = var.is_substitute_values == true ? templatefile(var.values_path, local.credentials) : file(var.values_path)
}

# Get data
data "vault_generic_secret" "vault" {
    count = var.vault_path == "" ? 0 : 1
    path = var.vault_path
}
data "vault_generic_secret" "vault_global" {
    count = var.vault_global_path == "" ? 0 : 1
    path = var.vault_global_path
}


# Create secrets
resource "kubernetes_secret" "credentials" {
  count        = length(local.credentials) > 0 ? 1 : 0
  metadata {
    name      = "${var.name}-credentials"
    namespace = var.namespace
  }
  data = {for k, v in local.credentials: k => v}
  type = "Opaque"
}
resource "kubernetes_secret" "certificates" {
  for_each     = local.certificates
  metadata {
    name      = "${each.key}-certificates"
    namespace = var.namespace
  }
  data = {
      "tls.crt" = each.value.cert
      "tls.key" = each.value.key
  }
  type = "kubernetes.io/tls"
}
resource "kubernetes_secret" "secret_files" {
  count        = length(local.secret_files) > 0 ? 1 : 0
  metadata {
    name      = "${var.name}-secrets"
    namespace = var.namespace
  }
  data = {for k, v in local.secret_files: k => v}
  type = "Opaque"
}

# Create PVC
# Create persistant volume claim
resource "kubernetes_persistent_volume_claim" "pvc" {
  for_each = var.pvcs
  wait_until_bound = true
  metadata {
    name = each.key
    namespace = var.namespace
  }
  spec {
    access_modes = [each.value.access_mode]
    storage_class_name = each.value.storage_class
    resources {
      requests = {
        storage = each.value.size
      }
    }
  }
}

# Create App from helm
resource "helm_release" "app" {
    name             = var.name
    repository       = var.repository
    chart            = var.template_name
    version          = var.template_version
    namespace        = var.namespace
    force_update     = var.force_upgrade

    values = [
        local.values
    ]
}
