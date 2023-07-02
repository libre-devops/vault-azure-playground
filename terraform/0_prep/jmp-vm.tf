module "jmp_vm" {
  source = "registry.terraform.io/libre-devops/windows-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vm_amount          = 1
  vm_hostname        = "jmp${var.short}${var.loc}${terraform.workspace}"
  vm_size            = "Standard_B2ms"
  vm_os_simple       = "WindowsServer2022Gen2"
  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.jmp_vm.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = random_password.password.result // Created with the Libre DevOps Terraform Pre-Requisite script

  subnet_id            = element(values(module.network.subnets_ids), 0) // Places in sn1-vnet-ldo-euw-dev-01
  availability_zone    = "alternate"                                    // If more than 1 VM exists, places them in alterate zones, 1, 2, 3 then resetting.  If you want HA, use an availability set.
  storage_account_type = "StandardSSD_LRS"
  identity_type        = "UserAssigned"
  identity_ids         = [azurerm_user_assigned_identity.managed_id.id]
}

module "run_command_win" {
  source = "registry.terraform.io/libre-devops/run-vm-command/azurerm"

  depends_on = [module.jmp_vm] // fetches as a data reference so requires depends-on
  location   = module.rg.rg_location
  rg_name    = module.rg.rg_name
  vm_name    = element(module.jmp_vm.vm_name, 0)
  os_type    = "windows"
  tags       = module.rg.rg_tags

  command = "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) ; choco install -y git microsoft-edge azure-cli powershell-core ; New-NetFirewallRule -DisplayName 'AllowPort445Inbound' -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow"
}

resource "azurerm_virtual_machine_extension" "mount" {
  depends_on = [
    module.run_command_win
  ]
  name                 = "${element(module.jmp_vm.vm_name, 0)}-MountFileShare-${title(module.sa.sa_name)}"
  virtual_machine_id   = element(module.jmp_vm.vm_ids, 0)
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/libre-devops/utils/dev/scripts/azure/powershell/Mount-AzShare.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File Mount-AzShare.ps1 -storageAccountName ${module.sa.sa_name} -storageAccountKey ${module.sa.sa_primary_access_key} -fileShareName ${azurerm_storage_share.share.name}"
  }
  SETTINGS
}
