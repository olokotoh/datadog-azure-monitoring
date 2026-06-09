# Datadog pulls Azure metrics automatically using this service-principal-based
# integration. All credential values come from the caller as variables.
resource "datadog_integration_azure" "this" {
  tenant_name                 = var.tenant_id
  client_id                   = var.client_id
  client_secret               = var.client_secret
  host_filters                = var.host_filters
  metrics_enabled             = var.metrics_enabled
  resource_collection_enabled = var.resource_collection_enabled
}

# Least-privilege roles Datadog recommends to read Azure monitoring data.
locals {
  datadog_roles = ["Monitoring Reader", "Reader"]
}

resource "azurerm_role_assignment" "datadog" {
  for_each = var.manage_azure_permissions ? toset(local.datadog_roles) : toset([])

  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = each.value
  principal_id         = var.sp_object_id
}
