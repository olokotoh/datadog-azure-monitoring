resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  # Accepted-risk skips for the Terraform state backend (justified, auditable):
  #checkov:skip=CKV_AZURE_59:Public network access is required so GitHub-hosted runners can reach the remote backend; locking it down needs a VNet + self-hosted runners.
  #checkov:skip=CKV2_AZURE_33:Private endpoint not used for the same reason (public runners). Access is still restricted via AAD + TLS1.2 + no shared keys.
  #checkov:skip=CKV2_AZURE_1:Customer-managed keys (Key Vault) are out of scope for the bootstrap backend; data is still encrypted at rest with platform-managed keys.
  #checkov:skip=CKV_AZURE_33:Queue service is not used by the state backend, so queue logging is not applicable.
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  # Force Azure AD / OIDC auth to the backend; no long-lived access keys.
  shared_access_key_enabled = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  #checkov:skip=CKV2_AZURE_21:Blob read logging (storage analytics/diagnostic settings) is out of scope for the bootstrap state container.
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
