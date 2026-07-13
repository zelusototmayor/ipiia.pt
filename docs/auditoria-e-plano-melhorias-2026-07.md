# Auditoria completa e plano de melhorias — ipiia.pt (julho 2026)

Contexto assumido (confirmado pelo Zelu):
- **Conversão prioritária:** intro calls. O Agente de Gestão com IA é a porta de entrada mais promissora.
- **Público:** donos/gerentes de PMEs e diretores de operações/IT.
- **Âmbito:** copy, estrutura, navegação, design, conteúdo dos cursos — tudo em cima da mesa.
- **Prova social:** ainda não há casos concluídos; o primeiro agente de gestão está em implementação.

Este documento complementa (não repete) a `auditoria-site-ipiia.md` anterior — vários pontos dessa auditoria já foram corrigidos (formulário de contacto real, contradição de preço em serviços, cross-links de fundos, secção de casos fundida na homepage).

---

## Parte 1 — Diagnóstico estratégico

### 1.1 O site vende "IA"; o dono da PME compra "controlo e tempo"

O copy é consistentemente bom — direto, PT-PT, sem hype. Mas o enquadramento dominante é a **categoria tecnológica** ("A IA já chegou a Portugal", "não fique para trás", "liderar a digitalização"). Para um dono de PME não-técnico, o medo de "ficar para trás" é abstrato; a dor concreta é: *perco horas a perseguir informação, descubro problemas tarde, a equipa afoga-se em tarefas repetitivas*.

As melhores páginas do site (Agente de Gestão, Fundos) já falam a linguagem da dor operacional. A homepage e a missão ainda falam a linguagem da tese macro (Portugal atrasado, produtividade nacional). A tese macro é boa para a página de missão; não devia ser o primeiro argumento da homepage.

### 1.2 O funil principal não aponta para a conversão prioritária

Hoje o CTA primário do hero é **"Fazer teste IA gratuito"** — um lead magnet de literacia *individual*, cujo output natural é… vender um curso de 39,99€. A intro call é o CTA secundário. Se a prioridade é gerar conversas de diagnóstico com o Agente de Gestão como porta de entrada:

- O agente aparece na homepage apenas na 7ª secção, como segundo botão de um bloco partilhado com "Casos".
- Na nav, "Agente de Gestão" é o 3º link, sem qualquer destaque.
- O hero não menciona o agente de todo.

**Inversão proposta:** hero orientado à dor operacional do gestor → CTA primário "Marcar intro call" → secção do Agente de Gestão logo após o problema (2ª/3ª secção) → teste IA como CTA secundário/inline para quem ainda não está pronto para falar.

### 1.3 O melhor segmento de leads do teste cai num beco sem saída

`AiReadinessTest` recomenda `curso-proficiencia.html` aos perfis com pontuação alta — precisamente os diretores de operações/IT com maturidade para contratar implementação. Mas essa página **não tem nada para comprar**: sem preço, sem botão, com copy de especificação ("Estrutura prevista", "A avaliação final *deve* combinar…"). O visitante mais qualificado do site recebe uma recomendação para uma página morta.

---

## Parte 2 — Plano de alterações

Organizado em 4 níveis de prioridade. Dentro de cada nível, itens por ordem de impacto.

### P1 · Bloqueadores de conversão e confiança (corrigir primeiro)

**1. Não existe menu mobile — os links de navegação desaparecem em ecrãs ≤980px.**
`styles.css:431` faz `.nav-links .nav-link { display: none; }` sem qualquer alternativa. Num telemóvel, um visitante só tem o logótipo e o botão de CTA — não consegue chegar a Serviços, Agente de Gestão, Casos, nada (exceto pelo rodapé). Para um público que abre links de LinkedIn/email no telemóvel, isto é provavelmente a maior perda silenciosa de conversão do site. → Implementar menu hamburger simples (HTML no chrome partilhado + ~30 linhas de CSS/JS).

**2. Copy interno visível no fluxo de booking.**
`book_call.html.erb:98`: "**A reserva foi enviada para o backend.**" e `:93`: "Cria evento no calendário. Confirmação por email quando sincronizar." — linguagem de programador no momento de maior sensibilidade (o utilizador acabou de dar os dados). → Substituir por: "Pedido recebido. Vai receber um email de confirmação com o convite de calendário."

**3. Disponibilidade de horários é fictícia.**
`application.js` gera sempre os mesmos 6 slots (10:00–16:00) para os próximos 10 dias úteis, sem consultar disponibilidade real nem bookings existentes. Riscos: dois pedidos para a mesma hora; marcarem uma hora em que não podes. → Mínimo viável: endpoint que devolve slots livres (excluindo bookings existentes e, idealmente, o Google Calendar que já está integrado). Alternativa mais barata: enquadrar explicitamente como *pedido* de reserva ("propomos confirmar por email em 24h úteis") em toda a UI — o que o backend já faz na prática.

**4. Redirecionar o funil avançado do teste.**
Enquanto o curso de proficiência não existir: perfis altos do teste devem ser recomendados para **intro call / workshop in-company** (são os melhores leads de consultoria), com o curso avançado como "em preparação — entre na lista de espera". Alterar `ai_readiness_test.rb:58` e o email/relatório correspondente.

**5. Página do curso de proficiência: assumir o estado real + capturar procura.**
A página lê-se como um produto à venda mas não tem preço nem compra, e o rodapé chama-lhe "Certificado avançado" como se existisse. → Banner claro "Em preparação · abre em [período]", formulário de lista de espera (email), e reescrever o copy de especificação ("deve combinar…") para copy de promessa ("vai combinar…"). A lista de espera valida a procura antes de investires em construir o curso.

**6. /contacto e /book-call competem pela mesma promessa.**
Ambas as páginas têm como headline "Marque uma intro call de 15 minutos", mas uma marca de verdade (widget) e a outra só envia uma mensagem. Quem entra por /contacto tem uma experiência pior para o mesmo objetivo. → Reposicionar /contacto como canal secundário: "Prefere escrever primeiro?" — para dúvidas, parcerias, faturação — com link destacado para o booking real no topo. Alinhar o link "Contacto" do rodapé com esta expectativa.

### P2 · Reorientar mensagem e estrutura para a prioridade comercial

**7. Homepage nova (a alteração de maior alavancagem).**
Estrutura proposta, mantendo os componentes existentes:
1. **Hero** — dor operacional + resultado, não categoria tecnológica. Direção de copy: *"A sua operação inteira, debaixo de olho — sem perseguir ninguém."* / sub: diagnóstico, formação e sistemas de IA que devolvem horas à gestão de PMEs portuguesas. CTA primário: **Marcar intro call**; secundário: *Fazer o teste IA gratuito*.
2. **Problema** (manter os 4 cards, estão bons — eventualmente reescrever o 01 para a dor de gestão, não de "não sei por onde começar com IA").
3. **Agente de Gestão** — secção própria com badge "Novo", 3 bullets do que faz + CTA para a página. É a porta de entrada; merece estar acima dos serviços.
4. **Método** (resumo, manter).
5. **Serviços** (manter grid, ver item 11).
6. **Casos/cenários** (ver item 9).
7. **CTA final** (manter).
- Hero-stats atuais são filler ("100% foco em resultados", "2 percursos de formação") — números que não provam nada enfraquecem os que provam. Substituir por âncoras com substância: "30 dias · piloto funcional", "15 min · primeira conversa", "4 fases · método com métrica", e uma âncora de dor citável (ex.: horas/semana que a gestão gasta em coordenação manual, com fonte).

**8. Navegação: reordenar para espelhar a prioridade.**
Atual: Missão · Serviços · Agente de Gestão · Apoios IA · Teste IA · Casos · Sobre + CTA.
Proposta: **Agente de Gestão · Serviços · Casos · Apoios IA · Teste IA · Sobre** + CTA "Intro call 15 min".
- "Missão" sai da nav (fica no rodapé e linkada da homepage): para um decisor, Missão + Sobre são a mesma pergunta ("quem são vocês?") — considerar mesmo fundir as duas páginas numa só ("Sobre · Missão"), reduzindo o peso institucional do site (hoje há 3 páginas de "quem somos/como pensamos" para 1 de serviços).
- Tagline da nav: "TESTE · FORMAÇÃO · DIAGNÓSTICO · IMPLEMENTAÇÃO" lidera com o item de menor valor. → "DIAGNÓSTICO · FORMAÇÃO · IMPLEMENTAÇÃO · GESTÃO COM IA".

**9. Prova social — honesta, não forjada.**
Casos fictícios apresentados como reais são publicidade enganosa (DL 57/2008, práticas comerciais desleais) e, mais prático: uma PME que pergunte "posso falar com esse cliente?" na intro call desmonta tudo — e o negócio inteiro assenta em confiança. Alternativa com quase o mesmo efeito persuasivo e zero risco:
- **/casos → "Cenários de aplicação"**: manter os 6 casos, mas dar a cada um números ilustrativos assinalados como tal ("Numa PME-tipo com 40 pedidos/dia, a triagem automática liberta ~6h/semana — estimativa ilustrativa"). Números concretos + honestidade > vago + honesto, e infinitamente > concreto + falso.
- **Bloco "Primeiro projeto em curso"**: o agente que estás a implementar agora é prova social real — "Estamos a implementar o primeiro Agente de Gestão numa [setor] com N unidades. Resultados publicados aqui quando medidos." Escassez + transparência funcionam a favor.
- **Instrumentar o piloto atual** desde já (baseline de horas/semana, tempos de resposta) para teres o primeiro caso real com métricas dentro de 2–3 meses — está previsto no plano de implementação; garantir que acontece.
- Barra "Setores" da homepage → "Setores em foco" (já apontado na auditoria anterior, ainda por corrigir).

**10. Página do Agente de Gestão: de conceito a cenário.**
A página é a melhor do site (honesta, bem estruturada, FAQ forte). Falta-lhe tornar o abstrato palpável para um dono não-técnico:
- **Secção "Uma semana com o agente"** — narrativa concreta: *segunda 8h: resumo do estado da operação no email; terça: alerta de despesa sem comprovativo; quinta: follow-up preparado para o cliente X à espera de aprovação…* Um cenário vale mais do que três grids de conceitos.
- **Ancorar o investimento.** "Sob proposta" em tudo cria fricção para PMEs (medo do orçamento surpresa). Sem publicar preço, ancorar o formato: "Projeto de implementação + acompanhamento mensal. O âmbito define-se no diagnóstico." — ou, se estiveres confortável, uma ordem de grandeza "a partir de".
- CTA com contexto: `book-call.html?tema=agente` a pré-selecionar o tópico no formulário (1 linha de JS).

**11. Serviços: separar visualmente self-serve de consultivo.**
Já identificado na auditoria anterior e ainda válido: teste grátis, curso de 40€ e serviços "sob proposta" partilham o mesmo componente com o mesmo peso. Os dois grupos já existem ("Capacitar a equipa" / "Pôr a IA a trabalhar") — reforçar a diferença visual (cards self-serve com preço e ação imediata; consultivos com "diagnóstico primeiro") e dar link direto ao curso no card de formação (hoje o CTA força a volta pelo teste: `servicos.html:50`).

### P3 · Estrutura técnica, SEO e limpeza

**12. Nav e rodapé server-side.**
Hoje o chrome do site é injetado por JS (`application.js` monta `NAV_HTML`/`FOOTER_HTML` em `#nav-mount`/`#footer-mount`). Consequências: crawlers/preview-bots sem JS não veem navegação nem links internos (perda de SEO interno real), flash de layout no carregamento, e sem JS o site fica sem navegação. Em Rails a correção é natural: partials `_nav.html.erb` e `_footer.html.erb` renderizados no layout. Migração mecânica, ~1h, remove ~70 linhas de JS.

**13. SEO básico em falta.**
- Só 2 de 17 páginas têm meta description própria (`pages_controller.rb`) — preencher todas no hash `PAGES`.
- OG tags só na página de fundos — mover para o layout com defaults + override por página.
- Não há `sitemap.xml` — gerar estático (as rotas são conhecidas).
- Títulos: normalizar padrão "Página — IPIIA" (ok) e corrigir a inconsistência "Fundamentos de IA **no** Trabalho" (controller) vs "**para o** Trabalho" (catálogo/página).

**14. Dependência do unpkg para ícones.**
`lucide.min.js` carrega de CDN externo, síncrono, no `<head>`. Se o unpkg falhar/abrandar, os ícones desaparecem e o parse bloqueia. → Fazer vendor do ficheiro (ou inline dos ~15 SVGs usados, que é ainda melhor) e `defer`.

**15. Limpeza de resíduos (da auditoria anterior, ainda pendente).**
Apagar ou mover para fora do repo: `*.html` da raiz, `app.js` da raiz, `static_site_backup/`, e a função morta `initAssessmentForm()` em `application.js` (formulário simulado de 900ms que já não corresponde a nenhuma página). Enquanto existirem, cada sessão de edição futura arrisca tocar no ficheiro errado.

**16. Links internos: usar helpers/paths absolutos.**
As views usam `href="teste.html"` (relativo). Funciona com a estrutura atual de URLs mas parte-se à primeira rota aninhada. → `page_path("teste")` ou `/teste.html`.

### P4 · Cursos: conteúdo e produto

O conteúdo do curso de fundamentos é **bom** — prático, honesto, com arco pedagógico real (literacia → prompting → meta-prompting → casos → segurança → workflow final que alimenta a avaliação). As melhorias são de acabamento e de posicionamento, não de substância:

**17. PT-PT consistente no LMS.** "Lesson" aparece no UI do curso ("Concluir lesson", eyebrow "Lesson", "Cada lesson inclui") em contraste com o resto do site em português cuidado. → "lição" em `courses/lesson.html.erb`, `courses/show.html.erb`, `curso_fundamentos.html.erb`.

**18. Aumentar valor percebido sem regravar nada.**
- **Biblioteca de templates**: os 18 templates copiáveis são o ativo mais valioso do curso. Juntá-los numa página final "Os seus templates" (e/ou PDF descarregável) dá um artefacto permanente que justifica o preço e circula dentro da empresa (marketing orgânico).
- **1 exemplo visual por módulo**: screenshot de uma conversa real (anonimizada) a aplicar o template. Barato, quebra a monotonia de texto corrido.

**19. Endurecer o quiz.** Várias perguntas têm a resposta certa óbvia por eliminação (a opção sensata/longa vs. três absurdas — ex. q13 "Cor favorita"). Para um certificado que vale alguma coisa: distratores plausíveis em pelo menos metade das perguntas, e remover a q15 (auto-referencial sobre o que o certificado indica — não avalia competência).

**20. Oferta de equipa.** O comprador-alvo é uma PME, não um indivíduo. Um pacote "5 acessos por 149€" (ou similar) é um upsell natural, dá ao dono uma razão para pagar para a equipa toda e cria a ponte para o workshop in-company — outra fonte de intro calls. Tecnicamente: N enrollments por compra, o modelo de dados atual aguenta com pouco esforço.

**21. Decidir o destino do curso de proficiência.** Com a lista de espera do item 5 a correr, decidir com dados: se houver procura, construir uma v1 mínima (o `CourseCatalog` torna isso barato — é acrescentar conteúdo, o LMS já existe); se não, manter como âncora aspiracional e canalizar tudo para consultoria. Não deixar indefinido por mais meses.

---

## Parte 3 — Sequência recomendada

| Fase | Itens | Racional |
|------|-------|----------|
| Semana 1 | 1, 2, 3, 6 | Bloqueadores de conversão; tudo pequeno exceto o menu mobile (1 dia) |
| Semana 1–2 | 4, 5 | Fecha a fuga do funil do teste e captura procura do curso avançado |
| Semana 2–3 | 7, 8, 9, 10, 11 | O reposicionamento — fazer como um bloco coerente, é a mesma narrativa em várias páginas |
| Semana 3–4 | 12, 13, 14, 15, 16 | Técnico/SEO — mecânico, pode intercalar |
| Contínuo | 17–21 | Cursos — 17 é imediato; 18–20 quando houver espaço; 21 depende da lista de espera |

## Parte 4 — O que NÃO mudar

- **O tom.** Direto, sem hype, com "dizemos que não quando não faz sentido" — é diferenciador real num mercado cheio de vendedores de IA. Todas as reescritas devem preservá-lo.
- **A página de fundos europeus.** É a melhor peça de SEO/conteúdo do site; só ganha as OG/meta melhorias gerais.
- **A honestidade estrutural** (disclaimer de marca privada, "não garantimos aprovação", certificado "não é certificação regulatória"). É um ativo, não um custo.
- **O sistema de design.** Componentes consistentes, hierarquia clara, uma secção dark por página. O design não precisa de redesign — precisa do menu mobile e de pequenos ajustes de ênfase já descritos.
