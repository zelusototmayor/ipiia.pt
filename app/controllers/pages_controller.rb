class PagesController < ApplicationController
  PAGES = {
    "home" => { template: "index", title: "IPIIA — Instituto Português de Implementação de IA" },
    "index" => { template: "index", title: "IPIIA — Instituto Português de Implementação de IA" },
    "missao" => { template: "missao", title: "Missão — IPIIA" },
    "metodo" => { template: "metodo", title: "Método — IPIIA" },
    "servicos" => { template: "servicos", title: "Serviços — IPIIA" },
    "fundos-europeus-ia-pmes" => {
      template: "fundos_europeus_ia_pmes",
      title: "Fundos Europeus para IA em PMEs | IPIIA",
      description: "Descubra como conseguir fundos europeus para implementar inteligência artificial na sua PME. O IPIIA ajuda a estruturar projetos de IA para Portugal 2030, PRR e apoios à digitalização."
    },
    "casos" => { template: "casos", title: "Casos de uso — IPIIA" },
    "teste" => { template: "teste", title: "Teste IA gratuito — IPIIA" },
    "sobre" => { template: "sobre", title: "Sobre — IPIIA" },
    "contacto" => { template: "contacto", title: "Contacto — IPIIA" },
    "book-call" => { template: "book_call", title: "Intro call — IPIIA" },
    "curso-fundamentos" => { template: "curso_fundamentos", title: "Fundamentos de IA no Trabalho — IPIIA" },
    "curso-proficiencia" => { template: "curso_proficiencia", title: "Proficiência em Implementação de IA — IPIIA" },
    "privacidade" => { template: "privacidade", title: "Política de Privacidade — IPIIA" },
    "termos" => { template: "termos", title: "Termos e Condições — IPIIA" },
    "cookies" => { template: "cookies", title: "Política de Cookies — IPIIA" }
  }.freeze

  def home
    render_page("home")
  end

  def show
    slug = params[:page].to_s.delete_suffix(".html")
    return render_page(slug) if PAGES.key?(slug)

    raise ActionController::RoutingError, "Not Found"
  end

  def funding_support
    @funding_page = FundingSupportPages.fetch(params[:apoio].to_s)
    @page_title = @funding_page[:title]
    @meta_description = @funding_page[:description]
    render "apoio_fundos"
  rescue KeyError
    raise ActionController::RoutingError, "Not Found"
  end

  private

  def render_page(slug)
    page = PAGES.fetch(slug)
    @page_title = page[:title]
    @meta_description = page[:description]
    render page[:template]
  end
end
