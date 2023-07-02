
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

  custom_data = base64encode(<<-EOF
    #cloud-config
    package_upgrade: true
    package_update: true

    packages:
      - cifs-utils
      - lsof
      - gpg
      - curl
      - wget
      - jq
      - nano
      - apt-transport-https

    runcmd:
      - apt-get update
      - apt-get dist-upgrade
      - sh -c 'wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg'
      - sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list'
      - mkdir -p /etc/vault.d
      - adduser vault
      - adduser nginx
      - mkdir -p /etc/nginx
      - chown -R nginx:nginx /etc/nginx
      - apt-get update
      - apt-get install -y vault
      - chown vault:vault /etc/vault.d/vault.hcl
      - sh -c 'echo export VAULT_ADDR="http://127.0.0.1:8200" >> /etc/environment'
      - systemctl daemon-reload
      - systemctl start vault
      - systemctl enable vault
      - STORAGE_ACCOUNT_NAME=${module.sa.sa_name}
      - STORAGE_ACCOUNT_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
      - MNT_PATH="/mnt/${module.sa.sa_name}"
      - SMB_PATH="//${STORAGE_ACCOUNT_NAME}.file.core.windows.net/${azurerm_storage_share.share.name}"
      - mkdir -p $MNT_PATH
      - mount -t cifs $SMB_PATH $MNT_PATH -o vers=3.0,username=$STORAGE_ACCOUNT_NAME,password=$STORAGE_ACCOUNT_KEY,serverino,nosharesock,actimeo=30,mfsymlinks
      - echo "$SMB_PATH $MNT_PATH cifs vers=3.0,username=$STORAGE_ACCOUNT_NAME,password=$STORAGE_ACCOUNT_KEY,serverino,nosharesock,actimeo=30,mfsymlinks 0 0" >> /etc/fstab
    EOF
  )

  user_data = base64encode(data.azurerm_client_config.current.tenant_id)

  asg_name = "asg-${element(regexall("[a-z]+", element(module.linux_vm.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = random_password.password.result
  ssh_public_key = azurerm_ssh_public_key.public_ssh_key.public_key

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

