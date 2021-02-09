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

resource "azurerm_hdinsight_spark_cluster" "gen3spark" {
  name                          = "hdinsights-${var.cluster_name}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  cluster_version               = "3.6"
  tier                          = "Standard"

  component_version {
    spark = "2.3"
  }

  gateway {
    #enabled  = true
    username = var.hdinsight_gw_username
    password = var.hdinsight_gw_password
  }

  storage_account {
    storage_container_id = azurerm_storage_container.gen3hdinsightcontainer.id
    storage_account_key  = azurerm_storage_account.gen3hdinsightsstorage.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "STANDARD_A4_V2"
      username = var.hdinsight_node_username
      ssh_keys = [file(var.sshKeyPath_hdinsights)]
    }

    worker_node {
      vm_size  = "STANDARD_A4_V2"
      username = var.hdinsight_node_username
      ssh_keys = [file(var.sshKeyPath_hdinsights)]
      target_instance_count = 3
    }

    zookeeper_node {
      vm_size  = "Medium"
      username = var.hdinsight_node_username
      ssh_keys = [file(var.sshKeyPath_hdinsights)]
    }
  }
}
