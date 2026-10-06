require "test_helper"

class AnalyticsSdkCandidateTest < ActionDispatch::IntegrationTest
  test "env candidate is silent unless explicitly enabled with token" do
    ENV.delete("MIXPANEL_TOKEN")
    ENV.delete("IPIIA_ANALYTICS_ENABLED")
    get "/contacto.html"
    assert_select "[data-analytics-consent]", count: 0
    FileUtils.mkdir_p(Rails.root.join("tmp/sdk-evidence"))
    File.write(Rails.root.join("tmp/sdk-evidence/disabled-page.html"), response.body)
    ENV["MIXPANEL_TOKEN"] = "SDK_CANDIDATE_DUMMY_NO_PROJECT"
    get "/contacto.html"
    assert_select "[data-analytics-consent]", count: 0
    ENV["IPIIA_ANALYTICS_ENABLED"] = "true"
    ENV["MIXPANEL_TOKEN"] = "malformed <token>"
    get "/contacto.html"
    assert_select "[data-analytics-consent]", count: 0
  ensure
    ENV.delete("MIXPANEL_TOKEN")
    ENV.delete("IPIIA_ANALYTICS_ENABLED")
  end

  test "dummy env renders equal explicit choice and lazy same-origin asset candidate" do
    ENV["IPIIA_ANALYTICS_ENABLED"] = "true"
    ENV["MIXPANEL_TOKEN"] = "SDK_CANDIDATE_DUMMY_NO_PROJECT"
    get "/contacto.html"
    assert_response :success
    assert_select "[data-analytics-consent]", count: 1
    assert_select "button[data-consent-choice='accept']", text: "Aceitar analytics"
    assert_select "button[data-consent-choice='reject']", text: "Rejeitar analytics"
    assert_select "button[data-consent-choice='revoke'][hidden]", count: 1
    assert_select "script[src*='mixpanel']", count: 0
    panel = Nokogiri::HTML(response.body).at_css("[data-analytics-consent]")
    config = JSON.parse(panel["data-config"])
    assert_equal "SDK_CANDIDATE_DUMMY_NO_PROJECT", config["token"]
    assert_match %r{\A/assets/mixpanel-2\.84\.0}, config["asset"]
    imports = JSON.parse(Nokogiri::HTML(response.body).at_css('script[type="importmap"]').text)["imports"]
    assert_match %r{\A/assets/analytics/sdk}, imports["analytics/sdk"]
    assert_match %r{\A/assets/analytics/consent}, imports["analytics/consent"]
    FileUtils.mkdir_p(Rails.root.join("tmp/sdk-evidence"))
    File.write(Rails.root.join("tmp/sdk-evidence/cmp.html"), panel.to_html)
    File.write(Rails.root.join("tmp/sdk-evidence/default-page.html"), response.body)
  ensure
    ENV.delete("MIXPANEL_TOKEN")
    ENV.delete("IPIIA_ANALYTICS_ENABLED")
  end
end
