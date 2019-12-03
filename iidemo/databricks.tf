resource "azurerm_databricks_workspace" "databricks-demo" {
  name                = "dbrksresdemo001"
  resource_group_name = "${azurerm_resource_group.spoke-rg.name}"
  location            = "${azurerm_resource_group.spoke-rg.location}"
  sku                 = "standard"

  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}
