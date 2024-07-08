resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "example-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.resourse_group.name
  location              = azurerm_resource_group.resourse_group.location
  size                  = var.vm_size
  admin_username        = "adminuser"
  admin_password        = random_password.password[count.index].result
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.vm_image 
    version   = "latest"
  }

  computer_name                  = "hostname-${count.index}"
  disable_password_authentication = false
}
