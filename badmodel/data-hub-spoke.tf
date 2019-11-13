resource "azurerm_virtual_network" "data-hub-vnet" {
  name                = "${var.data_hub_vnet_name}"
  location            = azurerm_resource_group.innovation-rg.location
  resource_group_name = azurerm_resource_group.innovation-rg.name
  address_space       = ["10.181.0.0/16"]

  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
  depends_on = ["azurerm_resource_group.innovation-rg"]
}
resource "azurerm_subnet" "data-hub-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.innovation-rg.name
  virtual_network_name = azurerm_virtual_network.data-hub-vnet.name
  address_prefix       = "10.181.0.64/27"
  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
}

resource "azurerm_sql_server" "sqlserver" {
  name                         = "sql-innov"
  resource_group_name          = "${azurerm_resource_group.innovation-rg.name}"
  location                     = "${azurerm_resource_group.innovation-rg.location}"
  version                      = "12.0"
  administrator_login          = "${var.sqlusername}"
  administrator_login_password = "${var.sqlpassword}"

  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
}

resource "azurerm_sql_firewall_rule" "firewallrules" {
  name                = "AlllowAzureServices"
  resource_group_name = "${azurerm_resource_group.innovation-rg.name}"
  server_name         = "${azurerm_sql_server.sqlserver.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "sqldb" {
  name                             = "sql-innov-db"
  resource_group_name              = "${azurerm_resource_group.innovation-rg.name}"
  location                         = "${azurerm_resource_group.innovation-rg.location}"
  server_name                      = "${azurerm_sql_server.sqlserver.name}"
  edition                          = "Standard"
  requested_service_objective_name = "S1"
}

resource "azurerm_data_factory" "data-hub-adf" {
  name                = "datafactorydatahub001"
  location            = "${azurerm_resource_group.innovation-rg.location}"
  resource_group_name = "${azurerm_resource_group.innovation-rg.name}"
  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
}

resource "azurerm_databricks_workspace" "data-hub-databricks" {
  name                = "databricksinnov001"
  resource_group_name = "${azurerm_resource_group.innovation-rg.name}"
  location            = "${azurerm_resource_group.innovation-rg.location}"
  sku                 = "standard"

  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
}

resource "azurerm_virtual_network_peering" "data-hub-peer" {
  name                      = "data-hub-peer"
  resource_group_name       = azurerm_resource_group.innovation-rg.name
  virtual_network_name      = azurerm_virtual_network.data-hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
  depends_on = ["azurerm_virtual_network.data-hub-vnet", "azurerm_virtual_network.hub-vnet" ]
}
resource "azurerm_network_interface" "data-hub-nic" {
  name                 = "data-hub-nic"
  location             = azurerm_resource_group.innovation-rg.location
  resource_group_name  = azurerm_resource_group.innovation-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "data-hub-nic-ip"
    subnet_id                     = azurerm_subnet.data-hub-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
}

resource "azurerm_virtual_machine" "data-hub-vm" {
  name                  = "data-hub-vm"
  location              = azurerm_resource_group.innovation-rg.location
  resource_group_name   = azurerm_resource_group.innovation-rg.name
  network_interface_ids = [azurerm_network_interface.data-hub-nic.id]
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
    computer_name  = "data-hub-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
	EnvironmentType = "${var.environment}"
	Project = "DataHub"
  }
}

resource "azurerm_virtual_network_peering" "hub-data-hub-peer" {
  name                      = "hub-data-hub-peer"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.data-hub-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
  depends_on = ["azurerm_virtual_network.data-hub-vnet", "azurerm_virtual_network.hub-vnet"]
}
