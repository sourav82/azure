resource "azurerm_virtual_network" "signal-vnet" {
  name                = "${var.signal_spoke_vnet_name}"
  location            = azurerm_resource_group.innovation-rg.location
  resource_group_name = azurerm_resource_group.innovation-rg.name
  address_space       = ["10.183.0.0/16"]

  tags = {
	EnvironmentType = "${var.environment}"
	Project = "Signal"
  }
  depends_on = ["azurerm_resource_group.innovation-rg"]
}
resource "azurerm_subnet" "signal-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.innovation-rg.name
  virtual_network_name = azurerm_virtual_network.signal-vnet.name
  address_prefix       = "10.183.0.64/27"
  tags = {
	EnvironmentType = "${var.environment}"
	Project = "Signal"
  }
}

resource "azurerm_virtual_network_peering" "signal-hub-peer" {
  name                      = "signal-hub-peer"
  resource_group_name       = azurerm_resource_group.innovation-rg.name
  virtual_network_name      = azurerm_virtual_network.signal-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
  depends_on = ["azurerm_virtual_network.signal-vnet", "azurerm_virtual_network.hub-vnet" ]
}
resource "azurerm_network_interface" "signal-nic" {
  name                 = "${local.prefix-signal}-nic"
  location             = azurerm_resource_group.innovation-rg.location
  resource_group_name  = azurerm_resource_group.innovation-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "signal-nic-ip"
    subnet_id                     = azurerm_subnet.signal-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
	EnvironmentType = "${var.environment}"
	Project = "Signal"
  }
}

resource "azurerm_virtual_machine" "signal-vm" {
  name                  = "signal-vm"
  location              = azurerm_resource_group.innovation-rg.location
  resource_group_name   = azurerm_resource_group.innovation-rg.name
  network_interface_ids = [azurerm_network_interface.signal-nic.id]
  vm_size               = var.vmsize

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
    computer_name  = "signal-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
	EnvironmentType = "${var.environment}"
	Project = "Signal"
  }
}

resource "azurerm_virtual_network_peering" "hub-signal-peer" {
  name                      = "hub-signal-peer"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.signal-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
  depends_on = ["azurerm_virtual_network.signal-vnet", "azurerm_virtual_network.hub-vnet"]
}
