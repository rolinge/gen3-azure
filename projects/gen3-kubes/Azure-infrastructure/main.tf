# Create a resource group
resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}



data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  # Part of common tags to be assigned to all resources
  common_tags = {
    owner = azurerm_resource_group.rg.name
  }
}


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                            = join("_", [var.prefix, var.cluster_name])
  location                        = azurerm_resource_group.rg.location
  dns_prefix                      = var.prefix
  resource_group_name             = azurerm_resource_group.rg.name
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  kubernetes_version              = var.aks_k8s_version

  default_node_pool {
    name                = "nodepool"

    vm_size             = var.k8_agents_regular
    enable_auto_scaling = true
    max_count           = var.max_count
    min_count           = var.min_count
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    os_disk_size_gb     = var.k8s_os_disk_size
  }
  identity {
    type = "SystemAssigned"
  }
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
    }
  }
  linux_profile {
    admin_username = "osadmin"
    ssh_key {
      key_data = var.public_ssh_key
    }
  }
  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
  }
  tags = merge(var.tags, local.common_tags)

#  addon_profile {
#
#    dynamic addon_profile {
#      for_each = var.enable_log_analytics_workspace ? ["log_analytics"] : []
#      content {
#        oms_agent {
#          enabled                    = true
#          log_analytics_workspace_id = azurerm_log_analytics_workspace.k8[0].id
#        }
#      }
#    }
#  }
}

resource "azurerm_kubernetes_cluster_node_pool" "gen3-2ndpool" {

  name                  = format("g3large%s",random_string.uid.result)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = var.k8_agents_big
  enable_auto_scaling = true
  max_count           = var.max_count
  min_count           = 0
  vnet_subnet_id      = azurerm_subnet.aks_subnet2.id
  os_disk_size_gb     = var.k8s_os_disk_size
  os_type              = "Linux"

  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_log_analytics_workspace" "k8" {
  count               = var.enable_log_analytics_workspace ? 1 : 0
  name                = "loganalytics-${random_string.uid.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days

  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_log_analytics_solution" "k8" {
  count                 = var.enable_log_analytics_workspace ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8[0].id
  workspace_name        = azurerm_log_analytics_workspace.k8[0].name
  tags = merge(var.tags, local.common_tags)
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
resource "random_string" "uid" {
  length  = 5
  upper   = false
  special = false
  number  = false
}
