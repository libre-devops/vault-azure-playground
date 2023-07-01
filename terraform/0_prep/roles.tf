data "azurerm_role_definition" "key_vault_administrator" {
  name = "Key Vault Administrator"
}


module "roles" {
  source = "registry.terraform.io/libre-devops/custom-roles/azurerm"

  create_role = false
  assign_role = true

  roles = [
    {
      role_assignment_name                             = "SvpKvOwner"
      role_definition_id                               = format("/subscriptions/%s%s", data.azurerm_client_config.current.subscription_id, data.azurerm_role_definition.key_vault_administrator.role_definition_id)
      role_assignment_assignee_principal_id            = data.azurerm_client_config.current.object_id
      role_assignment_scope                            = format("/subscriptions/%s", data.azurerm_client_config.current.subscription_id)
      role_assignment_skip_service_principal_aad_check = true
    },
    {
      role_assignment_name                             = "MiKvOwner"
      role_definition_id                               = format("/subscriptions/%s%s", data.azurerm_client_config.current.subscription_id, data.azurerm_role_definition.key_vault_administrator.id)
      role_assignment_assignee_principal_id            = azurerm_user_assigned_identity.managed_id.principal_id
      role_assignment_scope                            = format("/subscriptions/%s", data.azurerm_client_config.current.subscription_id)
      role_assignment_skip_service_principal_aad_check = true
    }
  ]
}
