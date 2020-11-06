# Create a resource group
resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}



data "azurerm_subscription" "current" {}

locals {
  # Part of common tags to be assigned to all resources
  common_tags = {
    owner = azurerm_resource_group.rg.name
  }
}

resource "azurerm_virtual_network" "dce_aks_vnet" {
  name                = join("_", [var.prefix, var.vnet])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
  tags                = merge(var.tags, local.common_tags)
}

resource "azurerm_subnet" "dce_aks_subnet" {
  name                 = "dce_aks_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes       = ["10.1.0.0/24"]
  virtual_network_name = azurerm_virtual_network.dce_aks_vnet.name
  service_endpoints         = ["Microsoft.Sql", "Microsoft.Storage"]

}

resource "azurerm_kubernetes_cluster" "dce_aks_cluster" {
  name                            = join("_", [var.prefix, var.cluster_name])
  location                        = azurerm_resource_group.rg.location
  dns_prefix                      = var.prefix
  resource_group_name             = azurerm_resource_group.rg.name
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  kubernetes_version              = var.aks_k8s_version

  default_node_pool {
    name                = "nodepool"
    node_count          = var.agent_count
    vm_size             = var.agents_size
    enable_auto_scaling = true
    max_count           = var.max_count
    min_count           = var.min_count
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = azurerm_subnet.dce_aks_subnet.id
    os_disk_size_gb     = var.disk_size
  }
  service_principal {
    client_id     =  var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
  }

  dynamic addon_profile {
    for_each = var.enable_log_analytics_workspace ? ["log_analytics"] : []
    content {
      oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.k8[0].id
      }
      kube_dashboard {
        enabled                    = true
      }
    }
  }

  tags = merge(var.tags, local.common_tags)
}

resource "random_string" "aksinsights" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  number  = true
}

resource "azurerm_log_analytics_workspace" "k8" {
  count               = var.enable_log_analytics_workspace ? 1 : 0
  name                = "loganalytics-${random_string.aksinsights.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
  #retention_in_days   = var.log_retention_in_days

  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_log_analytics_solution" "k8" {
  count                 = var.enable_log_analytics_workspace ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8[0].id
  workspace_name        = azurerm_log_analytics_workspace.k8[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
