terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "learning-rg" {
  name     = "learning-resources"
  location = "East Us"
  tags = {
    environment = "dev"
    owner       = "Ashutosh Mishra"
  }
}

resource "azurerm_virtual_network" "learning-vn" {
  name                = "learning-vn"
  resource_group_name = azurerm_resource_group.learning-rg.name
  location            = azurerm_resource_group.learning-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "learning-sub" {
  name                 = "learning-subnet"
  resource_group_name  = azurerm_resource_group.learning-rg.name
  virtual_network_name = azurerm_virtual_network.learning-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "learning-nsg" {
  name                = "learning-nsg"
  location            = azurerm_resource_group.learning-rg.location
  resource_group_name = azurerm_resource_group.learning-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "learning-dev-rule" {
  name                        = "learning-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.learning-rg.name
  network_security_group_name = azurerm_network_security_group.learning-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "learning-sga" {
  subnet_id                 = azurerm_subnet.learning-sub.id
  network_security_group_id = azurerm_network_security_group.learning-nsg.id
}

resource "azurerm_public_ip" "learning-ip" {
  name                = "learning-ip"
  resource_group_name = azurerm_resource_group.learning-rg.name
  location            = azurerm_resource_group.learning-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "learning-nic" {
  name                = "learning-nic"
  location            = azurerm_resource_group.learning-rg.location
  resource_group_name = azurerm_resource_group.learning-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.learning-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.learning-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "learning-vm" {
  name                = "learning-vm"
  resource_group_name = azurerm_resource_group.learning-rg.name
  location            = azurerm_resource_group.learning-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.learning-nic.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "learning-data" {
    name = azurerm_public_ip.learning-ip.name
    resource_group_name = azurerm_resource_group.learning-rg.name
}