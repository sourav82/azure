resource "azurerm_resource_group" "nonprod-hub-rg" {
        name = "${var.nonprod_hub_rg}"
        location = "${var.location}"
	tags = {
		EnvironmentType = "Non-Production"
		Project = "Non-Prod-HUB"
	}
}
resource "azurerm_resource_group" "innovation-rg" {
        name = "${var.innovation_rg}"
        location = "${var.location}"
        tags = {
		EnvironmentType = "Innovation"
	}
}
