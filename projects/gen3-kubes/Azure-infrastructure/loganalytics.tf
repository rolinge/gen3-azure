resource "azurerm_log_analytics_workspace" "k8" {
  name                = format("loga-%s%s",var.environment,random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days

  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_log_analytics_solution" "k8" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8.id
  workspace_name        = azurerm_log_analytics_workspace.k8.name
  tags = merge(var.tags, local.common_tags)
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
