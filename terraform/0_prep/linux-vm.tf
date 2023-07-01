
module "linux_vm" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vm_amount                  = 1
  vm_hostname                = "lnx${var.short}${var.loc}${terraform.workspace}"
  vm_size                    = "Standard_B4ms"
  use_simple_image_with_plan = false
  vm_os_simple               = "Ubuntu22.04"
  vm_os_disk_size_gb         = "127"
  custom_data                = data.template_cloudinit_config.config.rendered
  user_data                  = base64encode(data.azurerm_client_config.current.tenant_id)

  asg_name = "asg-${element(regexall("[a-z]+", element(module.linux_vm.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key

  subnet_id            = element(values(module.network.subnets_ids), 0)
  availability_zone    = "alternate"
  storage_account_type = "StandardSSD_LRS"
  identity_type        = "UserAssigned"
  identity_ids         = [azurerm_user_assigned_identity.managed_id.id]
}

locals {
  principal_id_map = {
    for k, v in element(module.linux_vm.vm_identity[*], 0) : k => v.principal_id
  }

  principal_id_string = element(values(local.principal_id_map), 0)
}

