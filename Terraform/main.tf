terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}

##Sudo Code###
# Create a Resource Group
# Create NSG 
# Create a Virtual Network
# data of subnets
# Create NAT gateway
# Associate NAT gateway with three subnets
# Create network interfaces for VMs
# Create three Virtual Machines

## Start ##
# Create a Resource Group

resource "azurerm_resource_group" "example" {
  name     = "k8s-rg"
  location = "East US"
}

# Create NSG 
resource "azurerm_network_security_group" "example" {
  name                = "k8s-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}


# Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "k8s-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.0.0/16"]
}

#Create Subnets
resource "azurerm_subnet" "example1" {
  name           = "subnet1"
  address_prefixes = ["10.10.0.0/24"]
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "example2" {
  name           = "subnet2"
  address_prefixes = ["10.10.2.0/24"]
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "example3" {
  name           = "subnet3"
  address_prefixes = ["10.10.4.0/24"]
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}
# NSG Association 
resource "azurerm_subnet_network_security_group_association" "example1" {
  subnet_id                 = azurerm_subnet.example1.id
  network_security_group_id = azurerm_network_security_group.example.id
}
resource "azurerm_subnet_network_security_group_association" "example2" {
  subnet_id                 = azurerm_subnet.example2.id
  network_security_group_id = azurerm_network_security_group.example.id
}
resource "azurerm_subnet_network_security_group_association" "example3" {
  subnet_id                 = azurerm_subnet.example3.id
  network_security_group_id = azurerm_network_security_group.example.id
}
# Create NAT gateway
resource "azurerm_nat_gateway" "example" {
  name                    = "nat-Gateway"
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

# Associate NAT gateway with three subnets

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.example1.id
  nat_gateway_id = azurerm_nat_gateway.example.id
}

#Create Public IP

resource "azurerm_public_ip" "example1" {
  name                = "example1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "example2" {
  name                = "example2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "example3" {
  name                = "example3"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Create network interfaces for VMs

resource "azurerm_network_interface" "example1" {
  name                = "example-nic1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.example1.id    
  }
}

resource "azurerm_network_interface" "example2" {
  name                = "example-nic2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.example2.id    
  }
}

resource "azurerm_network_interface" "example3" {
  name                = "example-nic3"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.example3.id
  }
}

# Create three Virtual Machines


resource "azurerm_linux_virtual_machine" "example1" {
  name                = "k8smaster"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D4_v4"
  admin_username      = "adminuser"
  admin_password      = "Password123#"
  disable_password_authentication = false  
  network_interface_ids = [
    azurerm_network_interface.example1.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


resource "azurerm_linux_virtual_machine" "example2" {
  name                = "k8sworker"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D4_v4"
  admin_username      = "adminuser"
  admin_password      = "Password123#"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}



resource "azurerm_linux_virtual_machine" "example3" {
  name                = "k8sobservability"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D4_v4"
  admin_username      = "adminuser"
  admin_password      = "Password123#"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example3.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}