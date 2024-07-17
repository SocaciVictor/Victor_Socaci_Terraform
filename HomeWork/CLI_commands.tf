resource "null_resource" "ping_3" {
  count = var.vm_count

  connection {
    host     = azurerm_public_ip.public_ip[count.index].ip_address
    user     = "adminuser"
    password = random_password.password[count.index].result
  }

  provisioner "remote-exec" {
    inline = [
      "ping -c 1 ${azurerm_public_ip.public_ip[(count.index + 1) % var.vm_count].ip_address}",
       "ping -c 4 8.8.8.8",
      "if [ $? -eq 0 ]; then echo 'Internet connection is available'; else echo 'No internet connection'; fi",
    ]    
  }
}

resource "null_resource" "internet_check" {
  count = var.vm_count

  connection {
    host     = azurerm_public_ip.public_ip[count.index].ip_address
    user     = "adminuser"
    password = random_password.password[count.index].result
  }

  provisioner "remote-exec" {
    inline = [
      "ping -c 4 8.8.8.8",
      "if [ $? -eq 0 ]; then echo 'Internet connection is available'; else echo 'No internet connection'; fi"
    ]
  }
}



resource "null_resource" "install_azure_cli" {
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
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]
  }
}

resource "null_resource" "run_container_from_acr" {
  count = 1

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.public_ip[var.vm_count - 1].ip_address
    user     = "adminuser"
    password = random_password.password[var.vm_count - 1].result
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "if ! command -v docker &> /dev/null; then sudo apt-get update -y && sudo apt-get install -y -qq apt-transport-https ca-certificates curl software-properties-common gnupg && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o docker-archive-keyring.gpg && sudo mv -f docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg && echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update -y && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-ce docker-ce-cli containerd.io && sudo systemctl start docker && sudo systemctl enable docker; fi",

      "if ! command -v az &> /dev/null; then curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash; fi",

      "az login --service-principal -u ${var.azure_client_id} -p ${var.azure_client_secret} --tenant ${var.azure_tenant_id}",

      "az account set --subscription d4ecd8ca-959f-44dd-aace-d25cec910ab5",

      "az acr login --name containerregistryfirsthomework",

      "docker pull containerregistryfirsthomework.azurecr.io/nginx:latest",

      "if [ $? -ne 0 ]; then echo 'Failed to pull Docker image. See /tmp/docker_pull.log' && exit 1; fi",

      "docker run -d -p 80:80 containerregistryfirsthomework.azurecr.io/nginx:latest",

      "if [ $? -ne 0 ]; then echo 'Failed to run Docker container. See /tmp/docker_run.log' && exit 1; fi"
    ]
  }
}


