module AnalyticsHelper
  # Candidate only: explicitly disabled unless both runtime variables are present.
  # No token in code/build args; no query-string or client override.
  def analytics_client_config
    token = ENV["MIXPANEL_TOKEN"].to_s
    return unless ENV["IPIIA_ANALYTICS_ENABLED"] == "true" && token.match?(/\A[A-Za-z0-9_-]{8,128}\z/)

    { enabled: true, token: token, asset: asset_path("mixpanel-2.84.0.min.js") }
  end
end
