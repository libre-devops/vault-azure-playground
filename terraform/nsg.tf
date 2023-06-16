module "nsg" {
  source = "registry.terraform.io/libre-devops/nsg/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  nsg_name  = "nsg-${var.short}-${var.loc}-${terraform.workspace}-01"
  subnet_id = element(values(module.network.subnets_ids), 0)
}


variable "custom_nsg_rules" {
  default = {
    "AllowVNetInbound"  = { priority = "110", direction = "Inbound", access = "Allow", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
  }
  description = "Rules to be added to nsg"
}

resource "azurerm_network_security_rule" "allow_rules" {
  for_each = var.custom_nsg_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = module.rg.rg_name
  network_security_group_name = module.nsg.nsg_name
}
