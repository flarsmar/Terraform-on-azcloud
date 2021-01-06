variable "vm-name" {
  type    = string
  default = "vm-name"
}
variable "subnet_id" {
  type    = string
  default = "subnet_id"
}
variable "location" {
  type    = string
  default = "westeurope"
}
variable "rg" {
  type    = string
  default = "resource_group_name"
}
variable "admin_password" {
  type    = string
  default = "Password1234!"
}
variable "vm_image_reference" {
  type = map(any)
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}


variable "vm_os_disk" {
  type = map(any)
  default = {
    caching      = "ReadWrite"
    storage_type = "StandardSSD_LRS"
  }
}
