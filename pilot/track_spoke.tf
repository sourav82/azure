resource "azurerm_virtual_network" "track-vnet" {
  name = var.spoke_track_vnet_name
  location = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  address_space = var.track_vnet_address_space
  tags = {
	Environment-Type = "Demo"
	Project = "Track"
  }
}
resource "azurerm_subnet" "vm-subnet"{
  name = "network-sub"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  virtual_network_name = azurerm_virtual_network.track-vnet.name
  address_prefix = "10.181.1.0/24"
}

resource "azurerm_network_interface" "tack-vm-nic" {
  name                = var.track_vm_nic_name
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
data "azurerm_network_interface" "track-vm-nic" {
  name                = var.track_vm_nic_name
  resource_group_name = azurerm_resource_group.spoke-rg.name
}


resource "azurerm_virtual_machine" "track-vm"{
  name = var.track_vm_name
  location = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  network_interface_ids = [azurerm_network_interface.tack-vm-nic.id]
  vm_size = var.track_vm_size
  os_profile_windows_config {
        provision_vm_agent=true
        timezone="UTC"
    }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}
resource "azurerm_virtual_network_peering" "peer2hub" {
  name = "peer2hub"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  virtual_network_name = azurerm_virtual_network.track-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
resource "azurerm_sql_server" "sqliidemo" {
  name                         = "sqliidemo001"
  resource_group_name          = azurerm_resource_group.spoke-rg.name
  location                     = azurerm_resource_group.spoke-rg.location
  version                      = "12.0"
  administrator_login          = "admin"
  administrator_login_password = "IIProgramme123"

  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}

