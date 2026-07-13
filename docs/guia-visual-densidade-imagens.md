# Guia visual — cores, densidade e slots de imagem (jul 2026)

Origem: revisão visual pedida pelo Zelu (screenshots da página do agente). Este documento
regista (1) os bugs corrigidos, (2) as regras a seguir daqui em diante, (3) o mapa de
sítios onde imagens — mesmo genéricas — melhorariam o site.

---

## 1. Bugs corrigidos nesta ronda

| Problema | Onde | Correção |
|---|---|---|
| `values-list` ilegível (texto grafite sobre azul-escuro) | Agente → secção "Autonomia" (dark) | `.section-dark .value-text` com cor clara; dot passa a ocre |
| `method-grid` com títulos creme sobre fundo creme | Agente → "Como entregamos" (secção clara) | Variante clara: `.section:not(.section-dark) .method-*` |
| Hero com duas leads empilhadas (parede de texto centrado) | Agente e Curso proficiência | 1 lead + `.hero-note` curta e muted |
| Lista de 5 garantias em coluna única a esticar a secção dark | Agente → "Autonomia" | `.values-list-grid` (2 colunas em desktop) |
| Zero elementos visuais na página do agente | Hero do agente + secção do agente na homepage | `.agent-mock` — cartão "resumo diário" em CSS puro, marcado "exemplo ilustrativo" |

## 2. Regras para não reincidir

- **Todo o componente novo precisa de definição para os dois contextos** (secção clara e
  `section-dark`) ou de um comentário a dizer em qual pode ser usado. Os componentes
  `method-grid` (nasceu dark) e `values-list` (nasceu claro) já têm as duas variantes.
- **Um hero = uma lead.** Contexto adicional vai para `.hero-note` (menor, muted) ou para a
  primeira secção. Texto centrado com mais de ~4 linhas é sinal de que há texto a mais.
- **Cada secção de página interior deve ter no máximo um bloco de prosa** (lead); o resto
  deve estar em cards, listas curtas ou componentes com hierarquia visual própria.
- **Elementos "produto" (mocks) em vez de fotos de banco genéricas** onde o assunto é o
  agente/software: um mock CSS honesto comunica mais do que uma stock photo de escritório.
  Manter sempre a legenda "exemplo ilustrativo".

## 3. Mapa de slots de imagem (por prioridade)

### Alta prioridade

1. **Sobre — foto real do fundador** (`sobre.html`, founder-card)
   Hoje é um avatar de iniciais "JS". Uma fotografia real (retrato, fundo neutro, ~800×800,
   quadrada) é o único slot em que uma imagem genérica NÃO serve — é o principal ponto de
   confiança do site. Substituir `.founder-avatar` por `<img>`.

2. **Curso de fundamentos — screenshot real do interior do LMS** (`curso_fundamentos.html`)
   Entre o "Programa" e o painel de preço. Mostra a página de uma lição (template copiável +
   checkpoint) — prova que o curso existe e tem substância. Formato: 16:10, ~1400px de largura,
   moldura de browser. É uma captura tua do produto real; posso preparar o layout quando a tiveres.

3. **Workshop in-company — foto genérica de formação** (`servicos.html`, secção "Formação in-company")
   Único sítio onde uma stock photo funciona bem: sala de formação/equipa a trabalhar,
   tons quentes para combinar com a paleta papel/terracota. Horizontal 3:2, ~1600px.
   A secção é hoje 100% texto (intro + 4 cards).

### Média prioridade

4. **Método — sem imagem, mas com diagrama** (`metodo.html`)
   A method-grid já funciona como visual. Se quiseres reforçar: um diagrama simples
   (SVG inline, na paleta do site) do fluxo diagnóstico→piloto→medição com as entregas
   de cada fase. Posso desenhá-lo em SVG quando quiseres.

5. **Casos/cenários — mini-ilustrações por cenário** (`casos.html`)
   Os ícones lucide são pequenos; cada case-item aguentava uma ilustração spot (estilo
   line-art, 1 cor, ~200×140). Genéricas servem (email, documento, gráfico). Alternativa
   barata: aumentar os ícones atuais para 32px dentro de um quadrado papel-q.

6. **Homepage hero** (`index.html`)
   Já tem o canvas animado de rede — suficiente. Não acrescentar foto; competiria com o canvas.

### Baixa prioridade

7. **Fundos europeus** (`fundos_europeus_ia_pmes.html`) — página de SEO, texto é o ponto;
   no máximo, logos dos programas (Portugal 2030, PRR) na secção dos avisos — verificar
   regras de uso das marcas antes.
8. **Missão** — as estatísticas (99%, ~3/4, ~60%) já são o elemento visual. Nada a fazer.
9. **Páginas legais** — sem imagens, obviamente.

### Onde NÃO pôr imagens

- Heros das páginas interiores (o padrão tipográfico centrado é a identidade do site).
- Secções dark (o contraste azul + tipografia é o momento "premium" de cada página).
- Qualquer foto de "robô/cérebro IA" — contradiz o posicionamento anti-hype.

## 4. Notas de cor (avaliação geral)

A paleta (papel #F5EFE6, azul #0B1F3A, terracota #C25A3A, ocre #D9A05B) é coerente e
diferenciada — não precisa de mudança. Os problemas eram de **aplicação** (componentes sem
variante para o contexto), não de escolha. Duas notas menores:
- O ocre sobre azul-escuro (eyebrows dark) está no limite de contraste para texto pequeno —
  manter apenas em labels uppercase curtas, nunca em corpo de texto.
- As fontes vêm do Google Fonts (CDN externo) — mesma classe de dependência que o lucide
  era; vale a pena self-host num passo futuro (performance + RGPD).
