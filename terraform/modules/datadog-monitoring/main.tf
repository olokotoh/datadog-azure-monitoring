locals {
  tags         = concat(["team:${var.team_name}", "managed-by:terraform"], var.extra_tags)
  notification = join(" ", var.members)
}

# Synthetics API (HTTP) test against the team's API endpoint, with assertions.
resource "datadog_synthetics_test" "api" {
  name      = "[${var.team_name}] ${var.display_name} API health"
  type      = "api"
  subtype   = "http"
  status    = "live"
  locations = var.api.locations
  tags      = local.tags
  message   = "API health check failed for ${var.display_name}.\nNotifying: ${local.notification}"

  request_definition {
    method = "GET"
    url    = var.api.endpoint
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = var.api.expected_status_code
  }

  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = var.api.max_response_time_ms
  }

  dynamic "assertion" {
    for_each = var.api.body_contains != "" ? [1] : []
    content {
      type     = "body"
      operator = "contains"
      target   = var.api.body_contains
    }
  }

  options_list {
    tick_every = var.api.tick_every_seconds

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = var.renotify_interval_minutes
    }
  }
}

# Complementary monitor tied to the test's results, notifying the team.
resource "datadog_monitor" "response_time" {
  name    = "[${var.team_name}] ${var.display_name} API response time"
  type    = "metric alert"
  message = "Response time high for ${var.display_name}. ${local.notification}"
  query   = "avg(last_5m):avg:synthetics.http.response.time{check_id:${datadog_synthetics_test.api.monitor_id}} > ${var.response_time_alert_threshold_ms}"

  monitor_thresholds {
    critical = var.response_time_alert_threshold_ms
  }

  renotify_interval = var.renotify_interval_minutes
  tags              = local.tags
}
