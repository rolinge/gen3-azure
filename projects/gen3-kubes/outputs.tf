output "kube_config" {
  value = azurerm_kubernetes_cluster.dce_aks_cluster.kube_config_raw
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}

