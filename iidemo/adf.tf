resource "azurerm_data_factory" "adf" {
  name                = "adfiidemo001"
  location            = "${azurerm_resource_group.spoke-rg.location}"
  resource_group_name = "${azurerm_resource_group.spoke-rg.name}"
}
