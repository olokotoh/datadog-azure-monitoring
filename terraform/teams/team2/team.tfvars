# Owned by team2 (see .github/CODEOWNERS).
# This team monitors a different set of services than team1.

team_name    = "team2"
display_name = "Team 2"
members      = ["@team2@example.com"]

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
