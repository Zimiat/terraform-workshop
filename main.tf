###############################################################################
# Terraform Configuration
###############################################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

###############################################################################
# Generate an SSH Key Pair
###############################################################################
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

###############################################################################
# Resource Group
###############################################################################
resource "azurerm_resource_group" "rg" {
  name     = "almalinux9-rg"
  location = "westeurope"
}

###############################################################################
# Virtual Network & Subnet
###############################################################################
resource "azurerm_virtual_network" "vnet" {
  name                = "almalinux9-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

###############################################################################
# Public IP (Static) & Network Interface
###############################################################################
resource "azurerm_public_ip" "public_ip" {
  name                = "almalinux9-publicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "almalinux9-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

###############################################################################
# AlmaLinux 9 (Gen2) Virtual Machine
###############################################################################
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "almalinux9-vm"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  network_interface_ids           = [azurerm_network_interface.nic.id]

  # Use the generated SSH public key
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    name                 = "almalinux9-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # AlmaLinux 9 Gen2 Image Reference
  source_image_reference {
    publisher = "almalinux"
    offer     = "almalinux-x86_64"
    sku       = "9-gen2"
    version   = "latest"
  }
}

###############################################################################
# Outputs
###############################################################################
output "ssh_private_key" {
  value = nonsensitive(tls_private_key.ssh_key.private_key_pem)
}

output "public_ip" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "ssh_command" {
  description = "Example SSH command to connect (once you've saved the private key)."
  value       = "ssh -i /path/to/private_key.pem azureuser@${azurerm_public_ip.public_ip.ip_address}"
}
