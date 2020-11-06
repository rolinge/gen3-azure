resource "azurerm_storage_account" "STORAGE" {
  name                = "stgacct${var.PGX_NAME}"
  resource_group_name = azurerm_resource_group.SITE.name
  location            = azurerm_resource_group.SITE.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  access_tier              = "Hot"
  account_replication_type = "LRS"

  enable_https_traffic_only = true

  #blob_properties {
  #  cors_rule {
  #    allowed_headers       = ["*"]
  #    allowed_methods       = ["GET", "HEAD"]
  #    allowed_origins       = ["https://www.${var.PGX_DOMAIN}"]
  #    exposed_headers       = ["Content-Range", "*"]
  #    max_age_in_seconds    = "300"
  #  }
  #}

}

resource "azurerm_storage_container" "STORAGE" {
  name                  = "storage-${var.PGX_NAME}"
  storage_account_name  = azurerm_storage_account.STORAGE.name
  container_access_type = "private"
}

output "STORAGE_ACCOUNT_NAME" {
  value = azurerm_storage_account.STORAGE.name
}

output "STORAGE_ACCOUNT_KEY" {
  value = azurerm_storage_account.STORAGE.primary_access_key
}

output "STORAGE_CONTAINER" {
  value = azurerm_storage_container.STORAGE.name
}
