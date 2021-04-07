output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}
output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_admin_config
}


output "kublet_identity" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}


output "storageAcct_name" {
  value = azurerm_storage_account.gen3.name
}
output "fileshare" {
  value = azurerm_storage_share.gen3.name
}

output "postgresql_server_id" {
  value = azurerm_postgresql_server.g3DATA.id
}
output "postgresql_server_version" {
  value = azurerm_postgresql_server.g3DATA.version
}
output "postgresql_server_fqdn" {
  value = azurerm_postgresql_server.g3DATA.fqdn
}
output "postgresql_server_password" {
  value = module.postgres_password.password
}

output "gen3keyid" {
  value = azurerm_key_vault_secret.gen3keyid.id
}

output "gen3KeySecret" {
  value = azurerm_key_vault_secret.gen3KeySecret.id
}
output "acrUsername" {
  value = local.registry_username
}

output "acrPassword" {
value = local.registry_password
}
output "acrHost" {
value = local.registry_hostname
}
