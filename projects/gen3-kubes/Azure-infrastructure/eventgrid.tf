resource "azurerm_eventgrid_system_topic" "gen3-storage33" {
  name                   = format("evtsystopic%s%s",var.environment,random_string.uid.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  source_arm_resource_id = azurerm_storage_account.gen3.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_eventgrid_event_subscription" "gen3trigger" {
  name  = format("evtsubscreateblob%s%s",var.environment,random_string.uid.result)
  scope = azurerm_storage_account.gen3.id
  event_delivery_schema = "EventGridSchema"
  included_event_types = [ "Microsoft.Storage.BlobCreated" ]
  azure_function_endpoint {
  function_id = format ("%s/functions/BlobEventTrigger1", azurerm_function_app.funcapp.id)
  }

}
