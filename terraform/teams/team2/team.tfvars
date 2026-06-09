# Owned by team2 (see .github/CODEOWNERS).
# team2 monitors payments (shared concern) plus its own orders service.

team_name    = "team2"
display_name = "Team 2"
members      = ["@team2@example.com", "@slack-team2"]

services = {
  payments-api = {
    display_name = "Payments"
    endpoint     = "https://api.example.com/payments/health"
  }

  orders-api = {
    display_name                     = "Orders"
    endpoint                         = "https://api.example.com/orders/health"
    max_response_time_ms             = 1000
    body_contains                    = "healthy"
    response_time_alert_threshold_ms = 1500
  }
}
