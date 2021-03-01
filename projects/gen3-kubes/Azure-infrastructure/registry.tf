resource "azurerm_container_registry" "gen3" {
  name                  = format("acrgen3%s",random_string.uid.result)
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  sku                      = "Basic"
  admin_enabled            = true
  #georeplication_locations = ["East US", "West Europe"]
}
#Grant access to the ACR, grant to the functionapp system

resource "azurerm_role_assignment" "acrtofuncapp0" {
  scope                = azurerm_container_registry.gen3.id
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.funcapp.identity[0].principal_id
}

resource "azurerm_role_assignment" "acrtojupyter" {
  scope                = azurerm_container_registry.gen3.id
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.funcapp.identity[0].principal_id
}

