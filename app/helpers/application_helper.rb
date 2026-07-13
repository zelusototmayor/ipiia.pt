module ApplicationHelper
  # Marca o link de navegação ativo. Compara caminhos normalizados (sem .html),
  # tratando as sub-páginas de fundos como caso especial.
  def nav_current?(href)
    current = request.path.delete_suffix(".html")
    target = href.delete_suffix(".html")

    return current.start_with?("/fundos-europeus-ia-pmes") if target == "/fundos-europeus-ia-pmes"

    current == target
  end
end
