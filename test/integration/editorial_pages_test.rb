require "test_helper"

class EditorialPagesTest < ActionDispatch::IntegrationTest
  PACK = JSON.parse(File.read(Rails.root.join("test/fixtures/files/editorial_pack_01.json")))

  test "approved pages preserve ordered content metadata five sources and real links" do
    host! "ipiia.pt"
    PACK.fetch("pages").each do |page|
      get page.fetch("path")
      assert_response :success
      doc = Nokogiri::HTML(response.body)
      assert_equal page.fetch("title"), doc.at_css("title").text
      assert_equal page.fetch("description"), doc.at_css('meta[name="description"]')["content"]
      assert_equal [ page.fetch("h1") ], doc.css("h1").map(&:text)
      assert_equal "http://ipiia.pt#{page.fetch('path')}", doc.at_css('link[rel="canonical"]')["href"]
      assert_equal doc.at_css('link[rel="canonical"]')["href"], doc.at_css('meta[property="og:url"]')["content"]
      schema = JSON.parse(doc.at_css('script[type="application/ld+json"]').text)
      assert_equal "WebPage", schema.fetch("@type")
      assert_equal "https://ipiia.pt#{page.fetch('path')}", schema.fetch("@id")
      blocks = doc.css("[data-approved-editorial] h2, [data-approved-editorial] h3, [data-approved-editorial] p, [data-approved-editorial] li, [data-approved-editorial] th, [data-approved-editorial] td").map { |n| n.text.strip }
      expected = page.fetch("blocks").map { |s| s.gsub(/\[([^\]]+)\]\(([^)]+)\)/, '\\1') }
      assert_equal expected, blocks, "Every approved block and table cell must remain ordered and exact"
      assert_equal page.fetch("source_urls"), doc.css(".editorial-sources a").map { |n| n["href"] }
      assert_equal 5, doc.css(".editorial-sources li[id]").size
      assert_select "main", count: 1
      assert_select "table caption", count: 1
      assert_select 'th[scope="col"]', minimum: 2
      assert_select 'th[scope="row"]', minimum: 1
      assert_select '.editorial-table[tabindex="0"][role="region"][aria-label]', count: 1
      assert_select "a[data-analytics-cta='#{page.fetch('cta_id')}'][href='#{page.fetch('cta_destination')}']", text: page.fetch("cta_label")
      assert_select "a[download]", count: 0
      assert_select "[data-analytics-consent]", count: 0
      doc.css("main a").each do |link|
        href = link["href"]
        if href.start_with?("/")
          slug = URI.parse(href).path.delete_prefix("/").delete_suffix(".html")
          assert PagesController::PAGES.key?(slug), "Unknown internal destination #{href}"
        elsif href.start_with?("#")
          assert doc.at_css("[id='#{href.delete_prefix('#')}']"), "Missing citation destination #{href}"
        end
      end
      assert_not_includes doc.at_css("[data-approved-editorial]").text, "—"
      assert_no_match(/\b(?:revolutionary)\b/i, doc.at_css("[data-approved-editorial]").text)
      get "/#{page.fetch('slug')}"
      assert_response :success
      assert_select 'link[rel="canonical"]', href: "http://ipiia.pt#{page.fetch('path')}"
    end
  end

  test "sitemap and incoming links include both approved URLs without invented dates" do
    doc = Nokogiri::XML(File.read(Rails.root.join("public/sitemap.xml")))
    locs = doc.xpath("//*[local-name()='loc']").map(&:text)
    PACK.fetch("pages").each do |page|
      assert_equal 1, locs.count("https://ipiia.pt#{page.fetch('path')}")
    end
    assert_empty doc.xpath("//*[local-name()='lastmod']")
    get "/"
    assert_response :success
    PACK.fetch("pages").each { |page| assert_select "footer a[href='#{page.fetch('path')}']", count: 1 }
  end

  test "full rendered editorial candidate includes genuine CMP only with dummy explicit env" do
    ENV["IPIIA_ANALYTICS_ENABLED"] = "true"
    ENV["MIXPANEL_TOKEN"] = "SDK_CANDIDATE_DUMMY_NO_PROJECT"
    FileUtils.mkdir_p(Rails.root.join("tmp/editorial-evidence"))
    PACK.fetch("pages").each do |page|
      get page.fetch("path"), params: { email: "editorial-canary@example.invalid", gclid: "editorial-canary" }
      assert_response :success
      assert_select "[data-analytics-consent]", count: 1
      assert_select "script[src*='mixpanel']", count: 0
      File.write(Rails.root.join("tmp/editorial-evidence", "#{page.fetch('slug')}.html"), response.body)
    end
  ensure
    ENV.delete("IPIIA_ANALYTICS_ENABLED")
    ENV.delete("MIXPANEL_TOKEN")
  end
end
