# These four values are the -backend-config inputs for the root `terraform init`.
output "resource_group_name" {
  description = "resource_group_name for the azurerm backend."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "storage_account_name for the azurerm backend."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "container_name for the azurerm backend."
  value       = azurerm_storage_container.tfstate.name
}

output "backend_key_hint" {
  description = "Suggested state key for the root module."
  value       = "datadog-azure-monitoring.tfstate"
}
