# Plano de redesign — Oficina de Operações

## Objetivo

Reposicionar visualmente o IPIIA como parceiro de implementação operacional de IA:
prático, rigoroso e próximo dos processos reais das PMEs. A interface deve parecer um
sistema de trabalho claro, não uma landing page genérica de consultoria tecnológica.

## Princípios

1. **Menos decoração, mais estrutura** — linhas, etapas e estados substituem sombras,
   texturas e cartões flutuantes.
2. **Uma ideia visual por secção** — evitar mosaicos, dashboards densos e vários focos
   concorrentes.
3. **Claro por defeito** — o branco frio domina; verde petróleo é reservado para
   estrutura e momentos de maior contraste.
4. **Lima funcional** — usada em CTAs, estados ativos e execução, nunca como
   decoração generalizada.
5. **Tipografia operacional** — Barlow Condensed nos títulos e Barlow no corpo, sem o
   trio serif + sans + mono da versão anterior.
6. **Geometria disciplinada** — cantos quase retos, divisórias finas, ausência de sombras
   e espaçamento amplo.

## Sistema visual

- Verde petróleo: `#0A2924`
- Branco frio: `#F5F6F2`
- Cinza metálico: `#DDE2DE`
- Grafite verde: `#18201E`
- Lima de ação: `#C7EA32`
- Lima suave: `#E5F3A8`
- Títulos: Barlow Condensed
- Corpo: Barlow

## Alterações por área

### Global

- Substituir fontes e tokens de cor.
- Remover textura de grão e sombras decorativas.
- Reduzir arredondamentos.
- Normalizar botões, formulários, tabelas, painéis e estados.
- Tornar labels pequenas legíveis sem depender de monospace.

### Navegação e rodapé

- Criar marca tipográfica compacta `IPIIA` com símbolo modular.
- Usar barra verde petróleo fina e estável.
- Tratar o CTA como ação operacional em lima.
- Simplificar o rodapé e manter todos os links atuais.

### Homepage

- Hero em duas colunas, alinhado à esquerda.
- Remover canvas de rede e bloco de quatro estatísticas.
- Introduzir um único fluxo: informação reunida → prioridades detetadas → ação executada.
- Converter setores, problemas, método, serviços e casos para módulos lineares leves.

### Páginas interiores

- Heros alinhados à esquerda e mais compactos.
- Secções escuras em verde petróleo, sem aspeto “premium editorial”.
- Cards e grelhas passam a ter fundo claro, sem sombra e com divisórias.
- Mocks do agente assumem linguagem de ferramenta operacional.
- Formulários, curso e booking usam os mesmos estados e hierarquia.

## Verificação

- Testes Rails existentes.
- Homepage, Serviços, Agente de Gestão, Fundos, Curso e Booking em desktop e mobile.
- Contraste, foco de teclado, overflow horizontal e menu móvel.
- Servidor local disponível para revisão antes de qualquer commit final do redesign.
