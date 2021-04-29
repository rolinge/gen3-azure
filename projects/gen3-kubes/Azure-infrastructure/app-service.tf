resource "azurerm_app_service_plan" "appplan1" {
  name                = format("app%s%s", var.environment, random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_function_app" "funcapp" {
  name                       = format("blobindexfunc%s%s", var.environment, random_string.uid.result)
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.appplan1.id
  storage_account_name       = azurerm_storage_account.gen3.name
  storage_account_access_key = azurerm_storage_account.gen3.primary_access_key
  os_type                    = "linux"
  https_only                 = true
  version                    = "~3"
  tags                       = merge(var.tags, local.common_tags)

  site_config {
    linux_fx_version          = format("DOCKER|%s/gen3/blobtriggerdocker:%s", local.registry_hostname, var.blobindexfunction_version)
    use_32_bit_worker_process = false
    always_on                 = true
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTION_APP_EDIT_MODE                = "readOnly"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = false
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.gen3.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.gen3.connection_string
    FUNCTIONS_WORKER_RUNTIME              = "python"
    FUNCTIONS_EXTENSION_VERSION           = "~3"
    #AzureWebJobsStorage = ""
    COMMONS_URL                       = format("https://%s.%s", var.commons_dns_name, var.commons_dns_suffix)
    gen3KeyID                         = format("@Microsoft.KeyVault(VaultName=%s;SecretName=%s)", azurerm_key_vault.keyvault1.name, azurerm_key_vault_secret.gen3keyid.name)
    gen3KeySecret                     = format("@Microsoft.KeyVault(VaultName=%s;SecretName=%s)", azurerm_key_vault.keyvault1.name, azurerm_key_vault_secret.gen3KeySecret.name)
    MOUNT_POINT                       = "/opt/shared"
    RESULTS_FILE                      = "gen3_hashes.csv"
    StorageaccountConnectString       = format("@Microsoft.KeyVault(VaultName=%s;SecretName=%s)", azurerm_key_vault.keyvault1.name, azurerm_key_vault_secret.StorageaccountConnectString.name)
    "DOCKER_REGISTRY_SERVER_URL"      = format("https://%s/", local.registry_hostname)
    "DOCKER_REGISTRY_SERVER_USERNAME" = local.registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = local.registry_password
    #maybe later for /home "WEBSITES_ENABLE_APP_SERVICE_STORAGE"=true
  }
}



resource "azurerm_app_service" "minio" {
  name                = format("miniofunc%s%s", var.environment, random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appplan1.id
  https_only          = true
  tags                = merge(var.tags, local.common_tags)

  site_config {
    linux_fx_version          = format("DOCKER|%s/minio:gen3", local.registry_hostname)
    use_32_bit_worker_process = false
    always_on                 = true
    app_command_line          = "gateway azure"
    ftps_state                = "Disabled"
    http2_enabled             = true
    min_tls_version           = "1.2"

  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.gen3.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.gen3.connection_string
    AZURE_STORAGE_ACCOUNT                 = azurerm_storage_account.dropbox.name
    AZURE_STORAGE_KEY                     = azurerm_storage_account.dropbox.primary_access_key
    MINIO_ROOT_USER                       = format("gen3s3drop%s", random_string.uid.result)
    MINIO_ROOT_PASSWORD                   = module.minio_password.password
    "DOCKER_REGISTRY_SERVER_URL"          = format("https://%s/", local.registry_hostname)
    "DOCKER_REGISTRY_SERVER_USERNAME"     = local.registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = local.registry_password
    #maybe later for /home "WEBSITES_ENABLE_APP_SERVICE_STORAGE"=true
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "minioconnection" {
  app_service_id = azurerm_app_service.minio.id
  subnet_id      = azurerm_subnet.aks_appintegration.id
}

resource "azurerm_app_service_virtual_network_swift_connection" "blobfunctionconnection" {
  app_service_id = azurerm_function_app.funcapp.id
  subnet_id      = azurerm_subnet.aks_appintegration.id
}


module "minio_password" {
  source    = "./modules/password_module"
  pw_length = 20
}

# Use the local-exec command to map the storage.  If it fails, the needful command is in the terraform output and in the instructions

resource "null_resource" "mapstorage" {
  provisioner "local-exec" {
    command = "az webapp config storage-account add --resource-group $RG  --storage-type AzureFiles --account-name $ACCOUNTNAME --share-name $SHARENAME --mount-path /opt/shared -n $FUNCNAME --custom-id CustomID --access-key $ACCKEY || az webapp config storage-account update --resource-group $RG  --storage-type AzureFiles --account-name $ACCOUNTNAME --share-name $SHARENAME --mount-path /opt/shared -n $FUNCNAME --custom-id CustomID --access-key $ACCKEY"
    environment = {
      RG          = azurerm_resource_group.rg.name
      ACCKEY      = azurerm_storage_account.gen3.primary_access_key
      FUNCNAME    = azurerm_function_app.funcapp.name
      ACCOUNTNAME = azurerm_storage_account.gen3.name
      SHARENAME   = azurerm_storage_share.gen3.name
    }
  }
}
# instead of defining outputs with the resource, define in one file.
# maybe helps with formatting and management

output "mapstorage" {
  value = <<EOT

  ###
  #  Below is the command to map the blob storage as specified in the instructions.
  #  The command will try to add the mount, if that fails it will try to update the setting
  ###
  az webapp config storage-account add \
      --resource-group "${azurerm_resource_group.rg.name}"  --storage-type AzureFiles \
      --account-name ${azurerm_storage_account.gen3.name} --share-name ${azurerm_storage_share.gen3.name} \
      --mount-path /opt/shared -n "${azurerm_function_app.funcapp.name}" \
      --custom-id CustomID --access-key "${azurerm_storage_account.gen3.primary_access_key}" || \
      az webapp config storage-account update \
          --resource-group "${azurerm_resource_group.rg.name}"  --storage-type AzureFiles \
          --account-name ${azurerm_storage_account.gen3.name} --share-name ${azurerm_storage_share.gen3.name} \
          --mount-path /opt/shared -n "${azurerm_function_app.funcapp.name}" \
          --custom-id CustomID --access-key "${azurerm_storage_account.gen3.primary_access_key}"


EOT
}

output "minio_S3_ACCESSKEY" {
  value = format("gen3s3drop%s", random_string.uid.result)
}

output "minio_S3_SECRETKEY" {
  value = module.minio_password.password
}

output "minio_S3_ENDPOINT" {
  value = azurerm_app_service.minio.default_site_hostname
}
