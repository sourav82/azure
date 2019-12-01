resource "azurerm_app_service_plan" "asptrack" {
  name                = "asptrackdemo001"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  kind                = "windows"
  app_service_environment_id = "/subscriptions/5848966e-9c65-43a6-8f59-831b41d361e2/resourceGroups/RES-IIDST-DEMO/providers/Microsoft.Web/hostingEnvironments/trackdemoase001" #azurerm_template_deployment.asetrack.outputs["app_service_evironment_id"]
 sku {
    tier = "Premium"
    size = "P1"
  }
  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}
resource "azurerm_app_service" "apptrack" {
  name                = "apptrackdemo001"
  location            = "${azurerm_resource_group.spoke-rg.location}"
  resource_group_name = "${azurerm_resource_group.spoke-rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.asptrack.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

}
