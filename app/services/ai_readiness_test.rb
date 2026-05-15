class AiReadinessTest
  def self.option(id, text, **scores)
    signals = Array(scores.delete(:signals))
    {
      id: id,
      text: text,
      scores: scores.transform_keys(&:to_s),
      signals: signals
    }
  end

  DIMENSIONS = {
    "foundations" => {
      label: "Fundamentos de IA",
      low: "Há ainda alguma confusão sobre o que a IA faz bem, onde falha e porque pode responder com segurança aparente mesmo quando está errada.",
      medium: "Já existe uma base funcional, mas ainda vale consolidar limites, casos de uso e critérios para escolher a ferramenta certa.",
      high: "Demonstra boa leitura dos limites dos modelos e da forma como devem ser usados em contexto profissional."
    },
    "prompting" => {
      label: "Prompting e workflow",
      low: "Os pedidos à IA ainda tendem a depender de tentativa e erro, com pouco contexto, formato ou critério de qualidade.",
      medium: "Já há noção de estrutura, mas há margem para transformar prompts soltos em métodos repetíveis de trabalho.",
      high: "Mostra capacidade para orientar a IA com contexto, exemplos, restrições e critérios claros."
    },
    "evaluation" => {
      label: "Avaliação de outputs",
      low: "O maior risco está na validação: outputs plausíveis podem entrar no trabalho antes de serem verificados.",
      medium: "Existe cuidado com a verificação, mas pode ser mais sistemático em dados, fontes, pressupostos e impacto.",
      high: "Tem uma boa postura crítica perante outputs de IA e percebe que qualidade não é só texto bem escrito."
    },
    "responsible" => {
      label: "Segurança e RGPD",
      low: "A prioridade deve ser definir regras de dados, ferramentas aprovadas e revisão humana antes de escalar o uso.",
      medium: "Há consciência de risco, mas falta transformar essa consciência em política interna simples e aplicável.",
      high: "Demonstra maturidade no uso responsável: dados, privacidade, revisão humana e limites operacionais."
    },
    "automation" => {
      label: "Automação e processos",
      low: "Ainda é cedo para automatizar processos críticos. Primeiro convém mapear tarefas, dados, riscos e métricas.",
      medium: "Existem bons sinais para pequenos pilotos, desde que sejam medidos e tenham guardrails claros.",
      high: "Mostra prontidão para pensar IA como workflow, piloto mensurável ou automação assistida."
    }
  }.freeze

  PROFILES = {
    "foundations" => {
      title: "Primeiros fundamentos",
      path: "curso-fundamentos.html",
      summary: "O melhor próximo passo é criar literacia prática antes de avançar para automações. A prioridade é perceber capacidades, limites, prompting, validação e segurança."
    },
    "practical_user" => {
      title: "Utilizador prático em consolidação",
      path: "curso-fundamentos.html",
      summary: "Já há contacto útil com IA, mas ainda existem fragilidades que podem criar erros, desperdício de tempo ou uso pouco seguro. O foco deve ser método e consistência."
    },
    "workflow_ready" => {
      title: "Pronto para workflows assistidos",
      path: "curso-proficiencia.html",
      summary: "Existe maturidade suficiente para transformar uso individual em workflows repetíveis, com validação, métricas e guardrails."
    },
    "implementation_ready" => {
      title: "Pronto para diagnóstico de implementação",
      path: "book-call.html",
      summary: "O perfil indica que já faz sentido olhar para processos reais, oportunidades de automação e pilotos mensuráveis dentro da empresa."
    }
  }.freeze

  QUESTIONS = [
    {
      id: "q1",
      dimension: "foundations",
      text: "Recebe um relatório longo e pede à IA um resumo executivo para enviar à direção. Qual é a melhor forma de enquadrar o resultado?",
      options: [
        option("a", "Usar o resumo como primeira versão, verificando números, conclusões e omissões relevantes.", foundations: 3, evaluation: 2),
        option("b", "Usar o resumo se o texto estiver claro, porque a IA leu o documento completo.", foundations: 1, evaluation: 1, signals: ["overtrust"]),
        option("c", "Pedir três versões e escolher a que parecer mais profissional.", foundations: 2, evaluation: 1),
        option("d", "Evitar usar IA neste caso, porque resumos de documentos são demasiado arriscados.", foundations: 1)
      ]
    },
    {
      id: "q2",
      dimension: "prompting",
      text: "Tem de pedir à IA para preparar uma primeira versão de proposta comercial. Qual é o pedido mais forte?",
      options: [
        option("a", "Explicar cliente, objetivo, oferta, restrições, tom, estrutura, exemplos e critérios para rever a proposta.", prompting: 3),
        option("b", "Enviar notas soltas da reunião e pedir uma proposta convincente.", prompting: 1, signals: ["vague_prompting"]),
        option("c", "Pedir uma proposta curta primeiro e depois ir corrigindo por iterações.", prompting: 2),
        option("d", "Dar todos os documentos disponíveis e pedir à IA para decidir o que é importante.", prompting: 1, evaluation: 1, signals: ["vague_prompting"])
      ]
    },
    {
      id: "q3",
      dimension: "evaluation",
      text: "A IA apresenta uma análise muito convincente sobre tendências de mercado, mas não indica fontes. O que faz?",
      options: [
        option("a", "Usa como hipótese inicial e pede fontes verificáveis, procurando confirmar os pontos críticos fora da IA.", evaluation: 3),
        option("b", "Usa internamente, mas evita mostrar ao cliente até a linguagem estar mais prudente.", evaluation: 1),
        option("c", "Pede à IA para adicionar fontes e assume que isso resolve a validação.", evaluation: 1, signals: ["overtrust"]),
        option("d", "Descarta a análise por não vir com fontes desde o início.", evaluation: 2)
      ]
    },
    {
      id: "q4",
      dimension: "responsible",
      text: "Uma equipa quer colar tickets reais de clientes numa ferramenta pública de IA para acelerar respostas. Qual é a melhor decisão?",
      options: [
        option("a", "Definir primeiro dados permitidos, anonimização, ferramenta aprovada e revisão humana das respostas.", responsible: 3),
        option("b", "Permitir se removerem nomes e emails antes de colar os tickets.", responsible: 1, signals: ["privacy_risk"]),
        option("c", "Começar com poucos tickets para testar valor antes de criar política interna.", responsible: 1, automation: 1, signals: ["privacy_risk"]),
        option("d", "Usar apenas para tickets antigos, porque o risco operacional é menor.", responsible: 1, signals: ["privacy_risk"])
      ]
    },
    {
      id: "q5",
      dimension: "automation",
      text: "Qual destes projetos é o melhor primeiro piloto de IA numa PME?",
      options: [
        option("a", "Classificar pedidos repetitivos, sugerir encaminhamento e medir tempo poupado com revisão humana.", automation: 3),
        option("b", "Criar um assistente geral para todos os departamentos e ajustar depois conforme utilização.", automation: 1, signals: ["measurement_gap"]),
        option("c", "Automatizar o processo mais caro da empresa para maximizar impacto desde o primeiro mês.", automation: 1, signals: ["premature_automation"]),
        option("d", "Começar por uma demonstração visível para gerar adesão interna, mesmo sem métrica fechada.", automation: 2, signals: ["measurement_gap"])
      ]
    },
    {
      id: "q6",
      dimension: "foundations",
      text: "Um colaborador diz: 'a IA errou, portanto esta tecnologia ainda não serve para a nossa empresa'. Qual é a resposta mais madura?",
      options: [
        option("a", "Analisar se falhou por falta de contexto, tarefa mal definida, dados fracos, ferramenta errada ou limite do modelo.", foundations: 3, evaluation: 2),
        option("b", "Testar uma versão paga antes de decidir, porque modelos melhores reduzem a maioria dos erros.", foundations: 1, signals: ["overtrust"]),
        option("c", "Concordar parcialmente e limitar IA a tarefas criativas, onde o erro tem menos impacto.", foundations: 2),
        option("d", "Criar uma lista de erros e pedir à equipa para evitar esses prompts no futuro.", foundations: 2, prompting: 1)
      ]
    },
    {
      id: "q7",
      dimension: "prompting",
      text: "A IA devolveu uma resposta genérica a uma tarefa importante. Qual é o melhor próximo passo?",
      options: [
        option("a", "Explicar o que falhou, dar exemplo de boa resposta, critérios de qualidade e contexto adicional.", prompting: 3),
        option("b", "Pedir uma resposta mais específica e comparar com a primeira versão.", prompting: 2),
        option("c", "Mudar para outro modelo para perceber se o problema é da ferramenta.", prompting: 1),
        option("d", "Dividir a tarefa em partes menores e pedir uma secção de cada vez.", prompting: 2)
      ]
    },
    {
      id: "q8",
      dimension: "evaluation",
      text: "A IA criou uma tabela com recomendações de fornecedores. O texto parece bom, mas alguns dados foram inferidos. Como deve usar esse output?",
      options: [
        option("a", "Separar factos de inferências, validar dados críticos e só depois usar a recomendação.", evaluation: 3),
        option("b", "Usar a tabela como shortlist inicial, desde que a decisão final continue humana.", evaluation: 2),
        option("c", "Pedir à IA para rever a própria tabela e assinalar incertezas.", evaluation: 1, signals: ["overtrust"]),
        option("d", "Usar a recomendação se coincidir com a experiência prévia da equipa.", evaluation: 1)
      ]
    },
    {
      id: "q9",
      dimension: "responsible",
      text: "A empresa quer incentivar o uso de IA, mas sem travar a equipa com burocracia. O que deve existir no mínimo?",
      options: [
        option("a", "Lista simples de ferramentas aprovadas, dados proibidos, casos que exigem revisão e exemplos permitidos.", responsible: 3),
        option("b", "Uma recomendação geral para não partilhar informação sensível.", responsible: 1, signals: ["privacy_risk"]),
        option("c", "Uma ferramenta oficial e liberdade para a equipa experimentar dentro dela.", responsible: 2),
        option("d", "Um canal interno onde as pessoas perguntam antes de usar dados de clientes.", responsible: 2)
      ]
    },
    {
      id: "q10",
      dimension: "automation",
      text: "A equipa quer criar um agente que leia emails, consulte dados internos e responda automaticamente. Qual é a melhor abordagem?",
      options: [
        option("a", "Mapear o fluxo, começar com sugestões em vez de envio automático, definir limites e medir erro/tempo poupado.", automation: 3, responsible: 2),
        option("b", "Lançar primeiro em emails menos críticos e aumentar autonomia à medida que corre bem.", automation: 2, signals: ["premature_automation"]),
        option("c", "Criar o agente com acesso limitado e pedir à equipa para corrigir erros durante as primeiras semanas.", automation: 2),
        option("d", "Automatizar só depois de a equipa documentar todas as exceções possíveis.", automation: 1)
      ]
    },
    {
      id: "q11",
      dimension: "automation",
      text: "Quando usa IA numa tarefa importante, o que acontece com mais frequência?",
      options: [
        option("a", "Uso como rascunho, valido pontos críticos e adapto antes de integrar no trabalho.", prompting: 1.5, evaluation: 1.5),
        option("b", "Peço várias versões e escolho a que parece mais forte.", prompting: 1, evaluation: 0.5),
        option("c", "Tenho prompts ou passos reutilizáveis para tarefas recorrentes.", prompting: 1.5, automation: 1.5),
        option("d", "Uso sobretudo para acelerar escrita e organização, sem processo fixo.", prompting: 0.75, evaluation: 0.75)
      ]
    },
    {
      id: "q12",
      dimension: "evaluation",
      text: "Quando encontra uma tarefa repetitiva que talvez pudesse ser melhorada com IA, qual é o seu primeiro instinto?",
      options: [
        option("a", "Perceber volume, variação, risco, dados necessários e métrica antes de testar.", automation: 1.5, evaluation: 1.5),
        option("b", "Testar rapidamente numa ferramenta de IA e decidir pelo valor percebido.", automation: 1, signals: ["measurement_gap"]),
        option("c", "Procurar primeiro se já existe uma ferramenta pronta para esse caso.", automation: 1, foundations: 1),
        option("d", "Evitar mexer até haver tempo para redesenhar o processo completo.", automation: 0.5)
      ]
    }
  ].freeze

  SIGNAL_FEEDBACK = {
    "overtrust" => "Há sinais de confiança excessiva em respostas plausíveis. O relatório recomenda criar hábitos de verificação antes de usar outputs em decisões reais.",
    "vague_prompting" => "As respostas indicam que a qualidade dos pedidos pode melhorar bastante com contexto, exemplos, formato e critérios claros.",
    "privacy_risk" => "Existe risco no tratamento de dados e na escolha de ferramentas. Antes de escalar IA, convém definir regras simples de segurança e RGPD.",
    "premature_automation" => "Há tendência para avançar depressa para automação sem processo suficientemente claro. O caminho mais seguro é mapear, medir e pilotar.",
    "measurement_gap" => "A medição de impacto ainda precisa de ser mais objetiva. Bons pilotos começam com uma métrica definida antes da demo."
  }.freeze

  class << self
    def public_questions
      QUESTIONS.map do |question|
        question.slice(:id, :text).merge(
          options: question[:options].map { |option| option.slice(:id, :text) }
        )
      end
    end

    def score(answers)
      normalized_answers = answers.to_h.transform_values(&:to_s)
      totals = Hash.new(0)
      max = Hash.new(0)
      signals = Hash.new(0)

      QUESTIONS.each do |question|
        question_max_scores(question).each { |dimension, value| max[dimension] += value }

        selected = question[:options].find { |option| option[:id] == normalized_answers[question[:id]] }
        next unless selected

        selected[:scores].each { |dimension, value| totals[dimension.to_s] += value }
        selected[:signals].each { |signal| signals[signal] += 1 }
      end

      dimension_scores = DIMENSIONS.keys.to_h do |dimension|
        pct = max[dimension].positive? ? ((totals[dimension].to_f / max[dimension]) * 100).round : 0
        [dimension, pct.clamp(0, 100)]
      end

      overall = (dimension_scores.values.sum.to_f / dimension_scores.size).round
      profile = profile_for(overall, dimension_scores)
      strengths = dimension_notes(dimension_scores, :strengths)
      priorities = dimension_notes(dimension_scores, :priorities)

      {
        answers: normalized_answers,
        overall_score: overall,
        dimension_scores: dimension_scores,
        signals: signal_notes(signals),
        strengths: strengths,
        priorities: priorities,
        profile_key: profile[:key],
        profile_title: profile[:title],
        profile_summary: profile[:summary],
        recommended_path: profile[:path]
      }
    end

    private

    def question_max_scores(question)
      question[:options].each_with_object(Hash.new(0)) do |option, memo|
        option[:scores].each do |dimension, value|
          memo[dimension] = [memo[dimension], value].max
        end
      end
    end

    def profile_for(overall, dimension_scores)
      key =
        if overall >= 78 && dimension_scores["responsible"] >= 65 && dimension_scores["automation"] >= 70
          "implementation_ready"
        elsif overall >= 66 && dimension_scores["responsible"] >= 55
          "workflow_ready"
        elsif overall >= 43
          "practical_user"
        else
          "foundations"
        end

      PROFILES.fetch(key).merge(key: key)
    end

    def dimension_notes(dimension_scores, type)
      selected = dimension_scores.select { |_dimension, score| type == :strengths ? score >= 70 : score < 60 }
      selected = dimension_scores.sort_by { |_dimension, score| score }.first(2).to_h if type == :priorities && selected.empty?
      selected.map do |dimension, score|
        copy_key = score >= 70 ? :high : score >= 50 ? :medium : :low
        {
          key: dimension,
          label: DIMENSIONS.fetch(dimension).fetch(:label),
          score: score,
          copy: DIMENSIONS.fetch(dimension).fetch(copy_key)
        }
      end
    end

    def signal_notes(signals)
      signals.select { |_key, count| count.positive? }.sort_by { |_key, count| -count }.map do |key, count|
        {
          key: key,
          count: count,
          copy: SIGNAL_FEEDBACK.fetch(key)
        }
      end
    end
  end
end
