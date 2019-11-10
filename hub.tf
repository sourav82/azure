locals {
  prefix-hub         = "hub"
  hub-location       = "CentralUS"
  hub-resource-group = "hub-vnet-rg"
  shared-key         = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
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

