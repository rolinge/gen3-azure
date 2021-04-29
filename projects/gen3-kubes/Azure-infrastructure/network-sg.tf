resource "azurerm_network_security_group" "network_sg_frontend" {
  name                = format("nsg-frontend-%s%s", var.environment, random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow_65200-65535"
    description                = "Allow 65200-65535 for AG function per ms docs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_443"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    destination_port_range     = "443"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_subnet_network_security_group_association" "network_sg_frontend" {
  subnet_id                 = azurerm_subnet.appgw_frontend.id
  network_security_group_id = azurerm_network_security_group.network_sg_frontend.id
}

resource "azurerm_network_security_group" "network_sg_primary" {
  name                = format("nsg-primary-%s%s", var.environment, random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow_local_subnet_traffic_inbound"
    description                = "Allow local traffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.0.0/24"
    destination_address_prefix = "10.1.0.0/24"
  }

  security_rule {
    name                       = "Allow_local_subnet_traffic_outbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    destination_port_range     = "*"
    source_port_range          = "*"
    source_address_prefix      = "10.1.0.0/24"
    destination_address_prefix = "10.1.0.0/24"
  }
  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_subnet_network_security_group_association" "network_sg_primary" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.network_sg_primary.id
}

resource "azurerm_network_security_group" "network_sg_secondary" {
  name                = format("nsg-secondary-%s%s", var.environment, random_string.uid.result)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow_local_subnet_traffic_inbound"
    description                = "Allow local traffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.32.0/22"
    destination_address_prefix = "10.1.32.0/22"
  }

  security_rule {
    name                       = "Allow_local_subnet_traffic_outbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    destination_port_range     = "*"
    source_port_range          = "*"
    source_address_prefix      = "10.1.32.0/22"
    destination_address_prefix = "10.1.32.0/22"
  }
  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_subnet_network_security_group_association" "network_sg_secondary" {
  subnet_id                 = azurerm_subnet.aks_subnet2.id
  network_security_group_id = azurerm_network_security_group.network_sg_secondary.id
}
resource "azurerm_subnet_network_security_group_association" "network_sg_appintegration" {
  subnet_id                 = azurerm_subnet.aks_appintegration.id
  network_security_group_id = azurerm_network_security_group.network_sg_secondary.id
}
