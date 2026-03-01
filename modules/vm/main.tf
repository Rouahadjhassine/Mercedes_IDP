variable "prefix"              { type = string }
variable "environment"         { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "vm_size"             { type = string }
variable "vm_admin_username"   { type = string }
variable "vm_admin_password" {
  type      = string
  sensitive = true
}
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

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = { Environment = var.environment }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Environment = var.environment }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = { Environment = var.environment }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${var.prefix}-vm-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    name                 = "${var.prefix}-osdisk-${var.environment}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  tags = { Environment = var.environment }
}

output "vm_name"           { value = azurerm_windows_virtual_machine.vm.name }
output "vm_public_ip"      { value = azurerm_public_ip.public_ip.ip_address }
output "vm_admin_username" { value = azurerm_windows_virtual_machine.vm.admin_username }
output "vm_id"             { value = azurerm_windows_virtual_machine.vm.id }