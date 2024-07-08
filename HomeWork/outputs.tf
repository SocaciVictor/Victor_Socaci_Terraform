output "resource_group_name" {
  value = azurerm_resource_group.resourse_group.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.virtual_network.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "public_ip_addresses" {
  value = azurerm_public_ip.public_ip[*].ip_address
}

output "network_interface_ids" {
  value = azurerm_network_interface.nic[*].id
}

output "vm_admin_passwords" {
  value     = azurerm_linux_virtual_machine.vm[*].admin_password
  sensitive = true
}


output "vm_ids" {
  value = azurerm_linux_virtual_machine.vm[*].id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}
