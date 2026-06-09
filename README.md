# Datadog + Azure monitoring (Terraform)

Reusable Terraform that provisions Datadog monitoring entirely as code:

- the **Datadog ↔ Azure** integration (service-principal based), and
- **per-team API Synthetics tests + alerts**,

with **`team`** as the primary grouping dimension. Each team owns a folder and lists
**any number of services** it wants to monitor — and gets its **own Terraform state**,
so one team's `apply` never touches another's.

## Layout

```
.
├── README.md  LICENSE  .gitignore
├── .github/
│   ├── CODEOWNERS                          # each team owns its folder
│   └── workflows/                          # PR (plan) + main (apply), matrixed per team
└── terraform/
    ├── versions.tf backend.tf providers.tf variables.tf main.tf outputs.tf
    │                                        # ^ the PER-TEAM root (one team per state)
    ├── .tflint.hcl
    ├── teams/
    │   ├── README.md
    │   ├── team1/team.tfvars                # payments + search
    │   ├── team2/team.tfvars                # payments + orders
    │   └── team3/team.tfvars                # payments + search + inventory
    ├── integration/                         # Datadog↔Azure integration (own root + state)
    ├── modules/
    │   ├── datadog-azure-integration/       # integration + least-privilege Azure roles
    │   └── datadog-monitoring/              # loops over a team's services
    └── bootstrap/                           # one-time remote-state backend setup
```

### Roots & state

| Root | State key | Scope |
|---|---|---|
| `terraform/` (per team) | `teams/<team>.tfstate` | one team's services |
| `terraform/integration/` | `integration.tfstate` | the Azure integration (once) |
| `terraform/bootstrap/` | local | creates the backend (run once) |

## Prerequisites

- Terraform `>= 1.6` (CI pins `1.15.1`).
- A Datadog account (API + APP keys).
- An Azure subscription and a service principal for the Datadog integration.

## Required secrets (env / CI)

| Secret | Purpose |
|---|---|
| `DD_API_KEY` / `DD_APP_KEY` | Datadog API + Application keys |
| `ARM_CLIENT_ID` / `ARM_TENANT_ID` / `ARM_SUBSCRIPTION_ID` | Azure auth (OIDC preferred) |
| `ARM_CLIENT_SECRET` | Datadog SP secret (integration root only) |
| `TFSTATE_RG` / `TFSTATE_SA` / `TFSTATE_CONTAINER` | Remote backend location |

Nothing is hardcoded; all of the above are variables/secrets. Placeholder defaults
let `init`/`validate` run with **no real secrets**. Team `team.tfvars` files never
contain secrets.

## Quick start

```bash
cd terraform

# 1. One-time: create the remote state backend (see bootstrap/README.md)
cd bootstrap && terraform init && terraform apply && cd ..

# 2. One-time: the Datadog<->Azure integration (its own state)
cd integration
terraform init \
  -backend-config="resource_group_name=$TFSTATE_RG" \
  -backend-config="storage_account_name=$TFSTATE_SA" \
  -backend-config="container_name=$TFSTATE_CONTAINER" \
  -backend-config="key=integration.tfstate"
terraform apply
cd ..

# 3. A team (repeat per team, each with its own state key)
export TF_VAR_datadog_api_key=... TF_VAR_datadog_app_key=...
export ARM_CLIENT_ID=... ARM_TENANT_ID=... ARM_SUBSCRIPTION_ID=... ARM_USE_OIDC=true
terraform init -reconfigure \
  -backend-config="resource_group_name=$TFSTATE_RG" \
  -backend-config="storage_account_name=$TFSTATE_SA" \
  -backend-config="container_name=$TFSTATE_CONTAINER" \
  -backend-config="key=teams/team1.tfstate"
terraform plan  -var-file="teams/team1/team.tfvars"
terraform apply -var-file="teams/team1/team.tfvars"
```

### Credential-free validate

```bash
cd terraform
terraform init -backend=false && terraform validate                 # per-team root
cd integration && terraform init -backend=false && terraform validate
# For an integration plan without Azure auth, set manage_azure_permissions = false.
```

## Multi-team usage

A team = a folder under `terraform/teams/`. Each team's `team.tfvars` declares its
identity (`team_name`, `display_name`, `members`) and a `services` map. **Every
service gets its own Synthetics HTTP test + response-time monitor**, all tagged
`team:<name>` and `service:<slug>`. State is isolated per team.

### How to add a new team (e.g. team4)

`team1`, `team2`, and `team3` ship as the base. Adding `team4` later is purely additive:

1. Create `terraform/teams/team4/team.tfvars`:

   ```hcl
   team_name    = "team4"
   display_name = "Team 4"
   members      = ["@team4@example.com", "@slack-team4"]
   services = {
     some-api = {
       endpoint = "https://api.example.com/team4/health"
     }
     # add as many services as you like, each with its own assertions/thresholds
   }
   ```

2. Add a line to `.github/CODEOWNERS` for `/terraform/teams/team4/`.
3. That's it — CI auto-discovers the folder and adds it to the plan/apply matrix
   with its own state key (`teams/team4.tfstate`). No module or resource code changes.

## CI/CD

- **Pull request** (`terraform-pr.yml`): `fmt -check` → `validate` (both roots) →
  `tflint` → `checkov`, then a **per-team `plan` matrix** + an integration `plan`,
  each posted as its own PR comment.
- **Merge to `main`** (`terraform-apply.yml`): applies the **integration** first,
  then a **per-team `apply` matrix**, each against its own state key, behind a
  protected `production` environment.

Teams are discovered automatically from `terraform/teams/*/`. Azure auth uses
**OIDC** (`ARM_USE_OIDC=true`). Action versions are pinned; convert version tags to
commit SHAs (e.g. via Dependabot) for the strictest supply-chain posture.

## State & locking

Remote state lives in Azure Storage; locking is automatic via **blob lease**, and
each team/root uses a distinct state key. The backend uses Azure AD auth
(`use_azuread_auth = true`) — grant the runner `Storage Blob Data Contributor` on
the storage account.

## Quality gates

`terraform fmt`, `terraform validate`, `tflint` (+ azurerm ruleset), and `checkov`
all run in CI. Provider and `required_version` constraints are pinned.
