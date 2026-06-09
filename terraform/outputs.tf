output "team_name" {
  description = "The team this state manages."
  value       = var.team_name
}

output "synthetics_test_public_ids" {
  description = "Synthetics API test public ID per service."
  value       = module.datadog_monitoring.synthetics_test_public_ids
}

output "synthetics_test_monitor_ids" {
  description = "Built-in Synthetics monitor ID per service."
  value       = module.datadog_monitoring.synthetics_test_monitor_ids
}

output "response_time_monitor_ids" {
  description = "Response-time monitor ID per service."
  value       = module.datadog_monitoring.response_time_monitor_ids
}
