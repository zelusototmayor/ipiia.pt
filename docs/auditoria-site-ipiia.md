# Auditoria ao site ipiia.pt (com as alterações do Agente de Gestão em mente)

Revi todo o site (10 páginas + navegação + rodapé + JS) antes de implementar a proposta anterior. Há dois achados que não são de copy — são bugs/riscos de execução — e valem mais do que qualquer ajuste de texto. Depois disso, ajustes de arquitetura e de copy.

## 1. Achados críticos (corrigir antes ou junto da implementação)

### 1.1 O formulário de `/contacto` não envia nada

`initContactForm()` em `app/javascript/application.js` (linha ~172) apenas espera 900ms e mostra "Recebemos o seu pedido" — não há `fetch`, não há controller, não existe rota `/contacts` no `routes.rb`. Comparei com `initReadinessTest()` e `initBookingWidget()`, que fazem `fetch()` reais para `ai_assessments` e `/bookings`. O contacto é o único formulário do site que é 100% simulado.

Isto significa que qualquer visitante que prefira o formulário de contacto em vez de marcar diretamente uma intro call **perde o pedido sem ninguém saber**. Dado que o objetivo de todo este trabalho é gerar conversas de diagnóstico, isto é uma fuga de leads real. Prioridade mais alta do que qualquer copy novo.

### 1.2 Há dois ficheiros de navegação/rodapé divergentes

- `app/javascript/application.js` — o que a app Rails realmente carrega via importmap. Tem 7 links (Missão, Método, Serviços, **Apoios IA**, Teste IA, Casos, Sobre) + CTA, e rodapé com Privacidade/Termos/Cookies.
- `/app.js` na raiz do repo e `static_site_backup/app.js` — versões mais antigas, com apenas 6 links (falta "Apoios IA"), hrefs relativos (`missao.html` em vez de `/missao.html`), sem os links legais no rodapé.

Os HTML na raiz do repo (`index.html`, `servicos.html`, etc.) e a pasta `static_site_backup/` também duplicam o conteúdo das views reais em `app/views/pages/*.erb`, mas não são servidos pela app (confirmado via `routes.rb` e `PagesController`). Isto é resíduo de uma versão estática anterior.

**Risco concreto:** a próxima ronda de edições (nav, rodapé, novo link do Agente de Gestão) tem de ir para `app/javascript/application.js`. Editar o `app.js` da raiz ou os `.html` da raiz não muda nada no site ao vivo. Vale a pena arquivar ou apagar claramente os duplicados para nenhuma sessão futura (minha ou de outra IA) perder tempo a editar o ficheiro errado.

**Correção à proposta anterior:** eu tinha escrito os snippets de nav/rodapé a apontar para "`app.js`" — está errado, é `app/javascript/application.js`. E a nav já tem 7 itens, não 6 — o que muda o ponto 2 abaixo.

## 2. Arquitetura de informação

### 2.1 A navegação já está no limite antes de acrescentar o Agente de Gestão

Ordem atual: Missão · Método · Serviços · Apoios IA · Teste IA · Casos · Sobre + CTA "Intro call". São 7 links de texto + 1 botão. Acrescentar "Agente de Gestão" tal como propus faria 8 — arriscado em mobile e dilui todos os itens.

Sugestão: **não acrescentar, substituir por consolidação.** "Método" é essencialmente a explicação de como decorre o diagnóstico/piloto — pode viver como âncora dentro de "Serviços" em vez de item próprio no topo. Isso liberta espaço para "Agente de Gestão" sem esticar a nav. Alternativa mais conservadora: manter os 7 e só acrescentar o link no rodapé + nos pontos de entrada (homepage, servicos, metodo, casos, book-call) já previstos na proposta — sem tocar na nav principal já. A decisão é tua; ambas resolvem o problema, a primeira é mais limpa a médio prazo.

### 2.2 A homepage já tem 7 secções — a 8ª proposta torna-a longa

Hero → Cred bar → Missão → Problema → Método → Serviços (4 cards) → Casos → CTA final. A secção nova que propus ("Depois do piloto") seria a 8ª. Em vez de a acrescentar a somar, sugiro **fundir com a secção de Casos**: reformular o bloco de "Casos de uso" para terminar explicitamente com a ideia de que esses casos podem ser pilotos pontuais hoje e módulos do Agente de Gestão amanhã, com o CTA da secção a apontar para a nova página em vez de (ou além de) `casos.html`. Mantém o número de secções em 7 e cria a ligação lógica em vez de duas mensagens separadas.

### 2.3 Sinergia não aproveitada: página de Fundos Europeus

`/fundos-europeus-ia-pmes` é uma peça de conteúdo muito bem construída (5 sub-páginas: SICE Qualificação PME, Linha IA nas PME, SICE Inovação Produtiva, Base Territorial, SIQRH Formação) que eu não tinha visto na primeira leitura. Um dos apoios (Linha IA nas PME) lista literalmente **"Assistentes virtuais ou agentes de IA para produtividade interna"** como despesa elegível — é quase a definição do Agente de Gestão.

Vale a pena um cross-link nos dois sentidos: na página do Agente de Gestão, uma nota "este tipo de projeto pode ser elegível para apoios como a Linha IA nas PME — ver fundos europeus →"; na página de fundos, uma referência ao Agente de Gestão como exemplo do "assistente/agente de IA" que os avisos mencionam. Com o mesmo cuidado que a página já tem (não prometer aprovação, avisos abrem e fecham) — o disclaimer existente (`funds-alert`) já cobre isso.

### 2.4 Cursos pouco descobríveis

`curso-fundamentos.html` e `curso-proficiencia.html` só são alcançados pelo rodapé ou depois do teste — nenhum card em `servicos.html` liga diretamente a eles (o card "02 / Formação online" tem CTA "Começar pelo teste →", não um link direto ao curso). Não é grave, mas para quem já sabe que quer o curso, força uma volta desnecessária pelo teste. Não está na proposta do Agente de Gestão, mas é uma correção barata a fazer na mesma leva.

## 3. Consistência de copy e preço

### 3.1 Contradição de preço já existente

`servicos.html`, card "02 / Formação online": `offer-scope` diz **"Pago · sem preço público"**. Mas `curso-fundamentos.html` mostra **"39,99€"** de forma totalmente pública, com botão de compra Stripe. É uma contradição direta — um clique separa "sem preço público" de "39,99€ à vista". Corrigir o texto do card para refletir que o curso de fundamentos tem preço público fixo; reservar "sem preço público" apenas para os serviços consultivos (workshop, diagnóstico, implementação, Agente de Gestão).

### 3.2 "Quatro formas de começar" — cuidado ao acrescentar a 5ª

Confirmo a decisão já tomada na proposta anterior: o Agente de Gestão **não entra na mesma grid de 4 cards** da homepage (que literalmente se chama "Quatro formas de começar"). Em `servicos.html` proponho um 5º card agrupado à parte ("Pôr a IA a trabalhar"); nesse caso a frase de abertura da página já não pode dizer "duas frentes" sem qualificar — ajustar para algo como "duas frentes: capacitar a equipa, e pôr a IA a trabalhar — do piloto pontual à camada de gestão contínua", que já estava na proposta.

## 4. Hierarquia visual: self-serve vs. serviço à medida

Hoje, "Teste gratuito" (grátis, self-serve), "Curso" (39,99€, checkout automático) e "Diagnóstico/Implementação" (sob proposta, via intro call) usam exatamente o mesmo componente (`offer-card`), lado a lado, com o mesmo peso visual. Isso já achata a diferença entre comprar um curso de 40€ com um clique e contratar um serviço à medida. Ao introduzir o Agente de Gestão — o tier mais caro e mais consultivo de todos — este problema fica mais visível: ele não deveria competir visualmente com um card de curso de 40€.

Sugestão: dar ao Agente de Gestão um tratamento visual próprio (bloco isolado, não um card na mesma grid — já é o que a proposta anterior faz na homepage) e, dentro de `servicos.html`, considerar separar visualmente os 2 cards self-serve (Teste, Curso) dos 3 consultivos (Workshop, Diagnóstico+Piloto, Agente de Gestão) em vez de uma grid única de 5.

## 5. Prova social — lacuna real, não inventar

Não há testemunhos, nomes de clientes, nem métricas de resultados reais em nenhuma página (consistente com o estado atual do projeto — sem casos publicados ainda). Não é algo a corrigir com copy fictício. Duas opções honestas: deixar como está e resolver assim que houver o primeiro caso validado; ou, se preferires, um placeholder claro tipo "Os primeiros casos serão publicados aqui" em vez de simplesmente não abordar o tema — mas isso é uma escolha tua, não vou decidir por ti.

A barra "Setores" na homepage (Indústria, Retalho, Logística, Serviços financeiros, Saúde, Jurídico, Construção) lê-se como setores já servidos. Se são setores-alvo e ainda não há clientes confirmados nesses setores, "Setores em foco" é mais honesto do que "Setores" a solo — alinhado com o valor "Honesto" que o `sobre.html` já reivindica.

## 6. O que NÃO mudaria

- O tom geral (direto, sem hype, PT-PT) está consistente em todas as páginas — não precisa de intervenção.
- O padrão de componentes (`page-hero`, `problem-grid`, `method-grid`, `pillars-grid`, `cta-banner`) é reutilizável e suficiente para a nova página; não é preciso inventar componentes novos.
- O ritmo de secções "dark" (uma por página, a marcar o bloco mais importante) está equilibrado — não sobrecarregar a nova página com mais do que uma.

## 7. Resumo de prioridade

**Corrigir já (antes ou em paralelo com a implementação do Agente de Gestão):**
1. Ligar `/contacto` a um endpoint real (mesmo que só envie email, não pode continuar simulado).
2. Confirmar que todas as edições de nav/rodapé vão para `app/javascript/application.js`, não para os ficheiros da raiz.
3. Corrigir a contradição de preço do curso em `servicos.html`.

**Incluir na implementação do Agente de Gestão:**
4. Consolidar nav (mover "Método" para dentro de Serviços, ou aceitar 8 itens conscientemente).
5. Fundir a secção de Casos da homepage com a introdução ao Agente de Gestão, em vez de acrescentar uma 8ª secção.
6. Cross-link com a página de Fundos Europeus.
7. Separação visual self-serve vs. consultivo em `servicos.html`.

**Depois, sem pressa:**
8. Link direto dos cursos a partir de `servicos.html`.
9. Rótulo mais honesto na barra de setores.
10. Arquivar os HTML/JS duplicados da raiz e de `static_site_backup/`.
