# Local successor: run1108 directives; independent exact-byte review pending.
# Style-only unsafe-inline supports inherited style attributes and dynamic progress widths.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self
    policy.style_src :self, :unsafe_inline, "https://fonts.googleapis.com"
    policy.font_src :self, "https://fonts.gstatic.com"
    policy.img_src :self, :data
    policy.connect_src :self, "https://api-eu.mixpanel.com"
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self
    policy.frame_src :none
    policy.frame_ancestors :self
  end
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(32) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
