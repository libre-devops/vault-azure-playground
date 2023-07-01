resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "public_ssh_key" {
  resource_group_name = module.rg.rg_name
  tags                = module.rg.rg_tags
  location            = module.rg.rg_location
  name                = "ssh-${var.short}-${var.loc}-${terraform.workspace}-pub-vault"
  public_key          = tls_private_key.ssh_key.public_key_openssh
}
