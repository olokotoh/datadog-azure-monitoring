# Owned by the Payments team (see .github/CODEOWNERS).
# Secrets (Datadog keys) are NOT here — they come from env / CI secrets.
# Apply: from terraform/, init with key=teams/payments.tfstate, then
#        terraform apply -var-file="teams/payments/team.tfvars"

team_name    = "payments"
display_name = "Payments"
members      = ["@payments@example.com", "@slack-payments"]
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
