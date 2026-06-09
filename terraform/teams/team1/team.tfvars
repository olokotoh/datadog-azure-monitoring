# Owned by team1 (see .github/CODEOWNERS).
# Secrets (Datadog keys) are NOT here — they come from env / CI secrets.
# Apply: from terraform/, init with key=teams/team1.tfstate, then
#        terraform apply -var-file="teams/team1/team.tfvars"

team_name    = "team1"
display_name = "Team 1"
members      = ["@team1@example.com", "@slack-team1"]
default_tags = ["tier:critical"]

# List as many services as you want — each gets its own Synthetics test + monitor.
services = {
  checkout-api = {
    display_name                     = "Checkout"
    endpoint                         = "https://api.example.com/checkout/health"
    expected_status_code             = 200
    max_response_time_ms             = 800
    body_contains                    = "ok"
    locations                        = ["aws:us-east-1", "aws:eu-west-1"]
    response_time_alert_threshold_ms = 1200
    renotify_interval_minutes        = 30
  }

  refunds-api = {
    display_name  = "Refunds"
    endpoint      = "https://api.example.com/refunds/health"
    body_contains = "healthy"
  }
}
