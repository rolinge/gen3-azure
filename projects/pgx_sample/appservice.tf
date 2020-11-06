resource "azurerm_app_service_plan" "APPPLAN" {
  name                = "appplan-${var.PGX_NAME}"
  resource_group_name = azurerm_resource_group.SITE.name
  location            = azurerm_resource_group.SITE.location
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appservice" {
  name                = "appservice-${var.PGX_NAME}"
  resource_group_name = azurerm_resource_group.SITE.name
  location            = azurerm_resource_group.SITE.location
  app_service_plan_id = azurerm_app_service_plan.APPPLAN.id
  https_only           = true
  site_config {
    linux_fx_version    = "DOCKER|minio/minio"
    app_command_line    = "gateway azure"

  }

  app_settings = {
    MINIO_ACCESS_KEY=azurerm_storage_account.STORAGE.name
    MINIO_SECRET_KEY=azurerm_storage_account.STORAGE.primary_access_key
    PORT=9000
  }
}
