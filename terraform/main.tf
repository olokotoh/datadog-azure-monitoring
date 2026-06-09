# Per-team root: one team per apply, with its own state key
# (teams/<team>.tfstate). Identity + services come from teams/<team>/team.tfvars.
# The Datadog<->Azure integration lives in ../integration (its own root/state).
module "datadog_monitoring" {
  source = "./modules/datadog-monitoring"

  team_name    = var.team_name
  display_name = var.display_name
  members      = var.members
  extra_tags   = var.default_tags
  services     = var.services
}
