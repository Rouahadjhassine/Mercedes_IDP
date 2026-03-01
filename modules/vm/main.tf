# ---- Variables reçues depuis main.tf racine ----
variable "prefix"              { type = string }
variable "environment"         { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "vm_count"            { type = number }
variable "vm_size"             { type = string }
variable "vm_os_type"          { type = string }
variable "vm_os_image"         { type = string }
variable "vm_disk_type"        { type = string }
variable "vm_admin_username"   { type = string }
variable "vm_admin_password" {
  type      = string
  sensitive = true
}

# ---- Map de toutes les images disponibles ----
locals {
  os_images = {
    "WindowsServer2022" = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
    }
    "WindowsServer2019" = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
    }
    "WindowsServer2016" = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
    }
    "UbuntuServer2204" = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
    }
    "UbuntuServer2004" = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
    }
    "CentOS8" = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "8_5-gen2"
    }
    "RedHat9" = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "9-lvm-gen2"
    }
  }
}

# ---- Réseau ----
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = { Environment = var.environment }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP publique - une par VM
resource "azurerm_public_ip" "public_ip" {
  count               = var.vm_count
  name                = "${var.prefix}-pip-${var.environment}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = { Environment = var.environment }
}

# NSG - règles selon l'OS choisi
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # RDP activé seulement si Windows
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = var.vm_os_type == "windows" ? "Allow" : "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # SSH activé seulement si Linux
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = var.vm_os_type == "linux" ? "Allow" : "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Environment = var.environment }
}

# NIC - une par VM
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.prefix}-nic-${var.environment}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
  tags = { Environment = var.environment }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ---- VM Windows (créée seulement si vm_os_type = windows) ----
resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.vm_os_type == "windows" ? var.vm_count : 0
  name                = "${var.prefix}-vm-win-${var.environment}-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  computer_name       = "${var.prefix}vm${count.index}"

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    name                 = "${var.prefix}-osdisk-${var.environment}-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
  }

  source_image_reference {
    publisher = local.os_images[var.vm_os_image].publisher
    offer     = local.os_images[var.vm_os_image].offer
    sku       = local.os_images[var.vm_os_image].sku
    version   = "latest"
  }

  tags = { Environment = var.environment, OS = "windows" }
}

# ---- VM Linux (créée seulement si vm_os_type = linux) ----
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_os_type == "linux" ? var.vm_count : 0
  name                = "${var.prefix}-vm-linux-${var.environment}-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    name                 = "${var.prefix}-osdisk-${var.environment}-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
  }

  source_image_reference {
    publisher = local.os_images[var.vm_os_image].publisher
    offer     = local.os_images[var.vm_os_image].offer
    sku       = local.os_images[var.vm_os_image].sku
    version   = "latest"
  }

  tags = { Environment = var.environment, OS = "linux" }
}

# ---- Outputs ----
output "vm_name" {
  value = var.vm_os_type == "windows" ? azurerm_windows_virtual_machine.vm[*].name : azurerm_linux_virtual_machine.vm[*].name
}
output "vm_public_ip"      { value = azurerm_public_ip.public_ip[*].ip_address }
output "vm_admin_username" { value = var.vm_admin_username }
output "vm_id" {
  value = var.vm_os_type == "windows" ? azurerm_windows_virtual_machine.vm[*].id : azurerm_linux_virtual_machine.vm[*].id
}