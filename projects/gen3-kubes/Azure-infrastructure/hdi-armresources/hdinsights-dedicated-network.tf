resource "azurerm_storage_account" "gen3hdinsightsstorage-dedicated" {
  name                            = "hdstg${var.cluster_name}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gen3hdinsights-dedicated" {
  name               = "gen3hdinsights-gen2dl"
  storage_account_id = azurerm_storage_account.gen3hdinsightsstorage-dedicated.id

  properties = {
    hello = "aGVsbG8="
  }
}

resource "azurerm_storage_container" "gen3hdinsightcontainer" {
  name                  = "hdinsights"
  storage_account_name  = azurerm_storage_account.gen3hdinsightsstorage-dedicated.name
  container_access_type = "private"
}

resource "azurerm_template_deployment" "hdi" {
  name                          = "hdinsights-${var.cluster_name}"
  resource_group_name           = azurerm_resource_group.rg.name
  template_body = file("./hdi-armresources/template.json")
  parameters = {
      "clusterName" = "${var.cluster_name}"
      "clusterLoginUserName" = var.hdinsight_gw_username
      "clusterLoginPassword" = var.hdinsight_gw_password
      "sshUserName" = var.hdi_ssh_username
      "sshPassword" =  var.hdi_ssh_Password
      "existingVirtualNetworkResourceGroup" = azurerm_resource_group.rg.name
      "existingVirtualNetworkName" =  azurerm_virtual_network.dce_aks_vnet.name
      "existingVirtualNetworkSubnetName" = azurerm_subnet.dce_aks_subnet2.name
      "existingAdlsGen2StgAccountResourceGroup" = azurerm_resource_group.rg.name
      "existingAdlsGen2StgAccountname" =  azurerm_storage_account.gen3hdinsightsstorage-dedicated.name
      "newOrExistingAdlsGen2FileSystem" = azurerm_storage_data_lake_gen2_filesystem.gen3hdinsights-dedicated.name
   }
  deployment_mode = "Incremental"
  depends_on =   [
    azurerm_virtual_network.dce_aks_vnet,
    azurerm_subnet.dce_aks_subnet2,
    azurerm_storage_account.gen3hdinsightsstorage-dedicated
  ]
}
