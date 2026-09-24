module ApplicationHelper
  # Marca o link de navegação ativo. Compara caminhos normalizados (sem .html),
  # tratando as sub-páginas de fundos como caso especial.
  def nav_current?(href)
    current = request.path.delete_suffix(".html")
    target = href.delete_suffix(".html")

    return current.start_with?("/fundos-europeus-ia-pmes") if target == "/fundos-europeus-ia-pmes"
    return %w[/casos /automacao-faturas /reboques-ipiia].include?(current) if target == "/casos"
    return %w[/formacao /curso-fundamentos /curso-proficiencia /teste].include?(current) if target == "/formacao"
    return %w[/servicos /agente-de-gestao-ia].include?(current) if target == "/servicos"

    current == target
  end
end
