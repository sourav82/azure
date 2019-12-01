resource "azurerm_template_deployment" "asetrack" {
  name                = "trackasedeploy001"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  template_body = "${file("arm/azuredeploy.json")}"

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "aseName"                   = "trackdemoase001"
    "aseLocation"               = "UK South" 
    "existingVnetResourceId"    = azurerm_virtual_network.track-vnet.id
    "subnetName"                = "ase-sub"
  }

  deployment_mode = "Incremental"
}
