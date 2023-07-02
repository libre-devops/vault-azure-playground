module "sa" {
  source = "registry.terraform.io/libre-devops/storage-account/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  storage_account_name = lower("st${var.short}${var.loc}${terraform.workspace}01")
  access_tier          = "Hot"
  identity_type        = "SystemAssigned"

  storage_account_properties = {

    // Set this block to enable network rules
    network_rules = {
      default_action = "Allow"
      bypass         = ["AzureServices", "Metrics", "Logging"]
      ip_rules       = []
      subnet_ids     = []
    }

    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      default_service_version  = "2020-06-12"
      last_access_time_enabled = false

      deletion_retention_policies = {
        days = 10
      }

      container_delete_retention_policy = {
        days = 10
      }
    }

    routing = {
      publish_internet_endpoints  = false
      publish_microsoft_endpoints = true
      choice                      = "MicrosoftRouting"
    }
  }
}

resource "azurerm_storage_share" "share" {
  name                 = "share1"
  storage_account_name = module.sa.sa_name
  quota                = 50
}

locals {
  files = {
    "tls.cer"    = "tls.cer"
    "tls.key"    = "tls.key"
    "vault.hcl"  = "vault.hcl"
    "nginx.conf" = "nginx.conf"
  }
}

resource "azurerm_storage_share_file" "files" {
  for_each         = local.files
  name             = each.key
  storage_share_id = azurerm_storage_share.share.id
  source           = each.value
}
