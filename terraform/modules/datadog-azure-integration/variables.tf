variable "tenant_id" {
  description = "Azure AD tenant (directory) ID."
  type        = string
}

variable "client_id" {
  description = "Application (client) ID of the Datadog integration service principal."
  type        = string
}

variable "client_secret" {
  description = "Client secret of the Datadog integration service principal."
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure subscription ID scoped for the role assignments."
  type        = string
}

variable "sp_object_id" {
  description = "Object ID of the Datadog service principal (role assignment principal)."
  type        = string
}

variable "manage_azure_permissions" {
  description = "Create the least-privilege Azure role assignments for the Datadog SP."
  type        = bool
  default     = true
}

variable "host_filters" {
  description = "Limits Azure hosts pulled into Datadog (tag filter), e.g. 'env:prod'."
  type        = string
  default     = ""
}

variable "metrics_enabled" {
  description = "Enable Azure metric collection."
  type        = bool
  default     = true
}

variable "resource_collection_enabled" {
  description = "Enable Azure resource collection."
  type        = bool
  default     = true
}
