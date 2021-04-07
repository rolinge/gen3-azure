terraform {
  backend "azurerm" {
    resource_group_name = "k8s-gen3-tfw2"
  }
  required_version = ">= 0.13"
}
