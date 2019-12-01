provider "azurerm" {
    version = "~>1.22"
}
resource "azurerm_resource_group" "hub-rg" {
	name = var.hub_rg_name
	location = var.location
	tags = {
		Environment-Type = "Pilot"
	}
}
resource "azurerm_resource_group" "spoke-rg" {
        name = var.spoke_rg_name
        location = var.location
        tags = {
                Environment-Type = "Pilot"
		Project = "Track"
        }
}
