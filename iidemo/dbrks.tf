resource "azurerm_template_deployment" "dbrks" {
  name                = "dbrksdeploy001"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  template_body = "${file("arm/azuredeploy.json")}"
  deployment_mode = "Incremental"
}
