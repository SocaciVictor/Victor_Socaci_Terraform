# Configuratia pentru Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

# Declarația provider-ului
provider "azurerm" {
  subscription_id = "d4ecd8ca-959f-44dd-aace-d25cec910ab5"
  features {}
}

# Variabile de intrare
variable "vm_count" {
  description = "Numărul de mașini virtuale de creat"
  default     = 2
}

variable "vm_size" {
  description = "Dimensiunea mașinii virtuale"
  default     = "Standard_B1s"
}

variable "vm_image" {
  description = "Imaginea pentru sistemul de operare al mașinii virtuale"
  default     = "18.04-LTS:latest"
}

# Resurse Terraform
resource "azurerm_resource_group" "resourse_group" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "example-network"
  location            = azurerm_resource_group.resourse_group.location
  resource_group_name = azurerm_resource_group.resourse_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resourse_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.vm_count
  name                = "example-public-ip-${count.index}"
  resource_group_name = azurerm_resource_group.resourse_group.name
  location            = azurerm_resource_group.resourse_group.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "example-nic-${count.index}"
  location            = azurerm_resource_group.resourse_group.location
  resource_group_name = azurerm_resource_group.resourse_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "random_password" "password" {
  count   = var.vm_count
  length  = 16
  special = true
}

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
    offer     = "UbuntuServer"
    sku       = var.vm_image 
    version   = "latest"
  }

  computer_name                  = "hostname-${count.index}"
  disable_password_authentication = false
}

