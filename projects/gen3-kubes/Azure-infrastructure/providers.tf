terraform {
  required_version = ">= 0.13"
}
provider "azurerm" {
  skip_provider_registration = true
  features  { }
}
provider null  {
}
