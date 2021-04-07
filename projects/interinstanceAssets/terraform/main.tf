# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  # Part of common tags to be assigned to all resources
  common_tags = {
    owner = azurerm_resource_group.rg.name
  }
}
resource "random_string" "uid" {
  length  = 5
  upper   = false
  special = false
  number  = false
}
