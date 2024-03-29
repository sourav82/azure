locals {
  prefix-hub         = "hub"
}

resource "azurerm_virtual_network" "hub-vnet" {
        name = "${var.hub_vnet_name}"
        location = "${var.location}"
        resource_group_name = azurerm_resource_group.hub-rg.name
        address_space = ["10.180.0.0/16"]
        tags = {environment="hub"}
	depends_on = ["azurerm_resource_group.hub-rg"]
}
resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.180.255.224/27"
}
resource "azurerm_subnet" "hub-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.180.0.64/27"
}

resource "azurerm_subnet" "hub-dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.180.0.32/27"
}

resource "azurerm_subnet" "hub-firewall" {
  name 		= "sub-firewall"
  resource_group_name = azurerm_resource_group.hub-rg.name
  virtual_network_name	= azurerm_virtual_network.hub-vnet.name
  address_prefix = "10.180.1.0/24"
}
resource "azurerm_public_ip" "firewallip" {
  name = "firewallip"
  location = "${var.location}"
  resource_group_name = azurerm_resource_group.hub-rg.name
  sku = "Standard"
}
resource "azurerm_firewall" "firewall" {
  name = "firewallhub001"
  location = "${var.location}"
  resource_group_name = azurerm_resource_group.hub-rg.name
  ip_configuration {
	name = "configuration"
	subnet_id = "${azurerm_subnet.hub-firewall.id}"
	public_ip_address_id = "${azurerm_public_ip.firewallip.id}"
  }
}

resource "azurerm_network_interface" "hub-nic" {
  name                 = "hub-nic"
  location             = "${var.location}"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "hub"
    subnet_id                     = azurerm_subnet.hub-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "hub"
  }
}

resource "azurerm_virtual_machine" "hub-vm" {
  name                  = "hub-vm"
  location              = "${var.location}"
  resource_group_name   = azurerm_resource_group.hub-rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic.id]
  vm_size               = "${var.vmsize}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hub-vm"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags={
    environment = "hub"
  }
}

