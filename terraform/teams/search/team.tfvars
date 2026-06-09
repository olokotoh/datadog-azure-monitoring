# Owned by the Search team (see .github/CODEOWNERS).
# This team monitors a different set of services than Payments.

team_name    = "search"
display_name = "Search"
members      = ["@search@example.com"]

services = {
  search-api = {
    endpoint = "https://api.example.com/search/health"
  }

  suggest-api = {
    display_name         = "Autosuggest"
    endpoint             = "https://api.example.com/suggest/health"
    max_response_time_ms = 500
  }
}
