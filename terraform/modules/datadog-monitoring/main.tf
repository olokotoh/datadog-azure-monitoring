locals {
  base_tags    = concat(["team:${var.team_name}", "managed-by:terraform"], var.extra_tags)
  notification = join(" ", var.members)
}

# One Synthetics API (HTTP) test per service this team monitors.
resource "datadog_synthetics_test" "api" {
  for_each = var.services

  name      = "[${var.team_name}] ${coalesce(each.value.display_name, each.key)} API health"
  type      = "api"
  subtype   = "http"
  status    = "live"
  locations = each.value.locations
  tags      = concat(local.base_tags, ["service:${each.key}"])
  message   = "API health check failed for ${coalesce(each.value.display_name, each.key)} (team ${var.display_name}).\nNotifying: ${local.notification}"

  request_definition {
    method = "GET"
    url    = each.value.endpoint
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = each.value.expected_status_code
  }

  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = each.value.max_response_time_ms
  }

  dynamic "assertion" {
    for_each = each.value.body_contains != "" ? [1] : []
    content {
      type     = "body"
      operator = "contains"
      target   = each.value.body_contains
    }
  }

  options_list {
    tick_every = each.value.tick_every_seconds

    retry {
      count    = 2
      interval = 300
    }

    monitor_options {
      renotify_interval = each.value.renotify_interval_minutes
    }
  }
}

# Complementary response-time monitor per service, tied to its test and notifying the team.
resource "datadog_monitor" "response_time" {
  for_each = var.services

  name    = "[${var.team_name}] ${coalesce(each.value.display_name, each.key)} API response time"
  type    = "metric alert"
  message = "Response time high for ${coalesce(each.value.display_name, each.key)} (team ${var.display_name}). ${local.notification}"
  query   = "avg(last_5m):avg:synthetics.http.response.time{check_id:${datadog_synthetics_test.api[each.key].monitor_id}} > ${each.value.response_time_alert_threshold_ms}"

  monitor_thresholds {
    critical = each.value.response_time_alert_threshold_ms
  }

  renotify_interval = each.value.renotify_interval_minutes
  tags              = concat(local.base_tags, ["service:${each.key}"])
}
