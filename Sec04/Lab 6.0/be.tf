
resource "azurerm_resource_group" "be-rg" {
  name     = "${var.env}-be-rg"
  location = var.location-name
}

module "be-vnet" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.be-rg.name
  address_space       = "10.0.2.0/23"
  subnet_prefixes     = ["10.0.2.0/24"]
  subnet_names        = ["${var.env}-web-subnet"]
  vnet_name           = "${var.env}-web-vnet"
  tags                = null

  depends_on = [azurerm_resource_group.be-rg]
}

/*
resource "azurerm_virtual_network" "be-rg" {
  name                = "${var.env}-web-vnet"
  address_space       = ["10.0.2.0/23"]
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name
}

resource "azurerm_subnet" "be-rg" {
  name                 = "${var.env}-web-subnet"
  resource_group_name  = azurerm_resource_group.be-rg.name
  virtual_network_name = azurerm_virtual_network.be-rg.name
  address_prefixes     = ["10.0.2.0/24"]
}
*/

module "web-vm" {
  source         = "../modules/compute"
  vm-name        = "${var.env}-web"
  subnet_id      = module.be-vnet.vnet_subnets[0]
  location       = azurerm_resource_group.be-rg.location
  rg             = azurerm_resource_group.be-rg.name
  admin_password = data.azurerm_key_vault_secret.kv01.value
}

resource "azurerm_network_security_rule" "be-rg" {
  name                        = "web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "${module.web-vm.vm_private_ip}/32"
  resource_group_name         = azurerm_resource_group.be-rg.name
  network_security_group_name = module.web-vm.nsg_name
}

resource "azurerm_network_interface_security_group_association" "be-rg" {
  network_interface_id      = module.web-vm.nic_id
  network_security_group_id = module.web-vm.nsg_id
}

resource "azurerm_virtual_machine_extension" "be-rg" {
  name                 = "iis-extension"
  virtual_machine_id   = module.web-vm.vm_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools;"
    }
SETTINGS
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "be-rg" {
  virtual_machine_id = module.web-vm.vm_id
  location           = azurerm_resource_group.be-rg.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.be-rg.com"
  }
}
