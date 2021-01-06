resource "azurerm_network_interface" "compute" {
  name                = "${var.vm-name}-nic"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "compute" {
  name                = "${var.vm-name}-nsg"
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_windows_virtual_machine" "compute" {
  name                = "${var.vm-name}-vm01"
  location            = var.location
  resource_group_name = var.rg
  size                = var.vm_size
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.compute.id
  ]

  os_disk {
    caching              = var.vm_os_disk["caching"]
    storage_account_type = var.vm_os_disk["storage_type"]
  }

  source_image_reference {
    publisher = var.vm_image_reference["publisher"]
    offer     = var.vm_image_reference["offer"]
    sku       = var.vm_image_reference["sku"]
    version   = var.vm_image_reference["version"]
  }
}
