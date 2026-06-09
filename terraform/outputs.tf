output "azure_integration_id" {
  description = "ID of the Datadog Azure integration."
  value       = module.azure_integration.integration_id
}

output "synthetics_test_public_ids" {
  description = "Synthetics API test public ID per team."
  value       = { for k, m in module.datadog_monitoring : k => m.synthetics_test_public_id }
}

output "synthetics_test_monitor_ids" {
  description = "Built-in Synthetics monitor ID per team."
  value       = { for k, m in module.datadog_monitoring : k => m.synthetics_test_monitor_id }
}

output "response_time_monitor_ids" {
  description = "Response-time monitor ID per team."
  value       = { for k, m in module.datadog_monitoring : k => m.response_time_monitor_id }
}
