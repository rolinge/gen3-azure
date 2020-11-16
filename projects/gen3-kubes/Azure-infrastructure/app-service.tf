resource "azurerm_app_service_plan" "appplan1" {
  name                = format("appsvcplangen3%s%s",var.environment,random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Standard"
    size = "Y1"
  }
}


resource "azurerm_function_app" "funcapp" {
  name                       = format("blobindexfunc%s%s",var.environment,random_string.uid.result)
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.appplan1.id
  storage_account_name       = azurerm_storage_account.gen3.name
  storage_account_access_key = azurerm_storage_account.gen3.primary_access_key
  os_type                    = "linux"

  site_config {
    linux_fx_version = "PYTHON|3.8"
    use_32_bit_worker_process = false
    always_on = false
    min_tls_version = "1.2"
#    azureStorageAccounts = {
#      CustomID = {
#        type = "AzureFiles"
#        accountName = "blobolingertriggertest22"
#        shareName = "blobolingertriggertest22"
#        mountPath = "/opt/shared"
#        }
#      }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    FUNCTIONS_EXTENSION_VERSION = "~3"
    AzureWebJobsStorage = format("@Microsoft.KeyVault(SecretUri=%s)",azurerm_storage_account.gen3.primary_connection_string)
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.gen3.instrumentation_key
    APPINSIGHTS_CONNECTION_STRING = azurerm_application_insights.gen3.connection_string
    COMMONS_URL = "https://gen3playground.optum.com"
    gen3KeyID = format("@Microsoft.KeyVault(SecretUri=%s)", azurerm_key_vault_secret.gen3keyid.id)
    gen3KeySecret = format("@Microsoft.KeyVault(SecretUri=%s)", azurerm_key_vault_secret.gen3KeySecret.id)
    MOUNT_POINT = "/opt/shared"
    RESULTS_FILE = "gen3_hashes.csv"
    StorageaccountConnectString = format("@Microsoft.KeyVault(SecretUri=%s)",azurerm_storage_account.gen3.primary_connection_string)
    }

}
