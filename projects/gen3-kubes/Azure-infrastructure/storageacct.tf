# Create a storage account

resource "azurerm_storage_account" "gen3" {
  name                     = format("stg%s%s",var.environment,random_string.uid.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  account_kind              = "StorageV2"

  identity {
    type = "SystemAssigned"
  }

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

resource "azurerm_storage_container" "registry" {
  name                  = "registry"
  storage_account_name  = azurerm_storage_account.gen3.name
  container_access_type = "private"
}

#resource "azurerm_storage_blob" "appcode" {
#    name = "functionapp.zip"
#    storage_account_name = azurerm_storage_account.gen3.name
#    storage_container_name = azurerm_storage_container.functioncode.name
#    type = "Block"
#    source = var.functionapp
#}


data "azurerm_storage_account_sas" "gen3sas" {
    connection_string = azurerm_storage_account.gen3.primary_connection_string
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

# Create a storage account for ingesting data

resource "azurerm_storage_account" "gen3ingest" {
  name                     = format("stgingest%s%s",var.environment,random_string.uid.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  account_kind              = "StorageV2"
  allow_blob_public_access  = "false"

  identity {
    type = "SystemAssigned"
  }
  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.api_server_authorized_ip_ranges
    virtual_network_subnet_ids = [azurerm_subnet.aks_subnet.id,azurerm_subnet.aks_subnet2.id]
  }

  tags = merge(var.tags, local.common_tags)
}

# Create a storage account for color to drop off data

resource "azurerm_storage_account" "dropbox" {
  name                     = format("stgdrop%s%s",var.environment,random_string.uid.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  account_kind              = "StorageV2"
  allow_blob_public_access  = "false"

  identity {
    type = "SystemAssigned"
  }
  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.api_server_authorized_ip_ranges
    virtual_network_subnet_ids = [azurerm_subnet.aks_subnet.id,azurerm_subnet.aks_subnet2.id]
  }

  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_storage_share" "minioconfig" {
  name                 = "miniovolume"
  storage_account_name = azurerm_storage_account.dropbox.name
  quota                = 5

  acl {
    id = "CE1362BF-7414-4A26-9A0B-42D95F2DC400"

    access_policy {
      permissions = "rwdl"
    }
  }
}


resource "time_sleep" "waitAccessPoliciesPlus30s" {
  depends_on = [ azurerm_key_vault_access_policy.gen3accesspolicy,
                  azurerm_key_vault_access_policy.drop01,
                  azurerm_key_vault_access_policy.ingest]
  create_duration = "30s"
}


resource "azurerm_storage_account_customer_managed_key" "gen3keyassignment" {
  storage_account_id = azurerm_storage_account.gen3.id
  key_vault_id       = azurerm_key_vault.keyvault1.id
  key_name           = azurerm_key_vault_key.stgacctkey.name
  depends_on = [ azurerm_key_vault_access_policy.gen3accesspolicy,azurerm_storage_account.gen3,time_sleep.waitAccessPoliciesPlus30s]
}

resource "azurerm_storage_account_customer_managed_key" "gen3dropkeyassignment" {
  storage_account_id = azurerm_storage_account.dropbox.id
  key_vault_id       = azurerm_key_vault.keyvault1.id
  key_name           = azurerm_key_vault_key.stgacctkey.name
  depends_on = [  azurerm_key_vault_access_policy.drop01,azurerm_storage_account.dropbox,time_sleep.waitAccessPoliciesPlus30s]
}
resource "azurerm_storage_account_customer_managed_key" "gen3ingestkeyassignment" {
  storage_account_id = azurerm_storage_account.gen3ingest.id
  key_vault_id       = azurerm_key_vault.keyvault1.id
  key_name           = azurerm_key_vault_key.stgacctkey.name
  depends_on = [  azurerm_key_vault_access_policy.ingest,azurerm_storage_account.gen3ingest,time_sleep.waitAccessPoliciesPlus30s]
}

# this adds the group AZU_Clinicogenomics_fileshare_rw ACL to the file share.
#resource "azurerm_role_assignment" "gen3ingest" {
#  scope                = azurerm_storage_account.gen3hdinsightsstorage.id
#  role_definition_name = "Contributor"
#  principal_id         = "40e2f0b8-827b-4db4-b110-885a474d2945"
#}
