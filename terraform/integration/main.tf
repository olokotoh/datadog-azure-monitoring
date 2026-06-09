# Configure the Datadog <-> Azure integration once for the subscription, and
# (optionally) grant the Datadog service principal the least-privilege roles.
module "azure_integration" {
  source = "../modules/datadog-azure-integration"

  tenant_id                = var.azure_tenant_id
  client_id                = var.azure_client_id
  client_secret            = var.azure_client_secret
  subscription_id          = var.azure_subscription_id
  sp_object_id             = var.azure_sp_object_id
  manage_azure_permissions = var.manage_azure_permissions
  host_filters             = var.host_filters
}
