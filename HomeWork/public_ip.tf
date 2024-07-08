resource "azurerm_public_ip" "public_ip" {
  count               = var.vm_count
  name                = "example-public-ip-${count.index}"
  resource_group_name = azurerm_resource_group.resourse_group.name
  location            = azurerm_resource_group.resourse_group.location
  allocation_method   = "Static"
}
