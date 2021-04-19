resource "azurerm_virtual_network" "aks_vnet" {
  name                = "g3vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
  tags                = merge(var.tags, local.common_tags)
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "primary-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.0.0/24"]
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

}


resource "azurerm_subnet" "aks_subnet2" {
  name                 = "secondary-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.32.0/22"]
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

}

resource "azurerm_subnet" "appgw_frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.44.0/26"]
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  service_endpoints    = []

}

resource "azurerm_public_ip" "appgw_public" {
  name                = format("appgw-public-%s%s", var.environment, random_string.uid.result)
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.commons_dns_name
}
