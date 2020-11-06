provider "azurerm" {
  environment     = "public"
  client_id       = var.AZ_CLIENT_ID
  client_secret   = var.AZ_CLIENT_SECRET
  tenant_id       = var.AZ_TENANT_ID
  subscription_id = var.AZ_SUBSCRIPTION_ID
  version         = "=2.14.0"
  features {}

}

resource "azurerm_resource_group" "SITE" {
  name     = var.PGX_NAME
  location = var.PGX_LOCATION
}

variable "AZ_CLIENT_ID" {
  default = ""
}

variable "AZ_CLIENT_SECRET" {
  default = ""
}

variable "AZ_TENANT_ID" {
  default = ""
}

variable "AZ_SUBSCRIPTION_ID" {
  default = ""
}

variable "PGX_NAME" {
  default     = "foobar"
  description = "The short name of this instance of DBE"
}

variable "PGX_SUBNET" {
  default     = "10.0.0.0/22"
  description = "The subnet used by this instance of DBE"
}

variable "BASTION_NETWORK" {
  default     = "10.1.0.0/22"
  description = "The network used by Bastion"
}

variable "PGX_LOCATION" {
  default = "west us"
}
