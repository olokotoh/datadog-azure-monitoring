terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
  }

  # Bootstrap intentionally uses LOCAL state: it creates the very storage
  # account that the root module then uses as its remote backend.
}
