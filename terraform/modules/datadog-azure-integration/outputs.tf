output "integration_id" {
  description = "ID of the Datadog Azure integration."
  value       = datadog_integration_azure.this.id
}

output "role_assignment_ids" {
  description = "IDs of the Azure role assignments granted to the Datadog SP."
  value       = { for r, a in azurerm_role_assignment.datadog : r => a.id }
}
