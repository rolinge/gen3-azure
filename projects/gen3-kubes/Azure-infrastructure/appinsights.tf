
data "azurerm_application_insights" "gen3" {
  name                = format("appinsghtsgen3%s%s",var.environment,random_string.uid.result)
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_application_insights" "gen3" {
  name                = format("appinsghtsgen3%s%s",var.environment,random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  retention_in_days   = "90"
}

output "instrumentation_key" {
  value = azurerm_application_insights.gen3.instrumentation_key
}

output "insights_app_id" {
  value = azurerm_application_insights.gen3.app_id
}
output "insights_connection_string"{
  value = azurerm_application_insights.gen3.connection_string
}
output "insights_instrumentation_key"{
  value = azurerm_application_insights.gen3.instrumentation_key
}
resource "azurerm_application_insights_analytics_item" "gen3func" {
  name                    = format("appinsghtsgen3func%s%s",var.environment,random_string.uid.result)
  application_insights_id = azurerm_application_insights.gen3.id
  content                 = "requests //simple example query"
  scope                   = "shared"
  type                    = "function"
  function_alias          = "blobconversiondata"
}
