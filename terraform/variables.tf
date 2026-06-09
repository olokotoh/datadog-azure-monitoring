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
# Azure service principal for the Datadog integration (never hardcoded).
# ---------------------------------------------------------------------------
variable "azure_subscription_id" {
  description = "Azure subscription ID Datadog will pull metrics from."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "azure_tenant_id" {
  description = "Azure AD tenant (directory) ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "azure_client_id" {
  description = "Application (client) ID of the Datadog integration service principal."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "azure_client_secret" {
  description = "Client secret of the Datadog integration service principal."
  type        = string
  sensitive   = true
  default     = "REPLACE_WITH_AZURE_CLIENT_SECRET"
}

variable "azure_sp_object_id" {
  description = "Object ID of the Datadog service principal (used for Azure role assignments)."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "manage_azure_permissions" {
  description = "Whether to create the least-privilege Azure role assignments for the Datadog SP. Set false for a credential-free plan/demo."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Teams — the primary grouping dimension. Add a team = one map entry.
# ---------------------------------------------------------------------------
variable "teams" {
  description = "Map of teams to monitor. Key is the team slug; each value defines members, tags, and one API service to monitor."
  type = map(object({
    display_name = string
    members      = list(string)
    tags         = optional(list(string), [])
    api = object({
      endpoint             = string
      expected_status_code = optional(number, 200)
      max_response_time_ms = optional(number, 1000)
      body_contains        = optional(string, "")
      locations            = optional(list(string), ["aws:us-east-1"])
      tick_every_seconds   = optional(number, 300)
    })
    response_time_alert_threshold_ms = optional(number, 1500)
    renotify_interval_minutes        = optional(number, 0)
  }))
  default = {}

  validation {
    condition     = alltrue([for t in var.teams : length(t.members) > 0])
    error_message = "Each team must define at least one notification handle in members."
  }

  validation {
    condition     = alltrue([for t in var.teams : startswith(t.api.endpoint, "https://")])
    error_message = "Each team's api.endpoint must be an https:// URL."
  }
}
