terraform {
  # Remote state in Azure Storage with automatic state locking via blob lease.
  #
  # This is a PARTIAL configuration on purpose: nothing environment-specific
  # and no secrets live in version control. Real values are supplied at init
  # time via -backend-config flags (or a *.backend.hcl file / CI secrets).
  #
  # PER-TEAM STATE: each team uses a distinct state key, so a team's apply only
  # ever touches its own services:
  #
  #   terraform init -reconfigure \
  #     -backend-config="resource_group_name=$TFSTATE_RG" \
  #     -backend-config="storage_account_name=$TFSTATE_SA" \
  #     -backend-config="container_name=$TFSTATE_CONTAINER" \
  #     -backend-config="key=teams/<team>.tfstate"
  #   terraform apply -var-file="teams/<team>/team.tfvars"
  #
  # The backing storage account + container are created once by the separate
  # ./bootstrap configuration (see bootstrap/README.md).
  backend "azurerm" {
    # Authenticate to the state backend with Azure AD / OIDC instead of a
    # storage account access key, so no long-lived key is needed.
    use_azuread_auth = true
  }
}
