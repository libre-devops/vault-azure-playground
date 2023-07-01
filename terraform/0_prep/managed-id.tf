resource "azurerm_user_assigned_identity" "managed_id" {
  resource_group_name = module.rg.rg_name
  tags                = module.rg.rg_tags
  location            = module.rg.rg_location
  name                = "${var.short}-${var.loc}-${terraform.workspace}-vault-id"
}

resource "azurerm_role_assignment" "mi_owner" {
  principal_id                     = azurerm_user_assigned_identity.managed_id.principal_id
  scope                            = format("/providers/Microsoft.Management/managementGroups/%s", data.azurerm_client_config.current.tenant_id)
  role_definition_name             = "Owner"
  skip_service_principal_aad_check = true
}
