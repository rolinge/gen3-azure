resource "azurerm_data_factory" "cg" {
  name                = format("df-cg%s", var.environment)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_data_factory_integration_runtime_azure" "example" {
  name                = format("dfintrt-%s", var.environment)
  description         = "Azure runtime for clinicogenomics services"
  data_factory_name   = azurerm_data_factory.cg.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  core_count          = var.data_factory_runtime_core_count
  time_to_live_min    = var.data_factory_runtime_ttl
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "cgblob" {
  description          = "Link to shared blob storage at clinicogenomics level"
  name                 = format("df-link-blob-%s", var.environment)
  resource_group_name  = azurerm_resource_group.rg.name
  connection_string    = azurerm_storage_account.cg.primary_connection_string
  #use_managed_identity = true
  data_factory_name    = azurerm_data_factory.cg.name
}

#resource "azurerm_data_factory_linked_service_azure_file_storage" "cgfs" {
#  description          = "Link to shared file storage at clinicogenomics level"
#  name                 = format("df-link-file-%s", var.environment)
#  resource_group_name  = azurerm_resource_group.rg.name
#  connection_string    = azurerm_storage_account.cg.primary_connection_string
#  file_share           = "cgshstgiidevakgen"
#  file_share           = azurerm_storage_share.cg.name
#  data_factory_name    = azurerm_data_factory.cg.name
#}

resource "azurerm_data_factory_linked_service_postgresql" "cgpostgres" {
  name                = format("df-link-postgres-%s", var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  data_factory_name   = azurerm_data_factory.cg.name
  connection_string   = "host=${azurerm_postgresql_server.clinicogenomics.fqdn} port=5432 dbname=postgres user=datafactory_user@${azurerm_postgresql_server.clinicogenomics.fqdn} password=${module.df_password.password} sslmode=require"
  }
