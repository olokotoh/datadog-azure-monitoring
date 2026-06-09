output "synthetics_test_public_id" {
  description = "Public ID of the Synthetics API test."
  value       = datadog_synthetics_test.api.id
}

output "synthetics_test_monitor_id" {
  description = "Built-in monitor ID associated with the Synthetics test."
  value       = datadog_synthetics_test.api.monitor_id
}

output "response_time_monitor_id" {
  description = "ID of the response-time monitor."
  value       = datadog_monitor.response_time.id
}
