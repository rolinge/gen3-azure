# since these variables are re-used - a locals block makes this more maintainable

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.aks_vnet.name}-beap"
  frontend_port_name80           = "${azurerm_virtual_network.aks_vnet.name}-fehttp"
  frontend_port_name443          = "${azurerm_virtual_network.aks_vnet.name}-fehttps"
  frontend_ip_configuration_name = "${azurerm_virtual_network.aks_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.aks_vnet.name}-be-htst"
  listener_name80                = "${azurerm_virtual_network.aks_vnet.name}-httplstn80"
  listener_name443               = "${azurerm_virtual_network.aks_vnet.name}-httplstn443"
  request_routing_rule_name80    = "${azurerm_virtual_network.aks_vnet.name}-rqrt80"
  request_routing_rule_name443   = "${azurerm_virtual_network.aks_vnet.name}-rqrt443"
  redirect_configuration_name    = "${azurerm_virtual_network.aks_vnet.name}-rdrcfg"
  ssl_certificate_name           = "${azurerm_virtual_network.aks_vnet.name}-sslcert"
  gw_tags = {
    ingress-for-aks-cluster-id = azurerm_kubernetes_cluster.aks_cluster.id
  }
}



resource "azurerm_user_assigned_identity" "appgw-usermanagedidentity" {
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  location            = azurerm_resource_group.rg.location
  name                = format("appgwuid-%s%s", var.environment, random_string.uid.result)
}

data "azurerm_resource_group" "k8nodes" {
  name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}


resource "azurerm_role_assignment" "k8rg-appgw" {
  scope                = data.azurerm_resource_group.k8nodes.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.appgw-usermanagedidentity.principal_id
}




resource "azurerm_application_gateway" "network" {
  name                = format("appgw-%s%s", var.environment, random_string.uid.result)
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  location            = azurerm_resource_group.rg.location
  tags                = merge(var.tags, local.common_tags, local.gw_tags)
  lifecycle {
    ignore_changes = [tags, backend_http_settings, request_routing_rule, probe, http_listener, frontend_port, backend_address_pool]
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw-usermanagedidentity.id]
  }
  ssl_certificate {
    name                = local.ssl_certificate_name
    key_vault_secret_id = azurerm_key_vault_certificate.gen3appgwcrt.secret_id
  }

  gateway_ip_configuration {
    name      = "gen3-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw_frontend.id
  }

  frontend_port {
    name = local.frontend_port_name80
    port = 80
  }
  frontend_port {
    name = local.frontend_port_name443
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_public.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name80
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name80
    protocol                       = "Http"
  }
  http_listener {
    name                           = local.listener_name443
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name443
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name
  }
  enable_http2 = true
  request_routing_rule {
    name                       = local.request_routing_rule_name80
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name80
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
  request_routing_rule {
    name                       = local.request_routing_rule_name443
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name443
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S" #https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview
  }
}



resource "null_resource" "appgwnull" {
  provisioner "local-exec" {
    command = "az aks enable-addons -n $CLUSTER -g $RG -a ingress-appgw --appgw-id $APPGWID"
    environment = {
      RG      = azurerm_resource_group.rg.name
      CLUSTER = azurerm_kubernetes_cluster.aks_cluster.name
      APPGWID = azurerm_application_gateway.network.id
    }
  }
  depends_on = [azurerm_application_gateway.network,
    azurerm_kubernetes_cluster.aks_cluster
  ]
}
