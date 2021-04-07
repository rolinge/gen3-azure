# Create a storage account

resource "azurerm_storage_account" "cg" {
  name                      = format("stg%s%s", var.environment, random_string.uid.result)
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  account_kind              = "StorageV2"

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_storage_share" "cg" {
  name                 = format("cgsh%s", azurerm_storage_account.cg.name)
  storage_account_name = azurerm_storage_account.cg.name
  quota                = 100

}
resource "azurerm_storage_container" "cg" {
  name                  = "cgblobstorage"
  storage_account_name  = azurerm_storage_account.cg.name
  container_access_type = "private"
}

# this adds the group AZU_Clinicogenomics_fileshare_rw ACL to the file share.
#resource "azurerm_role_assignment" "cgfs" {
#  scope                = azurerm_storage_share.cg.id
#  role_definition_name = "Contributor"
#  principal_id         = "40e2f0b8-827b-4db4-b110-885a474d2945"
#}
# this adds the group AZU_Clinicogenomics_fileshare_rw ACL to the file share.
#resource "azurerm_role_assignment" "cgcontainer" {
#  scope                = azurerm_storage_container.cg.id
#  role_definition_name = "Contributor"
#  principal_id         = "40e2f0b8-827b-4db4-b110-885a474d2945"
#}
