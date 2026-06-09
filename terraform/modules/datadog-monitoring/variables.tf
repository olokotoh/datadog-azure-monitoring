variable "team_name" {
  description = "Team slug used as the primary grouping tag (team:<name>)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}$", var.team_name))
    error_message = "team_name must be 2-31 chars, lowercase alphanumeric or hyphen, starting alphanumeric."
  }
}

variable "display_name" {
  description = "Human-friendly team name used in test/monitor titles."
  type        = string
}

variable "members" {
  description = "Datadog notification handles for this team (e.g. '@a@x.com', '@slack-team')."
  type        = list(string)

  validation {
    condition     = length(var.members) > 0
    error_message = "At least one notification handle is required."
  }
}

variable "extra_tags" {
  description = "Additional tags applied to every resource for this team."
  type        = list(string)
  default     = []
}

variable "services" {
  description = "Map of API services this team monitors. The map key is the service slug."
  type = map(object({
    endpoint                         = string
    display_name                     = optional(string)
    expected_status_code             = optional(number, 200)
    max_response_time_ms             = optional(number, 1000)
    body_contains                    = optional(string, "")
    locations                        = optional(list(string), ["aws:us-east-1"])
    tick_every_seconds               = optional(number, 300)
    response_time_alert_threshold_ms = optional(number, 1500)
    renotify_interval_minutes        = optional(number, 0)
  }))

  validation {
    condition     = alltrue([for s in var.services : startswith(s.endpoint, "https://")])
    error_message = "Every service endpoint must be an https:// URL."
  }

  validation {
    condition     = alltrue([for k in keys(var.services) : can(regex("^[a-z0-9][a-z0-9-]{1,40}$", k))])
    error_message = "Each service key must be 2-41 chars, lowercase alphanumeric or hyphen, starting alphanumeric."
  }
}
