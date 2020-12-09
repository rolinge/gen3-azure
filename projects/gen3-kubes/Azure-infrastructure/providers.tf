terraform {
  required_version = ">= 0.13"
}
provider "azurerm" {
	version = ">=2.3.0"
  subscription_id = "21a7a4d3-3641-4382-95a8-85ae72399ceb"
  #tenant_id       = "db05faca-c82a-4b9d-b9c5-0f64b6755421"
  skip_provider_registration = true
  features  { }
}
provider null  {
}
