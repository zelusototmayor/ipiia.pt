class CourseCatalog
  Course = Struct.new(:slug, :title, :subtitle, :price_cents, :certificate_name, :modules, :quiz, keyword_init: true) do
    def lessons
      modules.flat_map { |mod| mod[:lessons] }
    end

    def lesson(key)
      lessons.find { |item| item[:key] == key.to_s }
    end

    def first_lesson
      lessons.first
    end

    def next_lesson_key(key)
      index = lessons.index { |item| item[:key] == key.to_s }
      lessons[index + 1]&.fetch(:key) if index
    end
  end

  FUNDAMENTOS = Course.new(
    slug: "fundamentos-ia-trabalho",
    title: "Fundamentos de IA para o Trabalho",
    subtitle: "Use IA com método, segurança e utilidade concreta no trabalho diário.",
    price_cents: 3999,
    certificate_name: "Certificado de Fundamentos de IA para o Trabalho",
    modules: [
      {
        key: "m1",
        title: "O que a IA faz bem e mal",
        objective: "Criar literacia realista sobre capacidades, limites e riscos.",
        lessons: [
          {
            key: "m1-l1",
            title: "O que é IA generativa em linguagem simples",
            duration: "5 min",
            objective: "Perceber a IA generativa como ferramenta de apoio, não como oráculo.",
            explanation: [
              "IA generativa é software treinado para produzir texto, estruturas, ideias, código, imagens ou análises a partir de padrões aprendidos. Quando escreve uma resposta, não está a consultar uma verdade final: está a prever uma continuação provável com base no pedido e no contexto que recebeu.",
              "Isto torna a IA muito útil para rascunhos, comparação de opções, estruturação de informação e aceleração de tarefas. Também significa que uma resposta pode soar confiante e estar incompleta, desatualizada ou errada."
            ],
            example: "Em vez de pedir 'explica este contrato', peça 'resume este contrato para uma pessoa não jurídica, separando obrigações, riscos, datas e pontos que devem ser validados por um advogado'.",
            exercise: "Escolha um tema que conhece bem e peça à IA uma explicação curta. Assinale três pontos que precisariam de validação antes de usar essa explicação no trabalho.",
            template: "Explica [tema] em linguagem simples para [público]. No fim, lista: 1) pressupostos que usaste, 2) pontos que posso validar, 3) riscos de interpretar mal a resposta.",
            checkpoint: [ "IA generativa gera respostas prováveis, não verdades garantidas.", "Uma resposta clara pode conter erros.", "O utilizador continua responsável pela validação." ],
            completion: "Consegue explicar, numa frase, porque uma resposta convincente pode estar errada."
          },
          {
            key: "m1-l2",
            title: "Onde a IA cria valor no trabalho",
            duration: "6 min",
            objective: "Identificar tarefas onde a IA pode poupar tempo sem aumentar risco.",
            explanation: [
              "O primeiro valor da IA aparece em tarefas de linguagem e estrutura: escrever, resumir, transformar notas em planos, comparar opções, preparar reuniões, criar checklists, organizar documentos e gerar primeiras versões.",
              "A melhor oportunidade raramente é 'usar IA em tudo'. É escolher tarefas frequentes, com input claro, baixo risco e revisão humana natural."
            ],
            example: "Um comercial pode transformar notas de reunião num follow-up estruturado; RH pode criar um checklist de onboarding; operações pode converter uma explicação informal num procedimento simples.",
            exercise: "Liste cinco tarefas semanais onde gasta tempo a escrever, resumir, comparar ou estruturar informação.",
            template: "Tenho estas tarefas recorrentes: [lista]. Classifica cada uma por potencial de poupança de tempo, risco e facilidade de validação. Recomenda as duas melhores para começar.",
            checkpoint: [ "Comece por tarefas frequentes.", "Prefira baixo risco e revisão fácil.", "Templates reutilizáveis criam mais valor do que conversas soltas." ],
            completion: "Tem uma lista de cinco tarefas onde a IA pode ajudar."
          },
          {
            key: "m1-l3",
            title: "Onde a IA falha",
            duration: "7 min",
            objective: "Reconhecer falhas típicas antes de usar outputs em contexto profissional.",
            explanation: [
              "A IA pode inventar detalhes, misturar conceitos, ignorar contexto, responder com informação desatualizada ou tratar exceções como regra. Também pode falhar por receber um pedido demasiado vago.",
              "A pergunta prática não é 'a IA erra?'. A pergunta é: 'qual seria o impacto se este output estivesse errado, e como posso validar rapidamente?'."
            ],
            example: "Uma tabela de fornecedores criada por IA pode incluir empresas reais, dados inferidos e critérios subjetivos na mesma resposta. Antes de a usar, separe factos, hipóteses e recomendações.",
            exercise: "Pegue numa resposta gerada por IA e marque cada frase como facto verificável, opinião, inferência ou sugestão.",
            template: "Revê a resposta anterior. Separa factos, inferências e recomendações. Indica o que pode estar errado e como validar cada ponto em menos de 10 minutos.",
            checkpoint: [ "Outputs plausíveis podem estar errados.", "Risco depende do contexto de uso.", "Validação deve fazer parte do workflow." ],
            completion: "Consegue indicar três formas comuns de falha da IA."
          }
        ]
      },
      {
        key: "m2",
        title: "Como falar com IA",
        objective: "Transformar pedidos vagos em pedidos úteis com o framework O.C.F.R.I.",
        lessons: [
          {
            key: "m2-l1",
            title: "O problema dos pedidos vagos",
            duration: "6 min",
            objective: "Perceber porque prompts genéricos geram outputs genéricos.",
            explanation: [
              "Quando pede 'faz um email', a IA tem de adivinhar destinatário, objetivo, relação, tom, contexto, restrições e formato. O resultado pode parecer aceitável, mas raramente encaixa no trabalho real.",
              "Bons pedidos reduzem adivinhação. Dão contexto suficiente para a IA produzir uma primeira versão útil e fácil de rever."
            ],
            example: "Fraco: 'faz um email de follow-up'. Forte: 'escreve um follow-up para um diretor financeiro de uma PME, depois de uma reunião sobre automação de pedidos, com tom consultivo, 140 palavras e 3 próximos passos'.",
            exercise: "Pegue num pedido que já faria à IA e reescreva-o com destinatário, objetivo, contexto, tom e formato.",
            template: "Transforma este pedido vago num pedido forte: [pedido]. Faz perguntas se faltar informação crítica.",
            checkpoint: [ "Pedidos vagos transferem decisões para a IA.", "Contexto e formato melhoram a utilidade.", "O primeiro prompt é uma especificação de trabalho." ],
            completion: "Consegue distinguir um pedido fraco de um pedido forte."
          },
          {
            key: "m2-l2",
            title: "Framework O.C.F.R.I.",
            duration: "8 min",
            objective: "Usar Objetivo, Contexto, Formato, Restrições e Iteração.",
            explanation: [
              "O.C.F.R.I. é uma estrutura simples para pedir trabalho à IA. Objetivo diz o que quer obter. Contexto explica a situação. Formato define a forma da resposta. Restrições limitam erros e desalinhamentos. Iteração indica como melhorar a versão seguinte.",
              "Não precisa de escrever prompts enormes. Precisa de incluir as decisões que normalmente explicaria a uma pessoa antes de delegar uma tarefa."
            ],
            example: "Objetivo: criar proposta. Contexto: cliente PME logística com muitos emails. Formato: 5 secções. Restrições: sem prometer automação total. Iteração: no fim aponta riscos e perguntas em falta.",
            exercise: "Crie um prompt O.C.F.R.I. para uma tarefa real sua.",
            template: "Objetivo: [resultado]\nContexto: [situação, público, dados úteis]\nFormato: [estrutura]\nRestrições: [limites, tom, dados a evitar]\nIteração: [como quero rever e melhorar]",
            checkpoint: [ "Objetivo e contexto reduzem ambiguidade.", "Formato torna o output utilizável.", "Restrições protegem qualidade e segurança." ],
            completion: "Tem um prompt O.C.F.R.I. reutilizável."
          },
          {
            key: "m2-l3",
            title: "Como iterar uma resposta",
            duration: "6 min",
            objective: "Melhorar outputs com feedback específico.",
            explanation: [
              "Iterar não é admitir que o prompt falhou. É o modo normal de trabalhar com IA. A primeira resposta mostra o que a IA entendeu; a segunda pode ajustar detalhe, tom, estrutura e critérios.",
              "Feedback útil é específico: 'mais curto' é melhor do que 'melhora'; 'mantém o tom formal, mas torna os exemplos mais concretos para PMEs portuguesas' é ainda melhor."
            ],
            example: "Depois de receber uma proposta genérica, peça: 'mantém a estrutura, mas troca afirmações abstratas por exemplos de backoffice, vendas e atendimento. Remove promessas difíceis de provar'.",
            exercise: "Escolha uma resposta da IA e faça duas rondas de melhoria: uma de clareza e outra de risco/validação.",
            template: "Revê esta resposta com três objetivos: torna-a mais prática, remove afirmações vagas e assinala pontos que precisam de validação humana.",
            checkpoint: [ "Feedback específico melhora mais do que pedidos genéricos.", "Iteração deve ter critério.", "Peça sempre riscos quando o output vai ser usado no trabalho." ],
            completion: "Consegue pedir uma segunda versão com critérios claros."
          }
        ]
      },
      {
        key: "m3",
        title: "Meta-prompting e colaboração",
        objective: "Usar IA como parceiro que pergunta, critica e compara antes de produzir.",
        lessons: [
          {
            key: "m3-l1",
            title: "Fazer a IA fazer perguntas",
            duration: "6 min",
            objective: "Evitar respostas prematuras quando falta contexto.",
            explanation: [
              "Muitos pedidos profissionais falham porque a IA responde antes de perceber o problema. Meta-prompting muda a dinâmica: em vez de pedir logo uma solução, pede à IA para entrevistar, clarificar e só depois responder.",
              "Isto é especialmente útil para propostas, planos, documentos, decisões e tarefas onde o contexto muda tudo."
            ],
            example: "Antes de criar um plano de comunicação, peça à IA para perguntar sobre público, objetivo, canal, restrições, exemplos, prazo e critérios de sucesso.",
            exercise: "Crie um prompt 'entrevista-me primeiro' para uma tarefa real.",
            template: "Quero criar [resultado]. Antes de responder, faz-me as perguntas essenciais sobre contexto, público, objetivo, formato, restrições, dados sensíveis e critérios de sucesso. Não avances até eu responder.",
            checkpoint: [ "Perguntas reduzem respostas genéricas.", "A IA pode clarificar antes de executar.", "Isto é útil quando o contexto é incompleto." ],
            completion: "Tem um template 'entrevista-me primeiro'."
          },
          {
            key: "m3-l2",
            title: "Pedir crítica antes de melhoria",
            duration: "6 min",
            objective: "Usar IA para encontrar falhas antes de reescrever.",
            explanation: [
              "Quando pede apenas 'melhora isto', a IA tende a polir linguagem. Quando pede crítica primeiro, ela pode identificar pressupostos, lacunas, contradições, riscos e partes pouco claras.",
              "A sequência recomendada é: criticar, escolher prioridades, reescrever. Assim, a melhoria tem direção."
            ],
            example: "Antes de enviar uma proposta, peça uma crítica por clareza, prova, risco comercial, promessa excessiva e próximos passos.",
            exercise: "Submeta um texto seu à IA e peça uma crítica em tabela com problema, impacto e sugestão.",
            template: "Antes de reescrever, critica este texto. Mostra falhas de clareza, pressupostos, riscos, promessas excessivas e informação em falta. Depois recomenda as três melhorias prioritárias.",
            checkpoint: [ "Crítica primeiro evita polimento superficial.", "Riscos devem ser explícitos.", "Melhorar é decidir, não só reescrever." ],
            completion: "Consegue pedir crítica útil antes de uma revisão."
          },
          {
            key: "m3-l3",
            title: "Pedir opções e comparação",
            duration: "6 min",
            objective: "Tomar melhores decisões com alternativas e critérios.",
            explanation: [
              "A IA é forte a gerar opções. O valor aumenta quando pede trade-offs, critérios e recomendação, em vez de apenas uma resposta única.",
              "Para decisões profissionais, peça sempre pelo menos três abordagens, vantagens, riscos, custo de implementação e quando escolher cada uma."
            ],
            example: "Para melhorar atendimento, compare: templates manuais, assistente que sugere respostas, automação parcial com revisão humana.",
            exercise: "Escolha uma decisão pequena no trabalho e peça três abordagens comparadas.",
            template: "Dá-me três abordagens para [problema]. Compara por esforço, risco, rapidez, qualidade e dependências. No fim recomenda uma opção e explica em que condições mudarias de opinião.",
            checkpoint: [ "Opções ajudam a evitar a primeira resposta óbvia.", "Critérios tornam decisões mais claras.", "A recomendação deve explicar pressupostos." ],
            completion: "Consegue pedir alternativas com trade-offs."
          }
        ]
      },
      {
        key: "m4",
        title: "Casos práticos no trabalho",
        objective: "Aplicar IA a tarefas reais por função empresarial.",
        lessons: [
          {
            key: "m4-l1",
            title: "Casos para gestão e administração",
            duration: "7 min",
            objective: "Usar IA para preparar, resumir e estruturar trabalho de gestão.",
            explanation: [
              "Em gestão e administração, IA ajuda a transformar informação dispersa em sínteses, planos, atas, listas de decisão, comparações e próximos passos.",
              "O cuidado principal é não transformar uma síntese em decisão automática. A IA prepara material; a pessoa valida números, prioridades e impacto."
            ],
            example: "Notas de reunião podem virar ata, plano de ação, riscos, responsáveis e email de follow-up.",
            exercise: "Pegue em notas de uma reunião real ou simulada e peça um plano de ação com responsáveis e perguntas pendentes.",
            template: "Transforma estas notas em: resumo executivo, decisões tomadas, ações, responsáveis, riscos e perguntas em aberto. Assinala pontos que parecem inferidos.",
            checkpoint: [ "Gestão beneficia de síntese e estrutura.", "Decisões continuam humanas.", "Notas incompletas devem gerar perguntas." ],
            completion: "Documentou um caso de uso para gestão/administração."
          },
          {
            key: "m4-l2",
            title: "Casos para comercial, marketing e atendimento",
            duration: "8 min",
            objective: "Aplicar IA a comunicação com clientes sem perder controlo.",
            explanation: [
              "Comercial, marketing e atendimento usam IA para emails, follow-ups, propostas, respostas a objeções, variações de mensagem, análise de feedback e criação de conteúdo.",
              "O risco é soar genérico ou prometer demais. Bons prompts incluem público, oferta, objeções, prova, tom e limites."
            ],
            example: "Um follow-up pode incluir resumo da dor do cliente, proposta de próximo passo e uma pergunta concreta para avançar.",
            exercise: "Crie uma resposta a um cliente difícil com tom profissional, empático e limite claro.",
            template: "Escreve uma resposta para [cliente/persona] sobre [situação]. Tom: claro, profissional e sem hype. Inclui empatia, resposta objetiva, próximo passo e limites do que podemos prometer.",
            checkpoint: [ "Contexto comercial muda o tom.", "Promessas devem ser controladas.", "Respostas a clientes exigem revisão humana." ],
            completion: "Criou um template para comunicação com clientes."
          },
          {
            key: "m4-l3",
            title: "Casos para operações, RH e financeiro",
            duration: "8 min",
            objective: "Transformar conhecimento operacional em checklists e processos.",
            explanation: [
              "Operações, RH e financeiro beneficiam de checklists, SOPs, triagem de pedidos, onboarding, documentação, transformação de políticas em guias e análise inicial de informação.",
              "Como estas áreas lidam com dados sensíveis, é essencial remover dados pessoais/confidenciais ou usar ferramentas aprovadas."
            ],
            example: "Um processo explicado num email pode virar SOP com objetivo, passos, exceções, responsáveis, inputs e outputs.",
            exercise: "Escolha uma tarefa repetitiva e peça à IA um procedimento simples com pontos de controlo.",
            template: "Converte esta explicação num SOP: objetivo, quando usar, inputs, passos, exceções, riscos, revisão humana e checklist final. Não inventes dados em falta; faz perguntas.",
            checkpoint: [ "Processos repetitivos são bons candidatos.", "Dados sensíveis exigem cuidado.", "SOPs devem incluir exceções e revisão." ],
            completion: "Tem um caso de uso pessoal documentado."
          }
        ]
      },
      {
        key: "m5",
        title: "Validação, segurança e privacidade",
        objective: "Usar IA de forma responsável em contexto profissional.",
        lessons: [
          {
            key: "m5-l1",
            title: "Dados que não devem ser colocados em IA pública",
            duration: "7 min",
            objective: "Reconhecer dados sensíveis antes de usar IA.",
            explanation: [
              "Dados pessoais, informação confidencial, contratos, dados financeiros, dados de clientes, credenciais, propriedade intelectual sensível e informação interna estratégica não devem ser colocados em ferramentas públicas sem autorização e regras claras.",
              "Anonimizar é útil, mas nem sempre suficiente. Um conjunto de detalhes pode reidentificar pessoas ou clientes."
            ],
            example: "Em vez de colar tickets reais com nomes e emails, transforme-os em cenários anonimizados ou use uma ferramenta empresarial aprovada.",
            exercise: "Classifique oito exemplos do seu trabalho como seguro, usar com cuidado ou evitar.",
            template: "Classifica estes dados antes de eu usar IA: [lista]. Para cada item, diz seguro, usar com cuidado ou evitar, e explica a razão.",
            checkpoint: [ "Privacidade vem antes da produtividade.", "Anonimização parcial pode não chegar.", "Ferramentas aprovadas importam." ],
            completion: "Consegue identificar dados que não deve submeter."
          },
          {
            key: "m5-l2",
            title: "Como validar respostas",
            duration: "7 min",
            objective: "Criar uma rotina simples de validação.",
            explanation: [
              "Validar não significa refazer tudo. Significa focar nos pontos com maior risco: números, fontes, legislação, prazos, nomes, promessas, recomendações e decisões com impacto.",
              "Use fontes oficiais, comparação com documentos internos, revisão humana e perguntas de incerteza."
            ],
            example: "Antes de usar uma análise de mercado, peça à IA para separar factos, hipóteses e pontos que exigem fonte externa.",
            exercise: "Pegue numa resposta da IA e crie uma checklist de validação de cinco pontos.",
            template: "Analisa a tua resposta anterior e mostra: pressupostos usados, pontos que podem estar errados, informação em falta, riscos de uso e validação rápida recomendada.",
            checkpoint: [ "Valide pontos críticos, não tudo por igual.", "Fontes oficiais são preferíveis.", "Peça incerteza explicitamente." ],
            completion: "Tem uma checklist de validação."
          },
          {
            key: "m5-l3",
            title: "Regras simples para uso empresarial",
            duration: "6 min",
            objective: "Definir uma política mínima aplicável no dia-a-dia.",
            explanation: [
              "Uma PME não precisa de começar com uma política longa. Precisa de regras simples: ferramentas permitidas, dados proibidos, usos permitidos, outputs que exigem revisão e responsável por dúvidas.",
              "Estas regras reduzem medo e improviso. A equipa sabe onde pode experimentar e onde deve parar."
            ],
            example: "Permitido: rascunhos sem dados pessoais. Usar com cuidado: dados internos anonimizados. Evitar: contratos de clientes, dados salariais, credenciais e decisões sensíveis sem aprovação.",
            exercise: "Escreva cinco regras de uso de IA para a sua equipa.",
            template: "Ajuda-me a criar uma política simples de IA para uma PME: ferramentas permitidas, dados proibidos, casos permitidos, casos com revisão obrigatória e exemplos práticos.",
            checkpoint: [ "Regras simples aumentam adoção segura.", "Nem tudo deve ser automatizado.", "Revisão humana deve estar definida." ],
            completion: "Tem cinco regras pessoais ou de equipa."
          }
        ]
      },
      {
        key: "m6",
        title: "Primeiro workflow pessoal com IA",
        objective: "Transformar uma tarefa recorrente num sistema pessoal reutilizável.",
        lessons: [
          {
            key: "m6-l1",
            title: "De tarefa solta a workflow",
            duration: "6 min",
            objective: "Ver a IA como parte de um processo repetível.",
            explanation: [
              "Uma conversa isolada pode poupar minutos. Um workflow repetível pode poupar horas. A diferença é ter input, passos, output, validação e critério de sucesso definidos.",
              "O objetivo não é automatizar tudo. É criar uma rotina que possa repetir com qualidade previsível."
            ],
            example: "Para propostas: input de reunião, prompt O.C.F.R.I., crítica de riscos, versão final, checklist de validação e follow-up.",
            exercise: "Escolha uma tarefa que repete semanalmente e descreva input, passos, output e revisão.",
            template: "Transforma esta tarefa recorrente num workflow: input, passos da IA, output esperado, validação humana, frequência e critério de sucesso.",
            checkpoint: [ "Workflow é mais valioso que prompt único.", "Validação faz parte do processo.", "Comece por algo pequeno e recorrente." ],
            completion: "Escolheu uma tarefa recorrente para sistematizar."
          },
          {
            key: "m6-l2",
            title: "Construir o mini-sistema pessoal",
            duration: "8 min",
            objective: "Criar o artefacto final do curso.",
            explanation: [
              "O mini-sistema pessoal junta o que aprendeu: um caso de uso real, um prompt-template, uma rotina de revisão e uma métrica simples de sucesso.",
              "Bons sistemas são específicos: 'preparar follow-ups comerciais às sextas' é melhor do que 'usar IA para vendas'."
            ],
            example: "Tarefa: follow-up pós-reunião. Frequência: semanal. Input: notas e objetivo. Output: email + próximos passos. Validação: tom, promessas, dados. Sucesso: menos 20 minutos por reunião.",
            exercise: "Preencha o template de workflow pessoal. Este texto será usado na submissão final.",
            template: "Tarefa recorrente: [descrição]\nFrequência: [diária/semanal/mensal]\nInput: [o que forneço]\nPassos: [o que a IA deve fazer]\nOutput: [resultado esperado]\nValidação: [como revejo]\nCritério de sucesso: [tempo poupado, qualidade, clareza]",
            checkpoint: [ "O sistema deve caber numa rotina real.", "A métrica pode ser simples.", "O output precisa de revisão definida." ],
            completion: "Tem o mini-sistema pessoal pronto para submeter."
          },
          {
            key: "m6-l3",
            title: "Próximos passos",
            duration: "5 min",
            objective: "Perceber quando uso individual pode virar implementação.",
            explanation: [
              "Quando uma tarefa pessoal se repete em várias pessoas, usa dados consistentes e tem impacto mensurável, pode tornar-se workflow de equipa, automação assistida ou piloto de implementação.",
              "O próximo nível exige desenho de processo, integrações, dados, guardrails, métricas e ownership. Este curso prepara a base; a implementação exige outro grau de rigor."
            ],
            example: "Se três pessoas respondem manualmente ao mesmo tipo de pedido, pode haver oportunidade para triagem assistida, templates aprovados e medição de tempo poupado.",
            exercise: "Identifique um workflow pessoal que poderia ser útil para mais pessoas da empresa.",
            template: "Avalia se este workflow pessoal pode virar piloto de equipa. Analisa volume, variação, dados necessários, riscos, revisão humana e métrica de sucesso.",
            checkpoint: [ "Uso individual revela oportunidades.", "Automação exige processo claro.", "Pilotos devem ter métrica e guardrails." ],
            completion: "Consegue explicar o próximo passo depois dos fundamentos."
          }
        ]
      }
    ],
    quiz: [
      { id: "q1", question: "Qual é a forma mais segura de enquadrar uma resposta de IA?", options: [ "Como fonte fiável, desde que o modelo seja recente e de qualidade", "Como verdade provável, se a resposta citar fontes", "Como primeira versão que precisa de validação", "Como rascunho que só precisa de revisão ortográfica" ], answer: 2 },
      { id: "q2", question: "O que significa o O em O.C.F.R.I.?", options: [ "Origem", "Objetivo", "Operação", "Output" ], answer: 1 },
      { id: "q3", question: "Qual destes dados deve ser evitado numa ferramenta pública sem aprovação?", options: [ "Uma descrição genérica de um processo interno", "Um exemplo inventado com números fictícios", "Uma pergunta conceptual sobre legislação", "Dados de clientes identificáveis" ], answer: 3 },
      { id: "q4", question: "Quando falta contexto para uma tarefa importante, qual é o melhor primeiro pedido?", options: [ "Pedir à IA que faça perguntas antes de responder", "Pedir a resposta num formato mais estruturado", "Dar um exemplo do output esperado e avançar", "Dividir a tarefa em passos mais pequenos" ], answer: 0 },
      { id: "q5", question: "Qual é a principal vantagem de pedir crítica antes de melhoria?", options: [ "Evita que a IA reescreva o texto por completo", "Garante que a segunda versão fica mais curta", "Identifica falhas e riscos antes de polir a linguagem", "Dispensa a revisão humana no fim" ], answer: 2 },
      { id: "q6", question: "Um workflow pessoal com IA deve incluir:", options: [ "O maior número possível de ferramentas, para reduzir dependências", "Input, passos, output, validação e critério de sucesso", "Prompts diferentes em cada utilização, para evitar respostas repetidas", "Automação total, para eliminar o passo de revisão" ], answer: 1 },
      { id: "q7", question: "Qual é um bom primeiro caso de uso numa PME?", options: [ "Um processo crítico, para maximizar o retorno visível", "Uma área onde ninguém tem tempo para rever outputs", "Um caso com dados de clientes, porque é onde se gastam mais horas", "Uma tarefa frequente, clara e fácil de rever" ], answer: 3 },
      { id: "q8", question: "O F em O.C.F.R.I. refere-se a:", options: [ "Fonte", "Frequência", "Formato", "Função" ], answer: 2 },
      { id: "q9", question: "O que deve acontecer antes de usar outputs em decisões relevantes?", options: [ "Validação humana e confirmação nas fontes adequadas", "Pedir à IA um grau de confiança na própria resposta", "Comparar respostas de dois modelos diferentes", "Reformular o prompt e verificar se a resposta se mantém" ], answer: 0 },
      { id: "q10", question: "Qual é uma regra mínima sensata para uso empresarial de IA?", options: [ "Limitar o uso de IA a quem tem formação técnica", "Centralizar todos os pedidos de IA numa só pessoa", "Definir dados proibidos e outputs com revisão obrigatória", "Permitir apenas ferramentas gratuitas, mais fáceis de controlar" ], answer: 2 },
      { id: "q11", question: "Porque é que respostas convincentes podem ser perigosas?", options: [ "Porque a linguagem confiante pode esconder erros", "Porque tendem a ser demasiado longas para rever", "Porque são geradas depressa demais para serem fiáveis", "Porque impedem o utilizador de fazer perguntas de seguimento" ], answer: 0 },
      { id: "q12", question: "Para uma decisão com alternativas, o melhor pedido inclui:", options: [ "A opção mais usada no mercado, para reduzir risco", "Uma recomendação única e direta, para poupar tempo", "A opção mais barata e a mais cara, para ver os extremos", "Três opções com trade-offs e critérios de escolha" ], answer: 3 },
      { id: "q13", question: "Qual é uma boa métrica simples para um workflow pessoal?", options: [ "Número de prompts usados por semana", "Quantidade de texto gerado por sessão", "Tempo poupado ou clareza do output", "Número de ferramentas de IA experimentadas" ], answer: 2 },
      { id: "q14", question: "Quando a IA infere dados numa tabela, deve-se:", options: [ "Pedir mais linhas para diluir o efeito das inferências", "Separar factos de inferências e validar os pontos críticos", "Aceitar a tabela se as fontes citadas parecerem credíveis", "Refazer o pedido até a tabela vir sem avisos de incerteza" ], answer: 1 }
    ]
  )

  COURSES = {
    FUNDAMENTOS.slug => FUNDAMENTOS
  }.freeze

  def self.find(slug)
    COURSES.fetch(slug.to_s)
  end

  def self.fundamentos
    FUNDAMENTOS
  end
end
