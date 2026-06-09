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
  description = "Create the least-privilege Azure role assignments for the Datadog SP. Set false for a credential-free plan/demo."
  type        = bool
  default     = true
}

variable "host_filters" {
  description = "Limits Azure hosts pulled into Datadog (tag filter), e.g. 'env:prod'."
  type        = string
  default     = ""
}
