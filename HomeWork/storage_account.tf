resource "azurerm_storage_account" "storage" {
  name                     = "socatastorageaccount"
  resource_group_name      = azurerm_resource_group.resourse_group.name
  location                 = azurerm_resource_group.resourse_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
