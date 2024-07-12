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


resource "null_resource" "install_docker" {
  count = 1

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.public_ip[var.vm_count - 1].ip_address
    user     = "adminuser"
    password = random_password.password[var.vm_count - 1].result
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` stable\"",
      "sudo apt update",
      "sudo apt install -y docker-ce",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]
  }


  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]
}

resource "null_resource" "push_image_to_acr" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.public_ip[var.vm_count - 1].ip_address
    user     = "adminuser"
    password = random_password.password[var.vm_count - 1].result
    timeout  = "2m"
  }

  provisioner "file" {
    source      = "path/to/local/EngineINX.tar"
    destination = "/tmp/EngineINX.tar"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker load -i /tmp/EngineINX.tar",
      "sudo az acr login --name ${azurerm_container_registry.acr.name}",
      "sudo docker tag EngineINX:latest ${azurerm_container_registry.acr.login_server}/engineinx:latest",
      "sudo docker push ${azurerm_container_registry.acr.login_server}/engineinx:latest"
    ]
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm,
    null_resource.install_docker,
    azurerm_container_registry.acr
  ]
}

resource "null_resource" "run_container_from_acr" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.public_ip[var.vm_count - 1].ip_address
    user     = "adminuser"
    password = random_password.password[var.vm_count - 1].result
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker pull ${azurerm_container_registry.acr.login_server}/engineinx:latest",
      "sudo docker run -d -p 80:80 ${azurerm_container_registry.acr.login_server}/engineinx:latest"
    ]
  }

  depends_on = [
    null_resource.push_image_to_acr
  ]
}
