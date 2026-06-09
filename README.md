# Datadog + Azure monitoring (Terraform)

Reusable Terraform that provisions Datadog monitoring entirely as code:

- the **Datadog ↔ Azure** integration (service-principal based), and
- a **per-team API Synthetics test + alert**,

with **`team`** as the primary grouping dimension. Adding a team is a single entry
in the `teams` map — no code changes.

## Layout

```
.
├── README.md  LICENSE  .gitignore
├── .github/workflows/                   # PR (plan) + main (apply) pipelines
└── terraform/
    ├── versions.tf backend.tf providers.tf variables.tf main.tf outputs.tf
    ├── terraform.tfvars.example .tflint.hcl
    ├── modules/
    │   ├── datadog-azure-integration/   # integration + least-privilege Azure roles
    │   └── datadog-monitoring/          # per-team Synthetics test + monitor
    └── bootstrap/                       # one-time remote-state backend setup
```

## Prerequisites

- Terraform `>= 1.6` (CI pins `1.15.1`).
- A Datadog account (API + APP keys).
- An Azure subscription and a service principal for the Datadog integration.

## Required secrets (env / CI)

| Secret | Purpose |
|---|---|
| `DD_API_KEY` / `DD_APP_KEY` | Datadog API + Application keys |
| `ARM_CLIENT_ID` / `ARM_TENANT_ID` / `ARM_SUBSCRIPTION_ID` | Azure auth (OIDC preferred) |
| `ARM_CLIENT_SECRET` | Datadog SP secret (passed to the integration) |
| `TFSTATE_RG` / `TFSTATE_SA` / `TFSTATE_CONTAINER` | Remote backend location |

Nothing is hardcoded; all of the above are variables/secrets. Placeholder defaults
let `init`/`validate` run with **no real secrets**.

## Quick start

```bash
cd terraform

# 1. One-time: create the remote state backend (see bootstrap/README.md)
cd bootstrap && terraform init && terraform apply && cd ..

# 2. Init the root against the remote backend
terraform init \
  -backend-config="resource_group_name=$TFSTATE_RG" \
  -backend-config="storage_account_name=$TFSTATE_SA" \
  -backend-config="container_name=$TFSTATE_CONTAINER" \
  -backend-config="key=datadog-azure-monitoring.tfstate"

# 3. Validate / plan / apply
export TF_VAR_datadog_api_key=... TF_VAR_datadog_app_key=...
export ARM_CLIENT_ID=... ARM_TENANT_ID=... ARM_SUBSCRIPTION_ID=... ARM_USE_OIDC=true
terraform validate
terraform plan
terraform apply
```

### Credential-free validate/plan

```bash
terraform init -backend=false
terraform validate          # passes with placeholder defaults
# For plan without Azure auth, set manage_azure_permissions = false.
```

## Multi-team usage

Teams are driven by the `teams` map (`for_each`). Each team gets its own Synthetics
test and monitor, all tagged `team:<name>`.

### How to add a new team

Append one block to `teams` (in `terraform.tfvars` or your `TF_VAR_teams`):

```hcl
teams = {
  # ... existing teams ...
  team3 = {
    display_name = "Notifications"
    members      = ["@notifications@example.com", "@slack-notifs"]
    api = {
      endpoint = "https://api.example.com/notifications/health"
    }
  }
}
```

Then `terraform plan && terraform apply`. No module or resource code changes.

## CI/CD

- **Pull request** (`terraform-pr.yml`): `fmt -check` → `init -backend=false` →
  `validate` → `tflint` → `checkov` → remote `init` → `plan` (posted as a PR comment).
- **Merge to `main`** (`terraform-apply.yml`): `init` → `apply` against the locked
  remote backend, behind a protected `production` environment.

Azure auth uses **OIDC** (`ARM_USE_OIDC=true`, no long-lived secret for login).
Action versions are pinned; convert the version tags to commit SHAs (e.g. via
Dependabot) for the strictest supply-chain posture.

## State & locking

Remote state lives in Azure Storage; locking is automatic via **blob lease**.
The backend uses Azure AD auth (`use_azuread_auth = true`) — grant the runner the
`Storage Blob Data Contributor` role on the storage account.

## Quality gates

`terraform fmt`, `terraform validate`, `tflint` (+ azurerm ruleset), and `checkov`
all run in CI. Provider and `required_version` constraints are pinned.
