resource "azurerm_virtual_network" "hub-vnet" {
    name = "${var.hub_vnet_name}"
    location = "${var.location}"
    resource_group_name = azurerm_resource_group.nonprod-hub-rg.name
    address_space = ["10.180.0.0/16"]
    tags = {EnvironmentType="HUB"}
	depends_on = ["azurerm_resource_group.nonprod-hub-rg"]
}
resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.nonprod-hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.180.255.224/27"
}
resource "azurerm_subnet" "hub-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.nonprod-hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.180.0.64/27"
}

resource "azurerm_subnet" "hub-dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.nonprod-hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.180.0.32/27"
}

resource "azurerm_subnet" "hub-firewall" {
  name 		= "sub-firewall"
  resource_group_name = azurerm_resource_group.nonprod-hub-rg.name
  virtual_network_name	= azurerm_virtual_network.hub-vnet.name
  address_prefix = "10.180.1.0/24"
}
resource "azurerm_public_ip" "firewallip" {
  name = "firewallip"
  location = "${var.location}"
  resource_group_name = azurerm_resource_group.nonprod-hub-rg.name
  sku = "Standard"
      tags = {EnvironmentType="HUB"}

}
resource "azurerm_firewall" "firewall" {
  name = "firewallhub001"
  location = "${var.location}"
  resource_group_name = azurerm_resource_group.nonprod-hub-rg.name
  ip_configuration {
	name = "configuration"
	subnet_id = "${azurerm_subnet.hub-firewall.id}"
	public_ip_address_id = "${azurerm_public_ip.firewallip.id}"
  }
      tags = {EnvironmentType="HUB"}

}

resource "azurerm_network_interface" "hub-nic" {
  name                 = "hub-nic"
  location             = "${var.location}"
  resource_group_name  = azurerm_resource_group.nonprod-hub-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "hub"
    subnet_id                     = azurerm_subnet.hub-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }

      tags = {EnvironmentType="HUB"}

}

resource "azurerm_virtual_machine" "hub-vm" {
  name                  = "hub-vm"
  location              = "${var.location}"
  resource_group_name   = azurerm_resource_group.nonprod-hub-rg.name
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

    tags = {EnvironmentType="HUB"}
}

resource "azurerm_data_factory" "hub-adf" {
  name                = "hub-adf"
  location            = "${azurerm_resource_group.nonprod-hub-rg.location}"
  resource_group_name = "${azurerm_resource_group.nonprod-hub-rg.name}"
  tags = {EnvironmentType="HUB"}
}


resource "azurerm_data_lake_store" "hubadls" {
  name                = "hubadls"
  resource_group_name = "${azurerm_resource_group.nonprod-hub-rg.name}"
  location            = "${azurerm_resource_group.nonprod-hub-rg.location}"
  tags = {EnvironmentType="HUB"}
}

resource "azurerm_data_lake_store_firewall_rule" "hub-adls-firewall-rules" {
  name                = "hub-adls-firewall-rules"
  account_name        = "${azurerm_data_lake_store.hubadls.name}"
  resource_group_name = "${azurerm_resource_group.nonprod-hub-rg.name}"
  start_ip_address    = "${var.adls_firewall_start_ip}"
  end_ip_address      = "${var.adls_firewall_end_ip}"
}