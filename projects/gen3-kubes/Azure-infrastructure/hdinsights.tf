resource "azurerm_storage_account" "gen3hdinsightsstorage" {
  name                            = "hdstg${var.cluster_name}${random_string.uid.result}"
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

resource "azurerm_storage_container" "gen3hdinsightcontainer" {
  name                  = "hdinsights${random_string.uid.result}"
  storage_account_name  = azurerm_storage_account.gen3hdinsightsstorage.name
  container_access_type = "private"
}

resource "azurerm_template_deployment" "hdi" {
  name                          = "hdi-${var.cluster_name}${random_string.uid.result}"
  resource_group_name           = azurerm_resource_group.rg.name
  template_body = file("./hdi-armresources/template.json")
  parameters = {
      "clusterName" = "${var.cluster_name}${random_string.uid.result}"
      "clusterLoginUserName" = var.hdinsight_gw_username
      "clusterLoginPassword" = var.hdinsight_gw_password
      "clusterVersion" = "4.0"
      "sshUserName" = var.hdi_ssh_username
      "sshPassword" =  var.hdi_ssh_Password
      "existingVirtualNetworkResourceGroup" = azurerm_resource_group.rg.name
      "existingVirtualNetworkName" =  azurerm_virtual_network.dce_aks_vnet.name
      "existingVirtualNetworkSubnetName" = azurerm_subnet.dce_aks_subnet2.name
      "existingAdlsGen2StgAccountResourceGroup" = azurerm_resource_group.rg.name
      "existingAdlsGen2StgAccountname" =  azurerm_storage_account.gen3hdinsightsstorage.name
      "newOrExistingAdlsGen2FileSystem" = azurerm_storage_data_lake_gen2_filesystem.gen3hdinsights.name
      "existingHdiUserManagedIdentityResourceGroup" = azurerm_resource_group.rg.name
      "existingHdiUserManagedIdentityName" = "${var.prefix}hdiumi"
      "headNodeSize" = var.hdiHeadNodeSize
      "workerNodeSize" = var.hdiWorkerNodeSize
   }
  deployment_mode = "Incremental"
  depends_on =   [
    azurerm_virtual_network.dce_aks_vnet,
    azurerm_subnet.dce_aks_subnet2,
    azurerm_storage_account.gen3hdinsightsstorage,
    azurerm_role_assignment.stg_auth_hdiuseridentity
  ]
  timeouts {
    create = "60m"
    delete = "2h"

  }
}
