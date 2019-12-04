resource "azurerm_template_deployment" "asetrack" {
  name                = "trackasedeploy001"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  template_body = "${file("arm/asedeploy.json")}"


  deployment_mode = "Incremental"
}
