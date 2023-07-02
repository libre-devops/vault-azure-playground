module "nsg" {
  source = "registry.terraform.io/libre-devops/nsg/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  nsg_name  = "nsg-${var.short}-${var.loc}-${terraform.workspace}-01"
  subnet_id = element(values(module.network.subnets_ids), 0)
}

resource "azurerm_network_security_rule" "vault_inbound" {
  name                        = "AllowVault8200Inbound"
  priority                    = "148"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8200"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.nsg.nsg_rg_name
  network_security_group_name = module.nsg.nsg_name
}

resource "azurerm_network_security_rule" "vnet_inbound" {
  name                        = "AllowVnetInbound"
  priority                    = "149"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.nsg.nsg_rg_name
  network_security_group_name = module.nsg.nsg_name
}

resource "azurerm_network_security_rule" "bastion_inbound" {
  name                        = "AllowSSHRDPInbound"
  priority                    = "150"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.nsg.nsg_rg_name
  network_security_group_name = module.nsg.nsg_name
}

resource "azurerm_network_security_rule" "https_inbound" {
  name                        = "AllowHttpsInbound"
  priority                    = "151"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.nsg.nsg_rg_name
  network_security_group_name = module.nsg.nsg_name
}

resource "azurerm_network_security_rule" "smb_inbound" {
  name                        = "AllowSmbInbound"
  priority                    = "152"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.nsg.nsg_rg_name
  network_security_group_name = module.nsg.nsg_name
}
