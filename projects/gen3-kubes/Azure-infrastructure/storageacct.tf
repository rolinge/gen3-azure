# Create a storage account

resource "azurerm_storage_account" "gen3" {
  name                     = format("stgacgen3%s%s",var.environment,random_string.uid.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  account_kind              = "StorageV2"

  tags = {
    environment = var.environment
  }
}


resource "azurerm_storage_share" "gen3" {
  name                 = format("sh%s",azurerm_storage_account.gen3.name)
  storage_account_name = azurerm_storage_account.gen3.name
  quota                = 100

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2019-07-02T09:38:21.0000000Z"
      expiry      = "2052-07-02T10:38:21.0000000Z"
    }
  }
}
