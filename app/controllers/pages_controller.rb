class PagesController < ApplicationController
  PAGES = {
    "home" => {
      template: "index",
      title: "IPIIA · Instituto Português de Implementação de IA",
      description: "Automações e agentes de IA para PMEs: tratamento de faturas, atendimento por voz e gestão interna, ligados aos sistemas da empresa."
    },
    "index" => {
      template: "index",
      title: "IPIIA · Instituto Português de Implementação de IA",
      description: "Automações e agentes de IA para PMEs: tratamento de faturas, atendimento por voz e gestão interna, ligados aos sistemas da empresa."
    },
    "missao" => {
      template: "missao",
      title: "Missão · IPIIA",
      description: "As PMEs são a espinha dorsal da economia portuguesa. A missão do IPIIA é levar IA aplicada aos processos reais · com formação, diagnóstico e implementação."
    },
    "metodo" => {
      template: "metodo",
      title: "Método · IPIIA",
      description: "Quatro fases · diagnóstico, priorização, piloto e medição · que transformam oportunidades de IA em resultados operacionais mensuráveis."
    },
    "servicos" => {
      template: "servicos",
      title: "Soluções de IA e automação · IPIIA",
      description: "Implementação de automações e agentes para documentos, atendimento e gestão interna. Projetos ajustados aos processos e sistemas da empresa."
    },
    "agente-de-gestao-ia" => {
      template: "agente_de_gestao_ia",
      title: "Agente de Gestão com IA · IPIIA",
      description: "Um assistente privado de gestão para PMEs: centraliza a informação da empresa, responde na hora, avisa do que merece atenção e executa automações · com aprovação humana."
    },
    "fundos-europeus-ia-pmes" => {
      template: "fundos_europeus_ia_pmes",
      title: "Fundos Europeus para IA em PMEs | IPIIA",
      description: "Descubra como conseguir fundos europeus para implementar inteligência artificial na sua PME. O IPIIA ajuda a estruturar projetos de IA para Portugal 2030, PRR e apoios à digitalização."
    },
    "casos" => {
      template: "casos",
      title: "Exemplos e demos · IPIIA",
      description: "Conheça exemplos de tratamento de faturas, atendimento por voz e gestão interna com IA."
    },
    "formacao" => {
      template: "formacao",
      title: "Formação em IA · IPIIA",
      description: "Cursos online e workshops para usar IA nas tarefas da equipa."
    },
    "automacao-faturas" => {
      template: "automacao_faturas",
      title: "Faturas do email ao ERP · IPIIA",
      description: "Como automatizar a receção, leitura e inserção de faturas no ERP, com integração ajustada aos sistemas da empresa."
    },
    "reboques-ipiia" => {
      template: "reboques_ipiia",
      title: "Demonstração de voz Reboques IPIIA",
      description: "Demonstração de um agente de voz que recolhe e regista pedidos de assistência. Empresa fictícia, sem despacho real."
    },
    "teste" => {
      template: "teste",
      title: "Teste IA gratuito · IPIIA",
      description: "Teste gratuito de 5–7 minutos que avalia a prontidão em IA por dimensões · fundamentos, prompting, validação e segurança · com relatório enviado por email."
    },
    "sobre" => {
      template: "sobre",
      title: "Sobre · IPIIA",
      description: "O IPIIA é uma marca privada e independente que ajuda PMEs portuguesas a passar da curiosidade sobre IA à aplicação prática nos processos reais."
    },
    "contacto" => {
      template: "contacto",
      title: "Contacto · IPIIA",
      description: "Escreva-nos para dúvidas, parcerias ou questões sobre serviços e cursos. Respondemos em 24 horas úteis."
    },
    "book-call" => {
      template: "book_call",
      title: "Intro call · IPIIA",
      description: "Marque uma intro call gratuita de 15 minutos para perceber se o próximo passo é formação, diagnóstico, piloto ou o Agente de Gestão com IA."
    },
    "curso-fundamentos" => {
      template: "curso_fundamentos",
      title: "Fundamentos de IA para o Trabalho · IPIIA",
      description: "Curso online de fundamentos de IA para o trabalho: prompting, validação, segurança e um workflow pessoal. 6 módulos, certificado IPIIA, 39,99€."
    },
    "curso-proficiencia" => {
      template: "curso_proficiencia",
      title: "Proficiência em Implementação de IA · IPIIA",
      description: "Curso avançado de implementação de IA · workflows, automações e agentes com avaliação prática. Em preparação: entre na lista de espera."
    },
    "privacidade" => {
      template: "privacidade",
      title: "Política de Privacidade · IPIIA",
      description: "Como o IPIIA trata e protege os dados pessoais recolhidos no site."
    },
    "termos" => {
      template: "termos",
      title: "Termos e Condições · IPIIA",
      description: "Termos e condições de utilização do site e dos cursos online do IPIIA."
    },
    "cookies" => {
      template: "cookies",
      title: "Política de Cookies · IPIIA",
      description: "Que cookies o site do IPIIA utiliza e para quê."
    }
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
    @canonical_path = "/fundos-europeus-ia-pmes/#{params[:apoio]}"
    render "apoio_fundos"
  rescue KeyError
    raise ActionController::RoutingError, "Not Found"
  end

  private

  def render_page(slug)
    page = PAGES.fetch(slug)
    @page_title = page[:title]
    @meta_description = page[:description]
    @canonical_path = canonical_path_for(slug)
    render page[:template]
  end

  def canonical_path_for(slug)
    return "/" if %w[home index].include?(slug)
    return "/fundos-europeus-ia-pmes" if slug == "fundos-europeus-ia-pmes"

    "/#{slug}.html"
  end
end
