output "synthetics_test_public_ids" {
  description = "Public ID of each Synthetics API test, keyed by service slug."
  value       = { for k, t in datadog_synthetics_test.api : k => t.id }
}

output "synthetics_test_monitor_ids" {
  description = "Built-in Synthetics monitor ID, keyed by service slug."
  value       = { for k, t in datadog_synthetics_test.api : k => t.monitor_id }
}

output "response_time_monitor_ids" {
  description = "Response-time monitor ID, keyed by service slug."
  value       = { for k, m in datadog_monitor.response_time : k => m.id }
}
