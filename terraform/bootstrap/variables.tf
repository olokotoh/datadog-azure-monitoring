variable "subscription_id" {
  description = "Azure subscription ID to create the Terraform state backend in."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "location" {
  description = "Azure region for the state resource group and storage account."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group that holds the Terraform state storage account."
  type        = string
  default     = "rg-tfstate-datadog-monitoring"
}

variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 lowercase alphanumeric)."
  type        = string
  default     = "sttfstateddmonitoring"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "container_name" {
  description = "Blob container that stores the tfstate."
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Tags applied to bootstrap resources."
  type        = map(string)
  default = {
    purpose    = "terraform-state"
    managed-by = "terraform"
  }
}
