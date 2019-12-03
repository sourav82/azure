resource "azurerm_sql_server" "sqliidemo" {
  name                         = "sqliidemo001"
  resource_group_name          = azurerm_resource_group.spoke-rg.name
  location                     = azurerm_resource_group.spoke-rg.location
  version                      = "12.0"
  administrator_login          = "superuser"
  administrator_login_password = "IIProgramme123"

  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}
resource "azurerm_sql_database" "ads-datamart" {
  name                = var.ads-datamart-db-name
  resource_group_name = "${azurerm_resource_group.spoke-rg.name}"
  location            = azurerm_resource_group.spoke-rg.location
  server_name         = "${azurerm_sql_server.sqliidemo.name}"
  edition = "Standard"
  requested_service_objective_name = "S7"

  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}
resource "azurerm_sql_database" "ads-foundation" {
  name                = var.ads-foundation-db-name
  resource_group_name = "${azurerm_resource_group.spoke-rg.name}"
  location            = azurerm_resource_group.spoke-rg.location
  server_name         = "${azurerm_sql_server.sqliidemo.name}"
  edition	      = "Hyperscale"

  tags = {
    Environment-Type = "Demo"
    Project = "Track"
  }
}
