module "dns" {
  source                           = "registry.terraform.io/libre-devops/private-dns-zone/azurerm"
  location                         = module.rg.rg_location
  rg_name                          = module.rg.rg_name
  create_default_privatelink_zones = false
  create_reverse_dns_zone          = true
  private_dns_zone_name            = "azure.libredevops.org"
  address_range                    = module.network.vnet_address_space
  link_to_vnet                     = true
  vnet_id                          = module.network.vnet_id
}

# Add hosts to a basic DNS zone to save editing /etc/hosts
locals {
  dns_entries = {
    vault = element(module.linux_vm.nic_ip_private_ip, 0)
  }
}

resource "azurerm_private_dns_a_record" "dns_record" {
  for_each            = local.dns_entries
  name                = each.key
  zone_name           = element(module.dns.dns_zone_name, 0)
  resource_group_name = module.rg.rg_name
  tags                = module.rg.rg_tags
  ttl                 = 300
  records             = [each.value]
}

