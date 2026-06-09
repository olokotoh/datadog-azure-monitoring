# Configure the Datadog <-> Azure integration once, and (optionally) grant the
# Datadog service principal the least-privilege roles it needs on Azure.
module "azure_integration" {
  source = "./modules/datadog-azure-integration"

  tenant_id                = var.azure_tenant_id
  client_id                = var.azure_client_id
  client_secret            = var.azure_client_secret
  subscription_id          = var.azure_subscription_id
  sp_object_id             = var.azure_sp_object_id
  manage_azure_permissions = var.manage_azure_permissions
}

# Per-team API monitoring. Adding a team is a single entry in var.teams.
module "datadog_monitoring" {
  source   = "./modules/datadog-monitoring"
  for_each = var.teams

  team_name    = each.key
  display_name = each.value.display_name
  members      = each.value.members
  extra_tags   = each.value.tags
  api          = each.value.api

  response_time_alert_threshold_ms = each.value.response_time_alert_threshold_ms
  renotify_interval_minutes        = each.value.renotify_interval_minutes
}
