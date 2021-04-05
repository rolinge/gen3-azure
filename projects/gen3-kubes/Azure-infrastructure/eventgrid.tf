resource "azurerm_eventgrid_system_topic" "gen3-storage33" {
  name                   = format("egtopic%s%s",var.environment,random_string.uid.result)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  source_arm_resource_id = azurerm_storage_account.gen3.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags = merge(var.tags, local.common_tags)
}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [azurerm_function_app.funcapp]

  create_duration = "120s"
}


resource "azurerm_eventgrid_event_subscription" "gen3trigger" {
  name  = format("egsub%s%s",var.environment,random_string.uid.result)
  scope = azurerm_storage_account.gen3.id
  event_delivery_schema = "EventGridSchema"
  included_event_types = [ "Microsoft.Storage.BlobCreated" ]
  azure_function_endpoint {
    function_id = format ("%s/functions/BlobEventTrigger1", azurerm_function_app.funcapp.id)
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 128
  }
  depends_on = [azurerm_function_app.funcapp, time_sleep.wait_120_seconds]
}
