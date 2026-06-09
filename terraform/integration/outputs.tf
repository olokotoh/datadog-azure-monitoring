output "azure_integration_id" {
  description = "ID of the Datadog Azure integration."
  value       = module.azure_integration.integration_id
}

output "role_assignment_ids" {
  description = "IDs of the Azure role assignments granted to the Datadog SP."
  value       = module.azure_integration.role_assignment_ids
}
