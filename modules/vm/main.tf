# ---- Variables reçues depuis main.tf racine ----
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "vm_name"             { type = string }
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
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = { Module = "VM" }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP publique - une par VM
resource "azurerm_public_ip" "public_ip" {
  count               = var.vm_count
  name                = "${var.vm_name}-pip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = { Module = "VM" }
}

# NSG - règles selon l'OS choisi
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
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

  tags = { Module = "VM" }
}

# NIC - une par VM
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.vm_name}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
  tags = { Module = "VM" }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ---- VM Windows (créée seulement si vm_os_type = windows) ----
resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.vm_os_type == "windows" ? var.vm_count : 0
  name                = var.vm_count > 1 ? "${var.vm_name}-${count.index}" : var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  computer_name       = var.vm_count > 1 ? join("", [substr(var.vm_name, 0, 12), count.index]) : substr(var.vm_name, 0, 15)

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    name                 = "${var.vm_name}-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
  }

  source_image_reference {
    publisher = local.os_images[var.vm_os_image].publisher
    offer     = local.os_images[var.vm_os_image].offer
    sku       = local.os_images[var.vm_os_image].sku
    version   = "latest"
  }

  tags = { Module = "VM", OS = "windows" }
}

# ---- VM Linux (créée seulement si vm_os_type = linux) ----
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_os_type == "linux" ? var.vm_count : 0
  name                = var.vm_count > 1 ? "${var.vm_name}-${count.index}" : var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    name                 = "${var.vm_name}-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
  }

  source_image_reference {
    publisher = local.os_images[var.vm_os_image].publisher
    offer     = local.os_images[var.vm_os_image].offer
    sku       = local.os_images[var.vm_os_image].sku
    version   = "latest"
  }

  tags = { Module = "VM", OS = "linux" }
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