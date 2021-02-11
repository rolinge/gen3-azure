resource "azurerm_storage_account" "gen3hdinsightsstorage" {
  name                            = "hdstg${var.cluster_name}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gen3hdinsights" {
  name               = "gen3hdinsights-gen2dl"
  storage_account_id = azurerm_storage_account.gen3hdinsightsstorage.id

  properties = {
    hello = "aGVsbG8="
  }
}

resource "azurerm_storage_container" "gen3hdinsightcontainer" {
  name                  = "hdinsights"
  storage_account_name  = azurerm_storage_account.gen3hdinsightsstorage.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "hdi-usermanagedidentity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name = "${var.prefix}hdiumi"
}
resource "azurerm_role_assignment" "stg_auth_hdiuseridentity" {
  scope                = azurerm_storage_account.gen3hdinsightsstorage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.hdi-usermanagedidentity.principal_id
}

resource "azurerm_hdinsight_spark_cluster" "gen3spark" {
  name                          = "hdinsights-${var.cluster_name}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  cluster_version               = "3.6"
  tier                          = "Standard"

  component_version {
    spark = "2.3"
  }

  timeouts {
    create = "60m"
    delete = "2h"
  }

  gateway {
    #enabled  = true
    username = var.hdinsight_gw_username
    password = var.hdinsight_gw_password
  }

  storage_account_gen2 {
    is_default           = true
    managed_identity_resource_id = azurerm_user_assigned_identity.hdi-usermanagedidentity.id
    storage_resource_id = azurerm_storage_account.gen3hdinsightsstorage.id
    filesystem_id = azurerm_storage_data_lake_gen2_filesystem.gen3hdinsights.id
  }

  roles {
    head_node {
      vm_size  = "STANDARD_A4_V2"
      username = var.hdinsight_node_username
      ssh_keys = [file(var.sshKeyPath_hdinsights)]
      subnet_id = azurerm_subnet.dce_aks_subnet2.id
      virtual_network_id = azurerm_virtual_network.dce_aks_vnet.id
    }

    worker_node {
      vm_size  = "STANDARD_A4_V2"
      username = var.hdinsight_node_username
      ssh_keys = [file(var.sshKeyPath_hdinsights)]
      target_instance_count = 3
      subnet_id = azurerm_subnet.dce_aks_subnet2.id
      virtual_network_id = azurerm_virtual_network.dce_aks_vnet.id
    }

    zookeeper_node {
      vm_size  = "Medium"
      username = var.hdinsight_node_username
      ssh_keys = [file(var.sshKeyPath_hdinsights)]
      subnet_id = azurerm_subnet.dce_aks_subnet2.id
      virtual_network_id = azurerm_virtual_network.dce_aks_vnet.id
    }
  }
  depends_on = [
    azurerm_role_assignment.stg_auth_hdiuseridentity,
    azurerm_storage_container" "gen3hdinsightcontainer,
    azurerm_storage_data_lake_gen2_filesystem.gen3hdinsights,
    azurerm_storage_account.gen3hdinsightsstorage
  ]
}
