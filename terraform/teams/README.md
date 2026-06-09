# Teams

Each subfolder is one team and is owned by that team via
[`.github/CODEOWNERS`](../../.github/CODEOWNERS). A team manages **only** its own
`team.tfvars` and gets its **own Terraform state** (`teams/<team>.tfstate`), so a
team's plan/apply never touches another team's resources.

## Add a new team

1. Create `teams/<team>/team.tfvars` (copy an existing one). List any number of
   services under `services = { ... }`.
2. Add a CODEOWNERS line for `terraform/teams/<team>/`.
3. CI auto-discovers the folder — the plan/apply matrix picks it up, nothing else
   to wire.

## Apply a single team locally

```bash
cd terraform
terraform init -reconfigure \
  -backend-config="resource_group_name=$TFSTATE_RG" \
  -backend-config="storage_account_name=$TFSTATE_SA" \
  -backend-config="container_name=$TFSTATE_CONTAINER" \
  -backend-config="key=teams/<team>.tfstate"
terraform plan -var-file="teams/<team>/team.tfvars"
```

> Switching teams locally requires re-running `init -reconfigure` with the new
> `key=` (each team is a separate state). CI does this automatically per team.
