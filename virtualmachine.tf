resource "azurerm_linux_virtual_machine" "test" {
  name                = "test-machine"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [ azurerm_network_interface.test.id ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.keygen.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "test" {
  name                 = "test-vm-nginx"
  virtual_machine_id   = azurerm_linux_virtual_machine.test.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<INIT
  {
    "commandToExecute": "apt-get update && apt-get install -y nginx"
  }
INIT
}

resource "azurerm_network_security_group" "test" {
  name                = "test-nsg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_network_security_rule" "test" {
  name                        = "HTTP"
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  direction                   = "Inbound"
  priority                    = 100
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}
