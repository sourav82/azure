resource "azurerm_resource_group" "hub-rg" {
        name = "${var.hub_resource_group_name}"
        location = "${var.location}"
	tags = "${var.hubtags}"
}

resource "azurerm_resource_group" "spoke1-rg" {
	name = "${var.spoke1_resource_group_name}"
    	location = "${var.location}"
	tags = "${var.spoketags}"
}
