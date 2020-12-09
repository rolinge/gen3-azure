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

  tags = merge(var.tags, local.common_tags)
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
resource "azurerm_storage_container" "gen3" {
  name                  = "azgen3blobstorage"
  storage_account_name  = azurerm_storage_account.gen3.name
  container_access_type = "private"
}
resource "azurerm_storage_container" "functioncode" {
  name                  = "azgen3functioncode"
  storage_account_name  = azurerm_storage_account.gen3.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "appcode" {
    name = "functionapp.zip"
    storage_account_name = azurerm_storage_account.gen3.name
    storage_container_name = azurerm_storage_container.functioncode.name
    type = "Block"
    source = var.functionapp
}


data "azurerm_storage_account_sas" "gen3sas" {
    connection_string = "${azurerm_storage_account.gen3.primary_connection_string}"
    https_only = true
    start = "2020-12-02"
    expiry = "2021-02-28"
    resource_types {
        object = true
        container = false
        service = false
    }
    services {
        blob = true
        queue = false
        table = false
        file = false
    }
    permissions {
        read = true
        write = false
        delete = false
        list = false
        add = false
        create = false
        update = false
        process = false
    }
}
