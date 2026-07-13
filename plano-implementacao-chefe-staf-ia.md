# Plano de Implementação — Chefe de Staf IA (Fase 1) · Arquitetura Hermes-core

Documento interno de execução. Proposta adjudicada: 3.750 EUR + 500 EUR infra/ano. Prazo: 3 semanas + 1 mês de acompanhamento.
v2 (2026-07-13): arquitetura revista para Hermes como núcleo do agente, após clarificação de requisitos (1 conta partilhada, agente com capacidade de operar, dashboard separado).

---

## 1. Decisão de arquitetura

### Requisitos que definem a escolha

- 1 conta partilhada, 3 pessoas a usar → modelo single-operator do Hermes serve.
- O cliente fala com o agente e ele **opera**: cria alertas a pedido, regista ideias/projetos/requisitos, faz follow-up. Isto exige memória persistente, scheduling e capacidade de ação — que o Hermes traz de série (cron, memória 3 camadas, skills).
- Dashboard criado separadamente; o agente usa-o apenas como fonte de informação.
- Já operamos Hermes internamente → conhecemos os failure modes e o custo de manutenção baixa.

### Arquitetura

```
Google Sheets ─┐
Google Drive  ─┤→ Workers de sync (cron) → PostgreSQL → Dashboard (deliverable separado)
Gmail (labels)─┘                              ↓  ↑
                                     Motor de alertas standard
                                              ↑
                     HERMES (núcleo do agente, lockdown de produção)
                     memória · cron/alertas ad-hoc · tools de leitura da BD
                                              ↑
                     Web chat UI (endpoint OpenAI-compatible) atrás de Caddy
                     — login único partilhado —
```

Princípio: **o determinístico não depende do LLM.** Sync, dashboard e alertas standard (tarefa atrasada, sem responsável) correm sobre a BD com regras fixas. O Hermes lê da BD, responde no chat, e cria por cima disso os alertas/lembretes *ad-hoc* que o cliente lhe pedir em linguagem natural.

### Lockdowns de produção (não negociáveis)

1. **Escrita limitada ao interno**: alertas, notas, tarefas, lembretes, memória. Email só leitura. Nenhuma ação externa (enviar emails, mexer em plataformas do cliente) na fase 1 — fica para módulos futuros com confirmação humana.
2. **Self-evolution desligada**: sem auto-criação de skills em produção. Skills são escritas/aprovadas por nós e versionadas no repo.
3. **Versão pinada**: updates do Hermes testados primeiro no nosso setup interno, nunca direto na produção do cliente.
4. **Whitelist de tools**: só as tools que definirmos; sem execução arbitrária de código sobre dados do cliente.
5. **Logs completos** de conversas e ações do agente (auditabilidade).

### Stack

| Componente | Escolha | Notas |
|---|---|---|
| Servidor | DO Droplet 2GB + backups | Hermes + Postgres + UI cabem em 2GB; escalar a 4GB se preciso |
| Runtime | Docker Compose (hermes, db, ui, caddy) | Reproduzível |
| Agente | **Hermes (Nous Research)**, versão pinada | MIT, self-hosted |
| LLM | OpenAI API (config no Hermes; mini para tarefas simples) | Cliente paga consumo; limite de gasto na conta |
| BD | PostgreSQL | Fonte de verdade dos dados operacionais |
| Sync | Workers Python + cron | Sheets/Drive/Gmail → BD |
| Chat UI | Open WebUI ou hermes-web-ui, via endpoint OpenAI-compatible do Hermes | Atrás de Caddy; avaliar os dois em staging, escolher o mais estável |
| Auth | Login único partilhado (Caddy basic auth ou auth da UI) | 1 conta, 3 pessoas |
| Dashboard | App web separada, lê a BD | Deliverable próprio; agente consome-a como fonte |
| Proxy/SSL | Caddy | Let's Encrypt automático |

---

## 2. Pré-requisitos a pedir ao cliente (enviar já)

A timeline só conta a partir dos acessos (a proposta protege-nos).

- [ ] Links das Google Sheets de gestão + explicação das colunas
- [ ] Pastas do Drive relevantes
- [ ] Partilha com a service account (email enviado por nós após criação)
- [ ] Caixa de email + label (ex.: "ChefeStaf") ou remetentes a monitorizar — **só leitura**
- [ ] Nome do sistema POS/faturação e se tem API (validação técnica antes de assumir)
- [ ] Subdomínio pretendido + acesso DNS, ou subdomínio nosso
- [ ] Regras de alerta standard iniciais (o que é "atrasado", quem é notificado)
- [ ] Lista de restaurantes e responsáveis
- [ ] Confirmar: 1 login partilhado pelas 3 pessoas

## 3. Fase 0 — Infraestrutura (Semana 1, dias 1–2)

1. Droplet Ubuntu LTS 2GB + backups automáticos semanais.
2. Hardening: user não-root, SSH por chave, UFW (22/80/443), fail2ban, unattended-upgrades.
3. Docker + Compose; repo Git privado (`hermes/` config, `sync/`, `dashboard/`, `deploy/`).
4. Compose: `hermes`, `db` (Postgres + volume), `ui`, `caddy`.
5. Subdomínio → droplet; SSL via Caddy.
6. Backup diário: pg_dump + **diretórios de memória/config do Hermes** → DO Spaces. Teste de restore.

## 4. Fase 1 — Camada de dados (Semana 1, dias 3–5)

1. Google Cloud: Sheets/Drive API via service account; Gmail via OAuth da conta do cliente (`gmail.readonly`).
2. Modelo de dados: `restaurants`, `tasks`, `documents`, `emails`, `alerts`, `agent_requests` (pedidos/ideias registados pelo agente), `sync_runs`.
3. Workers de sync: Sheets (mapeamento de colunas em YAML), Drive (metadados), Gmail (label autorizado). Sheets 30–60 min; Drive/Gmail 2–4x/dia.
4. Motor de alertas standard (job pós-sync, regras do §2, anti-duplicação).
5. Alerta interno para nós se um sync falhar 2x.

## 5. Fase 2 — Hermes: instalação, lockdown e tools (Semana 2, dias 1–3)

1. Instalar Hermes (versão pinada = a que corre no nosso setup interno testado).
2. Configurar LLM (OpenAI), PT-PT, identidade "Chefe de Staf" da operação do cliente.
3. Aplicar lockdowns (§1): desligar self-evolution, whitelist de tools, escrita só interna.
4. Skills/tools custom (escritas por nós, no repo):
   - `get_tasks` / `get_overview` / `search_documents` / `get_recent_emails` / `get_alerts` — leitura da BD
   - `create_alert_rule` — o cliente pede "avisa-me quando/sobre X" → regra registada (via cron do Hermes ou regra na BD)
   - `log_request` — registar ideia/requisito/projeto em `agent_requests` com follow-up agendado
   - `set_reminder` — lembretes pontuais
5. System prompt: responde só com base nas tools, cita a origem, nunca inventa números, diz o que não sabe; pedidos fora de âmbito → regista em `agent_requests` e informa que será avaliado.
6. Expor endpoint OpenAI-compatible; ligar a UI de chat; login partilhado.
7. Testes: perguntas operacionais reais + pedidos de ação ("cria um alerta para...", "lembra-te que...", "o que te pedi esta semana?").

## 6. Fase 3 — Dashboard (Semana 2, dias 3–5)

Deliverable separado, sem LLM: cartões por restaurante (abertas/atrasadas/sem responsável), lista de prioridades filtrável, alertas ativos (standard + criados via agente, identificados), secção "precisa de acompanhamento", **pedidos registados ao agente** (`agent_requests` — o cliente vê que o que pediu ficou registado), timestamp do último sync.

Digest diário por email (alertas + pendentes), frequência a validar.

**Marco Semana 2**: sessão de validação com a equipa (chat + dashboard).

## 7. Fase 4 — Testes e hardening (Semana 3, dias 1–3)

1. Ajustes do feedback da validação.
2. Testes de robustez: sheets malformadas, fontes em baixo, perguntas fora de âmbito, pedidos de ação não permitidos (deve recusar e registar, não tentar).
3. **Red-team ao agente**: tentar levá-lo a agir fora da whitelist, a inventar dados, a expor informação de outra fonte. Corrigir prompt/config.
4. Segurança: BD não exposta, secrets fora do Git, rate limit no login, limite de gasto OpenAI, logs a funcionar.
5. Restore de teste (BD + memória do Hermes).

## 8. Fase 5 — Entrega e onboarding (Semana 3, dias 4–5 + 1º mês)

1. Deploy final; credenciais do login partilhado.
2. Onboarding (1h): o que o agente sabe, o que pode fazer (pedir alertas, registar ideias) e o que não faz na fase 1 (ações externas) — gerir expectativas face ao imaginário "chief of staff" do post do Eric Osiu.
3. Mini-guia (1–2 pág.) com exemplos de pedidos.
4. Doc interno: deploy, restore, update do Hermes (staging→prod), adicionar folha ao sync, adicionar skill.
5. Faturar 70% (2.625 EUR).
6. 1º mês: registar horas (máx. 10h oferta); afinação de regras, mapeamentos e prompt entram aqui. Rever consumo OpenAI e reportar ao cliente.

## 9. POS/Faturação (condicional)

Só com API oficial confirmada: worker de sync + cartão no dashboard + tool `get_sales`. Sem API → módulo futuro (proposta §8 cobre-nos). Sem scraping frágil na fase 1.

## 10. Custos operacionais (vs 500 EUR/ano)

Droplet 2GB + backups ~240 EUR · domínio ~20 EUR · Spaces ~60 EUR · margem no resto. Se o Hermes exigir 4GB, ~430 EUR/ano — ainda dentro, sem margem; monitorizar RAM na semana 1. OpenAI à parte (est. 10–30 EUR/mês; limite de gasto configurado).

## 11. Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Cliente atrasa acessos | Checklist §2 no dia 1; timeline condicionada (na proposta) |
| Update do Hermes parte produção | Versão pinada; staging no nosso setup interno primeiro |
| Agente age fora do esperado | Lockdowns §1 + red-team na fase 4 + logs |
| Expectativa "faz tudo" (post viral) | Onboarding define âmbito fase 1; pedidos fora de âmbito ficam registados em `agent_requests` → pipeline natural para vender módulos futuros |
| Folhas mudam de estrutura | Mapeamento YAML + alerta interno de sync |
| POS sem API | Condicional (§9), nunca prometido |
| Tokens surpreendem | Limite de gasto + relatório no 1º mês |
| Scope creep no mês de oferta | Registar horas; além das 10h → 75 EUR/h |

## 12. Checklist final de entrega

- [ ] HTTPS + login partilhado funcional
- [ ] Syncs sem erros há ≥3 dias
- [ ] Dashboard com dados reais + timestamp de sync
- [ ] Alertas standard a disparar; alerta criado via chat a funcionar ponta-a-ponta
- [ ] `log_request` e `set_reminder` testados ("o que te pedi?" devolve corretamente)
- [ ] Red-team passado; self-evolution confirmadamente desligada
- [ ] 10 perguntas-tipo respondidas corretamente
- [ ] Backup + restore testados (BD + memória Hermes)
- [ ] Limite de gasto OpenAI ativo
- [ ] Guia + onboarding feitos; doc interno no repo
- [ ] Fatura final emitida
