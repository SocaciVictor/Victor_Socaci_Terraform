resource "azurerm_container_registry" "acr" {
  name                = "containerRegistryFirstHomeWork"
  resource_group_name = azurerm_resource_group.resourse_group.name
  location            = azurerm_resource_group.resourse_group.location
  sku                 = "Basic"
  admin_enabled       = true    
}
