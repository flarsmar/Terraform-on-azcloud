resource "azurerm_virtual_network_peering" "be-fe" {
  name                      = "be-fe"
  resource_group_name       = azurerm_resource_group.fe-rg.name
  virtual_network_name      = module.fe-vnet.vnet_name
  remote_virtual_network_id = module.be-vnet.vnet_id
}

resource "azurerm_virtual_network_peering" "fe-be" {
  name                      = "fe-be"
  resource_group_name       = azurerm_resource_group.be-rg.name
  virtual_network_name      = module.be-vnet.vnet_name
  remote_virtual_network_id = module.fe-vnet.vnet_id
}

resource "azurerm_firewall_nat_rule_collection" "fe-rg" {
  name                = "nat-rules"
  azure_firewall_name = azurerm_firewall.fe-rg.name
  resource_group_name = azurerm_resource_group.fe-rg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "webrule"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "80",
    ]

    destination_addresses = [
      azurerm_public_ip.fe-rg.ip_address
    ]

    translated_port = 80

    translated_address = module.web-vm.vm_private_ip

    protocols = [
      "TCP",
    ]
  }

  rule {
    name = "jboxrule"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "3389",
    ]

    destination_addresses = [
      azurerm_public_ip.fe-rg.ip_address
    ]

    translated_port = 3389

    translated_address = module.jbox-vm.vm_private_ip

    protocols = [
      "TCP",
    ]
  }
}

resource "azurerm_network_security_rule" "be-rg-01" {
  name                        = "rdp"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = module.jbox-vm.vm_private_ip
  destination_address_prefix  = module.web-vm.vm_private_ip
  resource_group_name         = azurerm_resource_group.be-rg.name
  network_security_group_name = module.web-vm.nsg_name
}