# Estudo de imagens e prova social · 19 setembro 2026

Pré-visualização local. Copy anti-slop aprovado e aplicado, com limpeza visual. Sem publicação.

## Seleção

- Retrato fornecido pelo utilizador: `app/assets/images/jose-luis-sottomayor.jpg`. Aplicado no cartão do fundador, página Sobre. Original preservado; enquadramento apenas por CSS.
- JAM: copiado de `jam-gestao/public/assets/jam-logo.png`, no projeto indicado pelo utilizador.
- SellPoint: https://sellpoint.pt/wp-content/uploads/2024/01/b.png — identidade confirmada pelo utilizador nesta conversa.
- Cerealis: https://www.cerealis.pt/wp-content/uploads/2024/04/Logo_Cerealis.svg — website oficial português.
- Logos guardados como `client-jam.png`, `client-sellpoint.png`, `client-cerealis.svg`. Monocromia aplicada em CSS sem alterar os originais.

## Imagem de contexto

Gerada pela ferramenta integrada de imagem (não API/CLI). Artefacto selecionado: `app/assets/images/operations-editorial.jpg`. Conversão para JPEG para reduzir o peso. Representa uma cena ilustrativa, não um cliente nem a equipa do IPIIA; identificada como imagem gerada com IA na legenda.

Prompt final:

> Use case: photorealistic-natural. Create a landscape editorial photograph for a Portuguese AI implementation consultancy website, to illustrate the daily operations of small businesses. A candid documentary still of a small Portuguese restaurant before opening: foreground light oak table with open laptop seen obliquely (screen illegible), notebook and a few orderly delivery documents; in middle distance one restaurant manager in dark forest green overshirt checking preparation with a colleague, natural unposed interaction, faces secondary. Window daylight, warm ivory plaster, restrained petrol green accents, olive foliage outside. Realistic ordinary small business, tasteful but not luxury coworking, authentic material texture, calm framing with breathing room, fine film grain, muted natural colors, 35mm editorial photography. No text, branding, logos, holograms, robots, neon, handshakes, posed smiles, tech graphics. Wide 3:2 crop, main interaction right of center. This is illustrative contextual imagery, not a depiction of the consultancy team or a named client.

## Enquadramentos testados

1. Fotografia na hero, com fluxo operacional abaixo: rejeitado após inspeção no browser; primeira dobra excessivamente alta, fluxo cortado no viewport, posicionamento demasiado associado à restauração.
2. Fotografia junto à introdução dos problemas operacionais: selecionado; dá variação visual sem dominar a proposta geral. Hero original mantida.
3. Retrato no cartão Sobre: selecionado; rosto legível, proporções preservadas, sem regeneração da identidade.

## Revisão após feedback

A imagem do restaurante foi rejeitada pelo utilizador. Retirada do site, mantendo o ficheiro para histórico. Três novas imagens produzidas com a ferramenta integrada, convertidas para JPEG e verificadas no contexto das páginas:

- `app/assets/images/corporate-focus.jpg`: trabalho administrativo organizado, na introdução da homepage.
- `app/assets/images/corporate-collaboration.jpg`: colaboração entre colegas, junto ao workshop em Serviços.
- `app/assets/images/corporate-security.jpg`: ambiente reservado e trabalho partilhado, junto às permissões do Agente de Gestão.

As três imagens foram geradas com IA e não representam clientes nem colaboradores reais. As legendas visíveis foram retiradas a pedido do utilizador na revisão final. A proveniência permanece documentada aqui.

Prompts finais (prefixo comum: “Generate a photorealistic illustrative website image.”):

1. Three business colleagues seated on the SAME side and adjacent sides of an open desk, all looking together at a laptop, one pointing gently to screen, relaxed interested expressions, visibly cooperative workshop, medium-wide candid corporate editorial photograph, airy contemporary Portuguese office with glass partitions, ivory walls, petrol green details and natural window daylight. No confrontation or manager across a desk, no handshake, no posed stock smile. Landscape 3:2.
2. One business professional at a bright organized desk calmly reviewing a simple single-page document beside a laptop, relaxed posture, a finished modest stack of organized files off to one side, ample clean desk space, daylight through glass office walls, contemporary European corporate office. Editorial photograph about reduced administrative workload and focused work, not a vacation or empty desk. Landscape 3:2.
3. Two business IT colleagues calmly reviewing access permissions on a laptop together in a quiet contemporary glass meeting room, angled view including closed glass door and neatly organized work surface, discreet professional environment, confidentiality and collaboration, natural daylight, ivory and forest green corporate palette. Screens oblique and illegible, no padlock overlays, hacker hoodies, robots, neon, text or logos. Authentic editorial corporate photograph, landscape 3:2.

Sufixo comum: “Consistent restrained natural colors, realistic anatomy, natural materials. Not a representation of actual staff or a named client. No branding or text.”

As 29 propostas aprovadas foram aplicadas. Retirados rótulos redundantes, numeração decorativa, linhas do fluxo e do cartão do fundador. Mantidas sequências do método e separadores funcionais. Hero mais compacta. Clientes em faixa animada, com pausa por foco/hover e versão estática para movimento reduzido.
