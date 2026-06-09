# ---------------------------------------------------------------------------
# Datadog credentials (sourced from env: TF_VAR_datadog_api_key, etc.)
# Placeholder defaults keep `init`/`validate`/`plan` runnable without secrets.
# ---------------------------------------------------------------------------
variable "datadog_api_key" {
  description = "Datadog API key. Provide via TF_VAR_datadog_api_key / DD_API_KEY secret."
  type        = string
  sensitive   = true
  default     = "REPLACE_WITH_DATADOG_API_KEY"
}

variable "datadog_app_key" {
  description = "Datadog Application key. Provide via TF_VAR_datadog_app_key / DD_APP_KEY secret."
  type        = string
  sensitive   = true
  default     = "REPLACE_WITH_DATADOG_APP_KEY"
}

variable "datadog_api_url" {
  description = "Datadog site API URL (e.g. https://api.datadoghq.eu/ for the EU site)."
  type        = string
  default     = "https://api.datadoghq.com/"

  validation {
    condition     = can(regex("^https://api\\.(datadoghq\\.(com|eu)|us[0-9]\\.datadoghq\\.com|ddog-gov\\.com)/$", var.datadog_api_url))
    error_message = "datadog_api_url must be a valid Datadog site API URL ending in '/'."
  }
}

# ---------------------------------------------------------------------------
# Team identity + services. Supplied per team via teams/<team>/team.tfvars.
# Each team is applied as its own root with its own state key.
# ---------------------------------------------------------------------------
variable "team_name" {
  description = "Team slug; primary grouping tag (team:<name>) and state-key component."
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

variable "default_tags" {
  description = "Extra tags applied to every resource for this team."
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
    condition     = length(var.services) > 0
    error_message = "A team must monitor at least one service."
  }

  validation {
    condition     = alltrue([for s in var.services : startswith(s.endpoint, "https://")])
    error_message = "Every service endpoint must be an https:// URL."
  }
}
