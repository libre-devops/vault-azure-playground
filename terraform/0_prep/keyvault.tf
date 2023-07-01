module "keyvault" {
  source = "registry.terraform.io/libre-devops/keyvault/azurerm"

  depends_on = [
    module.roles,
    time_sleep.wait_120_seconds # Needed to allow RBAC time to propagate
  ]

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  kv_name                         = "kv-${var.short}-${var.loc}-${terraform.workspace}-01-${random_string.random.result}"
  use_current_client              = true
  give_current_client_full_access = false
  enable_rbac_authorization       = true
  purge_protection_enabled        = false
}

locals {
  secrets = {
    "${var.short}-${var.loc}-${terraform.workspace}-vault-ssh-key"  = tls_private_key.ssh_key.private_key_pem
    "${var.short}-${var.loc}-${terraform.workspace}-vault-password" = random_password.password.result
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  depends_on   = [module.roles]
  for_each     = local.secrets
  key_vault_id = module.keyvault.kv_id
  name         = each.key
  value        = each.value
}
