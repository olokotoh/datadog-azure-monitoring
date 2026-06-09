provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id

  # Credentials from the environment (ARM_CLIENT_ID / ARM_TENANT_ID /
  # ARM_SUBSCRIPTION_ID + OIDC, or ARM_CLIENT_SECRET). Nothing hardcoded.
}
