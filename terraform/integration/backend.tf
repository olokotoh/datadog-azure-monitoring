terraform {
  # The Datadog<->Azure integration is a once-per-subscription concern, so it
  # gets its own state, separate from any team:
  #
  #   terraform init \
  #     -backend-config="resource_group_name=$TFSTATE_RG" \
  #     -backend-config="storage_account_name=$TFSTATE_SA" \
  #     -backend-config="container_name=$TFSTATE_CONTAINER" \
  #     -backend-config="key=integration.tfstate"
  #
  # Partial config (no secrets / env-specific values committed). Locking via
  # Azure blob lease; AAD/OIDC auth to the backend.
  backend "azurerm" {
    use_azuread_auth = true
  }
}
