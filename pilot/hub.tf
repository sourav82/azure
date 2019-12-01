resource "azurerm_virtual_network" hub-vnet{
  name = var.hub_vnet_name
  location = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  address_space = var.core_vnet_address_space
  tags = {
	Environment-Type = "Core"
  }
}
resource "azurerm_subnet" "fw-subnet"{
  name = "AzureFirewallSubnet"
  resource_group_name = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix = "10.180.1.0/24"
}
resource "azurerm_public_ip" "fw-pip" {
  name                = "firewall-pip"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
data "azurerm_public_ip" "fw-pip" {
  name                = "firewall-pip"
  resource_group_name = azurerm_resource_group.hub-rg.name
}
resource "azurerm_firewall" "hub-fw" {
  name                = "firewallcore001"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.fw-subnet.id
    public_ip_address_id = azurerm_public_ip.fw-pip.id
  }
}
data "azurerm_firewall" "hub-fw" {
  name                = "firewallcore001"
  resource_group_name = azurerm_resource_group.hub-rg.name
}

resource "azurerm_firewall_nat_rule_collection" "fw-nat-rule" {
  name                = "nat-collection"
  azure_firewall_name = azurerm_firewall.hub-fw.name
  resource_group_name = azurerm_resource_group.hub-rg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "natrule001"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "3389",
    ]

    destination_addresses = [
      "${data.azurerm_public_ip.fw-pip.ip_address}"
    ]
    translated_address = data.azurerm_network_interface.track-vm-nic.ip_configuration.0.private_ip_address
    translated_port = "3389"
    protocols = [
      "TCP",
      "UDP",
    ]
  }
}
resource "azurerm_firewall_application_rule_collection" "fw-outbound" {
  name                = "outbound-collection"
  azure_firewall_name = azurerm_firewall.hub-fw.name
  resource_group_name = azurerm_resource_group.hub-rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

    source_addresses = [
      "10.180.0.0/16",
    ]

    target_fqdns = [
      "*",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
   }
  }
}
resource "azurerm_route_table" "hub-udr-fw-track" {
  name                          = "udrcore001"
  location                      = azurerm_resource_group.hub-rg.location
  resource_group_name           = azurerm_resource_group.hub-rg.name

  route {
    name           = "route1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_firewall.hub-fw.ip_configuration.0.private_ip_address
  }

  tags = {
    Environment-Type = "Core"
  }
}
resource "azurerm_virtual_network_peering" "peer2track" {
  name = "peer2track"
  resource_group_name = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.track-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
