resource "azurerm_container_group" "minio" {
  name                = format("app-minio-%s-%s",var.environment,random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_name_label      = format("minio-%s-%s",var.environment,random_string.uid.result)
  os_type             = "Linux"
  restart_policy      = "Always"

  container {
    name   = "minio"
    image  = "minio/minio"
    cpu    = "0.5"
    memory = "1.0"
    commands = ["/usr/bin/minio gateway azure"]

      ports {
        port     = 80
        protocol = "TCP"
      }

      environment_variables = {
        AZURE_STORAGE_ACCOUNT = "colordropbox"
        AZURE_STORAGE_KEY = "DsDRhqs2/X1Eqv1eyL/7nc754ewO4AXig9RqsT2Dr6SHrvqG2IaLmZ/OQUW6dq4Wb5RGoQ0BXBedKzB6fDcYmA=="
        MINIO_ROOT_USER = "colordrop01"
        MINIO_ROOT_PASSWORD = "NUMxODUxQjUtREZGRC00NEE1LTlFRDItRTVCREI2MjFDNDY0Cg=="
      }
    }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_container_group" "minioproxy" {
  name                = format("app-minioproxy-%s-%s",var.environment,random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_name_label      = format("minioproxy-%s-%s",var.environment,random_string.uid.result)
  os_type             = "Linux"
  restart_policy      = "Always"
  ip_address_type     = "public"

  container {
    name   = "minioproxy"
    image  = "nginx:latest"
    cpu    = "0.5"
    memory = "0.5"

      ports {
        port     = 443
        protocol = "TCP"
      }

      volume {
        name = "miniovolume"
        mount_path = "/etc/nginx/conf.d"
        read_only = false
        storage_account_name = azurerm_storage_account.colordropbox.name
        storage_account_key = azurerm_storage_account.colordropbox.primary_access_key
        share_name = azurerm_storage_share.minioconfig.name
      }
    }

  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_storage_share.minioconfig,azurerm_container_group.minio]
  tags = merge(var.tags, local.common_tags)
}
resource "azurerm_role_assignment" "miniovolume" {
  scope                = azurerm_storage_account.colordropbox.id
  role_definition_name = "Reader"
  principal_id         = azurerm_container_group.minioproxy.identity[0].principal_id
}
