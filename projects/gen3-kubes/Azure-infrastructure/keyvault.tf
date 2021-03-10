

resource "azurerm_key_vault" "keyvault1" {
  name                       = join("-", ["keyvault", var.environment,random_string.uid.result])
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  soft_delete_enabled         = true
  purge_protection_enabled    = false
  sku_name = "standard"
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules        = ["75.73.0.0/16" , "168.183.0.0/16", "149.111.0.0/16", "128.35.0.0/16", "161.249.0.0/16", "198.203.174.0/23", "198.203.176.0/22", "198.203.180.0/23"]
  }
  #contact {
  #  email = "randy.olinger@optum.com"
  #  name  = "Randy Olinger"
  #  phone = "9522054278"
  #}
  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_key_vault_access_policy" "randyolinger" {
  key_vault_id = azurerm_key_vault.keyvault1.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "be2b3c36-2c8b-4905-a81b-cc3c9c58e66e"

  key_permissions = [
  "Get",  "List", "Delete", "Recover",  "Backup", "Restore",
  "Create", "Decrypt", "Encrypt", "Import", "Sign",
  "UnwrapKey", "Update", "Verify" , "WrapKey"
  ]
  secret_permissions = [
  "get",  "list", "delete", "recover",  "backup", "restore",  "set"
  ]
  storage_permissions = [
  "get",  "list", "delete", "recover",  "backup", "restore",
  "regeneratekey", "getsas", "listsas", "deletesas", "set", "setsas",
  "update"
  ]
  certificate_permissions = [
  "Get",  "List", "Delete", "Recover",  "Backup", "Restore",
  "Update" , "Create", "Import", "ManageContacts",  "ManageIssuers",
  "GetIssuers","ListIssuers","SetIssuers",
  "DeleteIssuers","Purge"
  ]
}

resource "azurerm_key_vault_access_policy" "serviceaccount" {
  key_vault_id = azurerm_key_vault.keyvault1.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "bc9ed98e-b121-4bdc-8894-3f21554d4215"

  key_permissions = [
  "Get",  "List", "Delete", "Recover",  "Backup", "Restore",
  "Create", "Decrypt", "Encrypt", "Import", "Sign",
  "UnwrapKey", "Update", "Verify" , "WrapKey"
  ]
  secret_permissions = [
  "get",  "list", "delete", "recover",  "backup", "restore",  "set"
  ]
  storage_permissions = [
  "get",  "list", "delete", "recover",  "backup", "restore",
  "regeneratekey", "getsas", "listsas", "deletesas", "set", "setsas",
  "update"
  ]
  certificate_permissions = [
  "Get",  "List", "Delete", "Recover",  "Backup", "Restore",
  "Update" , "Create", "Import", "ManageContacts",  "ManageIssuers",
  "GetIssuers","ListIssuers","SetIssuers",
  "DeleteIssuers","Purge"
  ]
}



resource "azurerm_key_vault_access_policy" "carlosgarcia" {
  key_vault_id = azurerm_key_vault.keyvault1.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "8d1aadf7-0913-4e23-a653-72ff9de2c226"

  key_permissions = [
    "Get",  "List", "Delete", "Recover",  "Backup", "Restore",
    "Create", "Decrypt", "Encrypt", "Import", "Sign",
    "UnwrapKey", "Update", "Verify" , "WrapKey"
  ]
  secret_permissions = [
  "get",  "list", "delete", "recover",  "backup", "restore",  "set"
  ]
  storage_permissions = [
  "get",  "list", "delete", "recover",  "backup", "restore",
  "regeneratekey", "getsas", "listsas", "deletesas", "set", "setsas",
  "update"
  ]
  certificate_permissions = [
  "Get",  "List", "Delete", "Recover",  "Backup", "Restore",
  "Update" , "Create", "Import", "ManageContacts",  "ManageIssuers",
  "GetIssuers","ListIssuers","SetIssuers",
  "DeleteIssuers","Purge"
  ]
}
resource "azurerm_key_vault_access_policy" "functionapp" {
  key_vault_id = azurerm_key_vault.keyvault1.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_function_app.funcapp.identity[0].principal_id

  key_permissions = [   "Get",  "List"  ]

  secret_permissions = [  "Get",  "List"  ]
}


#The gen3 secrets are created with junk data and need to be populated before the background jobs will run.
# use the following commands to update from the creds.json file from the web portal.
#
# (Remember to replace xxx and yyy with the proper values)
# $ az keyvault secret set --name gen3keyid --value "xxx" --vault-name keyvault-dev-klnow
# $ az keyvault secret set --name gen3KeySecret  --value "yyy"  --vault-name keyvault-dev-klnow

resource "azurerm_key_vault_secret" "gen3keyid" {
  name         = "gen3keyid"
  value        = "BLANK-FILLINLATER"
  key_vault_id = azurerm_key_vault.keyvault1.id
  lifecycle {
    ignore_changes = [   value , tags ]
  }
  tags = merge(var.tags, local.common_tags)
}
resource "azurerm_key_vault_secret" "gen3KeySecret" {
  name         = "gen3KeySecret"
  value        = "BLANK-FILLINLATER"
  key_vault_id = azurerm_key_vault.keyvault1.id
  lifecycle {
    ignore_changes = [   value , tags ]
  }

  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_key_vault_secret" "StorageaccountConnectString" {
  name         = "StorageaccountConnectString"
  value        = azurerm_storage_account.gen3.primary_connection_string
  key_vault_id = azurerm_key_vault.keyvault1.id
  lifecycle {
    ignore_changes = [   value , tags ]
  }
  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_key_vault_secret" "acrAdminPassword" {
  name         = "acrAdminPassword"
  value        = azurerm_container_registry.gen3.admin_password
  key_vault_id = azurerm_key_vault.keyvault1.id
  tags = merge(var.tags, local.common_tags)
}
resource "azurerm_key_vault_secret" "acrAdminUsername" {
  name         = "acrAdminUsername"
  value        = azurerm_container_registry.gen3.admin_username
  key_vault_id = azurerm_key_vault.keyvault1.id
  tags = merge(var.tags, local.common_tags)
}

data "azurerm_key_vault" "keyvault1" {
  name                       = join("-", ["keyvault", var.environment,random_string.uid.result])
  resource_group_name         = azurerm_resource_group.rg.name
}
output "keyvault1vault_uri" {
  value = data.azurerm_key_vault.keyvault1.vault_uri
}
