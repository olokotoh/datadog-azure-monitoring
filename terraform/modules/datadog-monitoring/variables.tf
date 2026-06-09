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
  description = "Additional tags applied to this team's resources."
  type        = list(string)
  default     = []
}

variable "api" {
  description = "The single API service to monitor for this team."
  type = object({
    endpoint             = string
    expected_status_code = optional(number, 200)
    max_response_time_ms = optional(number, 1000)
    body_contains        = optional(string, "")
    locations            = optional(list(string), ["aws:us-east-1"])
    tick_every_seconds   = optional(number, 300)
  })

  validation {
    condition     = startswith(var.api.endpoint, "https://")
    error_message = "api.endpoint must be an https:// URL."
  }
}

variable "response_time_alert_threshold_ms" {
  description = "Critical threshold (ms) for the response-time monitor."
  type        = number
  default     = 1500
}

variable "renotify_interval_minutes" {
  description = "Re-notification interval in minutes (0 disables re-notification)."
  type        = number
  default     = 0
}
