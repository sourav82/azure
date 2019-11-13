resource "azurerm_resource_group" "hub-rg" {
        name = "${var.hub_rg}"
        location = "${var.location}"
	tags = "${var.hubtags}"
}
resource "azurerm_resource_group" "data_hub_innovation_rg" {
  	name = "${var.data_hub_innovation_rg}"
	location = "${var.location}"
	tags = "${var.datahubinnovtags}"
}

resource "azurerm_resource_group" "spoke-track-rg" {
	name = "${var.spoke-track_rg}"
    	location = "${var.location}"
	tags = "${var.spoketrackinnovtags}"
}

resource "azurerm_resource_group" "spoke-sig-rg" {
        name = "${var.spoke-signal_rg}"
        location = "${var.location}"
        tags = "${var.spokesignalinnovtags}"
}
