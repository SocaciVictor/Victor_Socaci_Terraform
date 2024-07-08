resource "null_resource" "ping" {
  count = var.vm_count

  connection {
    host     = azurerm_public_ip.public_ip[count.index].ip_address
    user     = "adminuser"
    password = random_password.password[count.index].result
  }

  provisioner "remote-exec" {
    inline = [
      "ping -c 1 ${azurerm_public_ip.public_ip[(count.index + 1) % var.vm_count].ip_address}",
    ]
  }
}