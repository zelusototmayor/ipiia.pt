require "test_helper"

class ImplementationPagesControllerTest < ActionDispatch::IntegrationTest
  test "home presents three applications without the management product funnel" do
    get "/"
    assert_response :success
    assert_select "h1", text: /Automatizamos tarefas que ainda faz à mão/
    assert_select ".implementation-example", count: 3
    assert_select ".agent-split", count: 0
    assert_select ".client-track"
    assert_select "nav a", text: "Soluções"
    assert_select "nav a", text: "Formação"
  end

  test "new pages and existing URLs remain available" do
    %w[servicos casos formacao automacao-faturas reboques-ipiia agente-de-gestao-ia metodo].each do |page|
      get "/#{page}.html"
      assert_response :success
      assert_select "h1", count: 1
      assert_select "a[href='http://127.0.0.1:8001/']", count: 0
      assert_no_match(/Brevauto|Brave Auto|Imagem ilustrativa gerada/, response.body)
    end
  end

  test "voice demo is explicitly fictional and does not load a call SDK" do
    get "/reboques-ipiia.html"
    assert_select "p", text: /empresa de demonstração/
    assert_select "a[href='/book-call.html?tema=voz']"
    assert_no_match(/api\.vapi|retell-client|<iframe/, response.body)
  end
end
