resource "azurerm_resource_group" "test" {
  name     = "test-loadbalancer-rg"
  location = "japaneast"
}

resource "azurerm_lb" "test" {
  name                = "test-loadbalancer"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                  = "test-public-ip-address"
    public_ip_address_id  = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "test-lb-backend-address-pool"
  loadbalancer_id = azurerm_lb.test.id
  
}

resource "azurerm_network_interface_backend_address_pool_association" "test" {
  network_interface_id    = azurerm_network_interface.test.id
  ip_configuration_name   = "test-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

}

resource "azurerm_lb_probe" "test" {
  name            = "test-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_lb_rule" "test" {
  name                           = "test_lb_rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [ azurerm_lb_backend_address_pool.test.id ]
  probe_id                       = azurerm_lb_probe.test.id
  loadbalancer_id                = azurerm_lb.test.id
}
