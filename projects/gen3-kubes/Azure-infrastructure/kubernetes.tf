resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                            = format("k8-%s%s",var.environment,random_string.uid.result)
  location                        = azurerm_resource_group.rg.location
  dns_prefix                      = var.prefix
  resource_group_name             = azurerm_resource_group.rg.name
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  kubernetes_version              = var.aks_k8s_version
  node_resource_group             = format("k8-nodes-%s%s",var.environment,random_string.uid.result)

  default_node_pool {
    name                = "nodepool"

    vm_size             = var.k8_agents_big
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
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8.id
    }

    http_application_routing {
      enabled = false
    }


  }

  tags = merge(var.tags, local.common_tags)

}

#resource "azurerm_kubernetes_cluster_node_pool" "gen3-2ndpool" {
#
#  name                  = format("g3large%s",random_string.uid.result)
#  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
#  vm_size               = var.k8_agents_big
#  enable_auto_scaling = true
#  max_count           = var.max_count
#  min_count           = 0
#  vnet_subnet_id      = azurerm_subnet.aks_subnet2.id
#  os_disk_size_gb     = var.k8s_os_disk_size
#  os_type              = "Linux"
#
#  tags = merge(var.tags, local.common_tags)
#}
