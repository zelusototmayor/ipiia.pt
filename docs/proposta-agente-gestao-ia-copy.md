# Proposta: integrar "Agente de Gestão com IA" no ipiia.pt

**Nota de contexto:** o brief original foi escrito a partir da análise de institutoia.pt, que é uma empresa diferente (subscrição de +100 cursos, publiweb360, etc.), não o teu site. Esta proposta pega na estratégia do brief — o conceito de "Agente de Gestão com IA", a escada de autonomia, o modelo de serviço faseado — e aplica-a à estrutura real do ipiia.pt, que hoje é: `index`, `missao`, `metodo`, `servicos`, `teste`, `casos`, `sobre`, `book-call`, `contacto`.

Não existe hoje um `/empresas` nem um `/ia-agentes` a dividir. O ipiia.pt já é 100% B2B/PME — a divisão relevante não é "site de consumidor vs. site de empresas", é **dentro da oferta de serviços**: capacitar pessoas (teste, formação) vs. pôr a IA a trabalhar na operação (diagnóstico, piloto, e agora o Agente de Gestão).

---

## 1. Onde isto encaixa no funil atual

Hoje o método tem 4 fases — Diagnóstico → Priorização → Piloto → Medição — e termina com "decidir juntos o próximo passo" (ver `metodo.html`, `pilar Acompanhamento` em `missao.html`). O Agente de Gestão com IA **não é uma quinta forma de começar** ao lado de Teste/Formação/Diagnóstico/Implementação — é o que acontece **depois** de um piloto correr bem e a empresa quiser continuar a expandir, em vez de terminar num projeto isolado.

Isto resolve um problema real do site atual: "Implementação" hoje soa a projeto fechado ("Piloto IA em 30 dias", "Automação ou agente funcional"). Não há lugar para a promessa de um serviço contínuo, modular, gerido. O Agente de Gestão preenche exatamente essa lacuna, sem contradizer nada do que já existe — é uma evolução natural da Fase 4 (Operação e evolução).

## 2. Mapa de alterações por página

| Página | Alteração | Prioridade |
|---|---|---|
| Nova página `/agente-de-gestao-ia` | Página dedicada completa (copy abaixo) | P1 |
| `index.html.erb` (homepage) | Nova secção entre "Método" e "Serviços" a introduzir o serviço | P1 |
| `servicos.html.erb` | Reagrupar os 4 cards em 2 frentes + acrescentar 5º card do Agente de Gestão | P1 |
| Navegação (`app.js`) | Novo link "Agente de Gestão" | P1 |
| Rodapé (`app.js`) | Novo link na coluna "Serviços" | P1 |
| `metodo.html.erb` | Nota de fecho a ligar Fase 4 ao Agente de Gestão | P2 |
| `missao.html.erb` | Reforçar o pilar "Acompanhamento" com a referência concreta | P2 |
| `casos.html.erb` | Callout no fim a ligar casos → módulos do Agente | P2 |
| `book_call.html.erb` | Nova opção no dropdown "Tema principal" + ajuste ao bloco "o que acontece depois" | P2 |

---

## 3. Copy completo da nova página — `/agente-de-gestao-ia`

Reutiliza os componentes visuais já existentes: `page-hero`, `problem-grid`/`problem-card`, `method-grid`/`method-step`, `pillars-grid`, `offer-card` (para o resumo comercial), e o padrão de FAQ que falta construir (sugiro accordion simples, mesmo estilo dos `problem-card`).

### Hero

> Eyebrow: **Agente de Gestão com IA**
>
> # Uma camada de gestão que vê a sua operação — e ajuda-a a avançar.
>
> A sua empresa continua a trabalhar com as suas pessoas e os seus sistemas. O agente reúne o que está a acontecer em cada um deles, organiza prioridades e ajuda a gestão a decidir mais depressa — com aprovação humana em cada ponto que importa.
>
> Para PMEs com operação recorrente e várias frentes em simultâneo, onde a informação já existe mas está espalhada por demasiados sítios.

CTA primário: `Marcar diagnóstico de operação →` (liga a `book-call.html`, tema pré-selecionado)
CTA secundário: `Ver como funciona ↓` (âncora)

### Secção 2 — O problema

> Eyebrow: **O problema**
> ## A gestão não sofre por falta de software. Sofre por falta de contexto.

`problem-grid` com 4 cards:

01. **Informação espalhada.** Email, folhas de cálculo, PMS, ERP, CRM, mensagens. Cada sistema sabe uma parte — ninguém vê o todo.
02. **Coordenação manual.** O gestor confirma se as tarefas foram feitas, persegue respostas, reconstrói contexto antes de decidir.
03. **Problemas detetados tarde.** Um desvio só aparece quando já custou tempo, dinheiro ou um cliente.
04. **Memória que não fica registada.** Decisões e regras vivem na cabeça de uma pessoa, não no sistema.

### Secção 3 — A solução

> Eyebrow: **A solução**
> ## Uma camada de gestão, não mais uma ferramenta.
>
> É um sistema privado que acompanha a operação a partir das fontes que a empresa autorizar. Reúne contexto, monitoriza prioridades, deteta pendentes e exceções, prepara decisões e ativa rotinas de trabalho. Não substitui o gestor nem os sistemas críticos — aumenta a capacidade de gestão.

Três pilares (`pillars-grid`, reutilizando o padrão de `missao.html`):

- **Vê o que está a acontecer.** Reúne informação dispersa numa visão atual da operação.
- **Sabe o que merece atenção.** Deteta pendentes, desvios, riscos e prioridades antes de crescerem.
- **Ajuda o trabalho a avançar.** Prepara e coordena ações, com o nível de autonomia que a gestão definir.

Tabela curta "não é / é" (evita confundir com chatbot ou automação pontual):

| Não é | É |
|---|---|
| Um chatbot que responde a perguntas | Um sistema que conhece o contexto da operação e acompanha trabalho real |
| Uma automação isolada | Uma fundação comum à qual se acrescentam módulos |
| Um substituto do ERP, PMS ou CRM | Uma camada que liga e dá sentido à informação desses sistemas |
| Uma solução igual para todas as empresas | Um serviço desenhado à volta da operação de cada negócio |

### Secção 4 — Como funciona

> Eyebrow: **Como funciona**
> ## Ligado às fontes da empresa. A agir por eventos, não por perguntas.
>
> O agente liga-se às fontes de informação que a empresa autorizar — email, calendário, sistemas de gestão, documentos, o que fizer sentido em cada caso. A forma exata de o usar fica ao critério de cada gestor: cada operação tem prioridades diferentes, e não há um conjunto fixo de tarefas que sirva a todas.

O que é comum a qualquer configuração:

- **Funciona por eventos, não por perguntas.** Não espera que alguém abra uma conversa. Quando algo acontece — uma alteração, um prazo que se aproxima, uma exceção — o agente age em conformidade: organiza, avisa ou prepara uma ação.
- **Cria alertas quando algo merece atenção.** Um desvio, uma tarefa esquecida, uma informação em falta — sinalizado antes de se tornar um problema maior.
- **Prepara antes de agir.** Quando a ação é sensível, fica pronta à espera de aprovação em vez de ser executada sozinha.
- **Segue as regras da casa.** Cada empresa define o que é normal e o que é exceção; o agente ajusta-se a essas regras — não o contrário.

Nota editorial: evitar prescrever cenários fixos ("resumo da manhã", "antes da reunião") como se fossem funcionalidades já construídas. O mecanismo é real e comum a todos os casos (fontes ligadas, ação por evento, alertas, aprovação); a aplicação concreta varia por empresa e é definida caso a caso.

### Secção 5 — Áreas que pode acompanhar

> Eyebrow: **Módulos**
> ## A fundação é comum. Cada módulo acrescenta uma competência.

Mostrar 4 exemplos fortes (alinhados aos setores já no cred-bar da homepage — Indústria, Retalho, Logística, Serviços financeiros, Saúde, Jurídico, Construção — em vez dos exemplos de restauração/hotelaria do brief, que são casos internos a não expor sem validação):

- **Operação e prioridades** — tarefas, responsáveis, prazos, bloqueios, alertas de trabalho atrasado ou sem responsável.
- **Controlo financeiro e margens** — despesas sem comprovativo, desvios de custo, preparação de informação para validação humana.
- **Equipas e escalas** — ausências, cobertura, comparação entre atividade e custo de pessoal.
- **Clientes e reputação** — resumo de feedback e reclamações, temas recorrentes, sugestões de resposta.

Nota: "Adaptável a qualquer operação recorrente — não um catálogo fechado."

### Secção 6 — Autonomia sob controlo

> Eyebrow: **Confiança**
> ## Autonomia que se conquista, não que se assume.

Escada (`method-grid`, 4 passos): **Observa → Recomenda → Executa com aprovação → Automatiza dentro de regras.** A empresa define o nível por tipo de tarefa.

Princípios de confiança (lista curta, sem juridiquês):

- Acesso apenas às fontes necessárias, com permissões por função e tarefa.
- Validação humana nos pontos críticos.
- Registo do que foi feito e porquê.
- Os dados mantêm-se propriedade da empresa.
- Desenho alinhado com RGPD e minimização de dados.
- Pode suspender uma rotina ou reduzir autonomia a qualquer momento.

### Secção 7 — Como entregamos

Reutiliza o padrão visual de `metodo.html` (`method-grid` + `method-detail`), mas com fases próprias do serviço:

01. **Diagnóstico operacional** — mapeamos como a empresa funciona hoje e escolhemos o primeiro caso de uso.
02. **Fundação do agente** — ligamos as fontes prioritárias, organizamos a memória operacional e definimos limites de autonomia.
03. **Primeiro módulo** — implementamos um fluxo completo, testamos com dados reais, medimos tempo poupado e controlo ganho.
04. **Operação e evolução** — acompanhamos, afinamos regras, acrescentamos módulos, aumentamos autonomia só quando fizer sentido.

Nota comercial (mesmo tom de `servicos.html` — "Sem preços públicos, sem pressão"): *"Serviço à medida, composto por diagnóstico, implementação e acompanhamento contínuo. O primeiro passo é sempre uma conversa de diagnóstico — não uma compra imediata."*

### Secção 8 — Para quem faz sentido

**Bom encaixe:** PMEs lideradas de perto pelo proprietário ou por uma pequena equipa de gestão; operação recorrente com várias frentes em simultâneo; múltiplas unidades, locais ou equipas; informação que já existe mas está dispersa; querem começar por uma prioridade e expandir aos poucos.

**Não é para:** quem procura apenas um chatbot genérico; uma automação pontual muito simples; ausência total de processos ou dados organizados; expectativa de delegar decisões críticas sem supervisão.

### Secção 9 — Perguntas frequentes

- **Isto substitui o nosso ERP, CRM ou PMS?** Não. Liga-se a eles e dá-lhes sentido — os sistemas core continuam a ser a fonte de verdade.
- **Precisamos de ter os dados todos organizados?** Não. Começamos pelo que existe; perceber o que falta faz parte do diagnóstico.
- **O agente pode agir sozinho?** Só dentro dos limites que a gestão definir — nunca em ações sensíveis sem aprovação.
- **Como são protegidos os dados?** Acesso limitado às fontes autorizadas, permissões por função, registo do que foi feito, propriedade dos dados mantém-se da empresa.
- **Quanto tempo demora a implementar?** A fundação e o primeiro módulo seguem o mesmo ritmo do piloto de 30 dias já usado no método do IPIIA.
- **Podemos começar apenas por uma área?** Sim — é a forma recomendada. Um módulo de cada vez.
- **O que acontece numa situação que o agente não conhece?** Sinaliza a exceção e pede orientação humana em vez de decidir sozinho.
- **Qual é a diferença para um chatbot ou uma automação?** Um chatbot responde quando alguém pergunta. Uma automação executa um passo isolado. O Agente de Gestão acompanha a operação de forma contínua e coordena vários fluxos ao mesmo tempo.

### Secção 10 — CTA final

> ## Comece por um diagnóstico de operação.
>
> Mapeamos onde a gestão perde tempo, identificamos um primeiro caso de uso e avaliamos os sistemas e a informação já disponíveis.

`Marcar diagnóstico de operação →` → `book-call.html`

---

## 4. Copy revisto das secções afetadas

### Homepage — nova secção (entre "Método" e "Serviços")

```
Eyebrow: Depois do piloto
H2: Um piloto prova o valor. O Agente de Gestão torna-o permanente.
Lead: Quando o primeiro piloto corre bem, a pergunta natural é "o que mais pode
fazer?". O Agente de Gestão com IA é a camada de gestão contínua que junta
módulos ao longo do tempo — sem recomeçar do zero a cada novo processo.
CTA: Conhecer o Agente de Gestão com IA →  (para /agente-de-gestao-ia)
```

Visual: reutilizar o padrão `mission-teaser` (texto + card lateral) ou um `offer-card featured` isolado, para não competir com a grid de "Quatro formas de começar" logo a seguir.

### `servicos.html` — reestruturar em duas frentes

Adicionar, logo depois do hero da página, uma frase de transição explícita:

> "Duas frentes complementares: **capacitar a equipa** para usar IA no dia a dia, e **pôr a IA a trabalhar na operação** — do piloto pontual à camada de gestão contínua."

Manter os 4 cards existentes (Teste, Formação online, Workshop in-company → agrupados sob "Capacitar a equipa") e acrescentar um 5º card, agrupado sob "Pôr a IA a trabalhar":

```
05 / Camada de gestão
Agente de Gestão com IA
Serviço contínuo · modular
— Fundação comum + módulos por prioridade
— Autonomia progressiva, sempre com aprovação
— Cresce depois do primeiro piloto
Sob proposta · diagnóstico primeiro
[Conhecer o Agente de Gestão →] (/agente-de-gestao-ia)
```

### `metodo.html` — nota de fecho

Antes do CTA final, acrescentar um parágrafo curto:

> "Para empresas que querem continuar depois do piloto, a Fase 4 evolui para um **Agente de Gestão com IA**: a mesma disciplina de medição, aplicada de forma contínua e modular. [Saber mais →]"

### `missao.html` — reforçar o pilar "Acompanhamento"

Acrescentar uma frase ao corpo do pilar já existente:

> "...ficamos até a métrica subir. Para operações que precisam de continuidade, isto tem hoje uma forma concreta: o Agente de Gestão com IA."

### `casos.html` — callout final antes do CTA

> "Vários destes casos podem tornar-se módulos de um Agente de Gestão com IA contínuo, em vez de automações isoladas. [Ver como funciona →]"

### `book_call.html` — dropdown e branch

Acrescentar opção ao `<select id="b-topic">`:

```html
<option>Agente de Gestão com IA</option>
```

E um 5º `problem-card` no bloco "o que acontece depois":

> **05 — Se já tem um piloto a funcionar bem:** Avaliamos evoluir para um Agente de Gestão com IA, módulo a módulo.

### Navegação e rodapé

Nav (`app.js`, depois de "Serviços"):
```html
<a class="nav-link" href="agente-de-gestao-ia.html">Agente de Gestão</a>
```
Rodapé, coluna "Serviços":
```html
<a href="agente-de-gestao-ia.html" class="footer-link">Agente de Gestão com IA</a>
```

Nota: a nav já tem 6 links + CTA. Se ficar sobrecarregada, a alternativa é não duplicar "Casos" no topo e deixar essa ligação só a partir de Serviços/rodapé — mas isso é um ajuste de UI, não de mensagem.

---

## 5. Naming e URL

- **Nome público:** "Agente de Gestão com IA" (claro, em português, distinto de formação/curso).
- **Metáfora de apoio:** "Chief of Staff de IA" — usar uma vez no corpo do texto para ancorar a ideia, depois preferir linguagem em português.
- **URL:** `/agente-de-gestao-ia` (consistente com o padrão de URLs já usado — `book-call`, `curso-fundamentos`).

## 6. Claims a validar antes de publicar

Nenhum destes deve ser inventado no copy final:

- Duração real da fundação + primeiro módulo (assumi "mesmo ritmo do piloto de 30 dias" — confirmar se se mantém para este serviço mais amplo).
- Modelo comercial: setup, mensalidade, custos variáveis.
- Modelo de diagnóstico gratuito ou pago para este serviço especificamente.
- Integrações realmente suportadas hoje (ERP, PMS, CRM específicos).
- Casos internos (restaurantes, Quinta das Margaridas) — não usar como prova pública sem autorização e sem identificar clientes.
- Certificações ou conformidades que podem ser afirmadas publicamente (RGPD é um princípio de desenho, não uma certificação — cuidado para não implicar uma).

## 7. Prioridades

**P1 — obrigatório:** nova página, secção na homepage, reestruturação de `servicos.html`, nav e rodapé.
**P2 — recomendável:** nota em `metodo.html`, reforço em `missao.html`, callout em `casos.html`, dropdown em `book_call.html`.
**P3 — evolução futura:** FAQ expansível dedicado, exemplos por setor, calculadora de maturidade operacional, estudos de caso validados.
