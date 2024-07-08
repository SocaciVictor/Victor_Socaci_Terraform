resource "azurerm_virtual_network" "virtual_network" {
  name                = "example-network"
  location            = azurerm_resource_group.resourse_group.location
  resource_group_name = azurerm_resource_group.resourse_group.name
  address_space       = ["10.0.0.0/16"]
}
