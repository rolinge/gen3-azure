resource "azurerm_postgresql_server" "DATA" {
  name                            = "postgres-${var.cluster_name}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name

  sku_name                        = "GP_Gen5_2"
  storage_mb                      = 81920
  backup_retention_days           = 7
  geo_redundant_backup_enabled    = false
  version                         = "11"
  ssl_enforcement_enabled         = false
  administrator_login             = "postgres"
  administrator_login_password    = var.POSTGRES_PASSWORD
}

resource "azurerm_postgresql_configuration" "DATA" {
    name                = "idle_in_transaction_session_timeout"
    resource_group_name = azurerm_resource_group.rg.name
    server_name         = azurerm_postgresql_server.DATA.name
    value               = "21600000"
      depends_on = [
    azurerm_postgresql_server.DATA
  ]
}

resource "azurerm_postgresql_virtual_network_rule" "DATA" {
  name                = "postgres-${var.cluster_name}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.DATA.name
  subnet_id           = azurerm_subnet.dce_aks_subnet.id
    depends_on = [
    azurerm_postgresql_server.DATA,
    azurerm_subnet.dce_aks_subnet
  ]
}




resource "azurerm_postgresql_database" "example" {
  name                = "gen3dev"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.DATA.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
