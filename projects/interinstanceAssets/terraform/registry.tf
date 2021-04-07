resource "azurerm_container_registry" "gen3" {
  name                     = format("optumclinicalgenomics%s%s", var.environment, random_string.uid.result)
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku                      = "Premium"
  admin_enabled            = true
  georeplication_locations = ["East US"]
}
