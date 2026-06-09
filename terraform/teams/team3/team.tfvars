# Owned by team3 (see .github/CODEOWNERS).
# team3 monitors payments + search (shared concerns) plus its own inventory service.

team_name    = "team3"
display_name = "Team 3"
members      = ["@team3@example.com", "@slack-team3"]
default_tags = ["tier:standard"]

services = {
  payments-api = {
    display_name = "Payments"
    endpoint     = "https://api.example.com/payments/health"
  }

  search-api = {
    display_name = "Search"
    endpoint     = "https://api.example.com/search/health"
  }

  inventory-api = {
    display_name                     = "Inventory"
    endpoint                         = "https://api.example.com/inventory/health"
    max_response_time_ms             = 1500
    body_contains                    = "available"
    response_time_alert_threshold_ms = 2000
  }
}
