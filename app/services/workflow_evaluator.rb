require "net/http"
require "uri"

class WorkflowEvaluator
  OPENAI_ENDPOINT = "https://api.openai.com/v1/responses"

  SCHEMA = {
    type: "object",
    additionalProperties: false,
    required: [ "score", "approved", "summary", "criteria", "improvements", "provider" ],
    properties: {
      score: { type: "integer", minimum: 0, maximum: 100 },
      approved: { type: "boolean" },
      summary: { type: "string" },
      criteria: {
        type: "array",
        items: {
          type: "object",
          additionalProperties: false,
          required: [ "name", "score", "comment" ],
          properties: {
            name: { type: "string" },
            score: { type: "integer", minimum: 0, maximum: 100 },
            comment: { type: "string" }
          }
        }
      },
      improvements: { type: "array", items: { type: "string" } },
      provider: { type: "string" }
    }
  }.freeze

  def self.evaluate(workflow_text)
    return mock_evaluation(workflow_text) if ENV["OPENAI_API_KEY"].blank?

    response = Net::HTTP.post(
      URI(OPENAI_ENDPOINT),
      request_body(workflow_text).to_json,
      {
        "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
        "Content-Type" => "application/json"
      }
    )
    raise "OpenAI evaluation failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(response.body)
    result = JSON.parse(output_text(parsed))
    result["provider"] = "openai"
    result["approved"] = result["score"].to_i >= CourseEnrollment::CERTIFICATE_THRESHOLD
    result
  end

  def self.request_body(workflow_text)
    {
      model: ENV.fetch("OPENAI_MODEL", "gpt-5.4-mini"),
      input: [
        {
          role: "system",
          content: "És avaliador do IPIIA. Avalia submissões de alunos de um curso básico de IA no trabalho. Sê exigente, prático e justo. Responde apenas no JSON schema pedido."
        },
        {
          role: "user",
          content: <<~PROMPT
            Avalia este mini-workflow pessoal de IA. O certificado exige pelo menos #{CourseEnrollment::CERTIFICATE_THRESHOLD}%.

            Rubrica:
            - Clareza da tarefa recorrente.
            - Input e passos bem definidos.
            - Output esperado concreto.
            - Validação humana e cuidado com privacidade.
            - Critério de sucesso mensurável.
            - Utilidade operacional no trabalho real.

            Submissão:
            #{workflow_text}
          PROMPT
        }
      ],
      text: {
        format: {
          type: "json_schema",
          name: "workflow_evaluation",
          strict: true,
          schema: SCHEMA
        }
      }
    }
  end

  def self.output_text(parsed)
    parsed.fetch("output").flat_map { |item| item.fetch("content", []) }
      .find { |content| content["type"] == "output_text" }
      .fetch("text")
  end

  def self.mock_evaluation(workflow_text)
    keywords = [ "tarefa", "frequência", "input", "passos", "output", "validação", "critério", "sucesso" ]
    hits = keywords.count { |word| workflow_text.downcase.include?(word) }
    length_score = [ workflow_text.length / 8, 35 ].min
    score = [ 45 + (hits * 6) + length_score, 92 ].min

    {
      "score" => score,
      "approved" => score >= CourseEnrollment::CERTIFICATE_THRESHOLD,
      "summary" => "Avaliação em modo local. A submissão foi analisada por estrutura, detalhe e presença dos elementos essenciais do workflow.",
      "criteria" => [
        { "name" => "Clareza da tarefa", "score" => [ score, 100 ].min, "comment" => "A tarefa deve ser específica e recorrente." },
        { "name" => "Validação e segurança", "score" => [ score - 5, 0 ].max, "comment" => "Inclua sempre como revê outputs e protege dados." },
        { "name" => "Critério de sucesso", "score" => [ score - 3, 0 ].max, "comment" => "O critério deve ser observável, como tempo poupado ou qualidade." }
      ],
      "improvements" => score >= CourseEnrollment::CERTIFICATE_THRESHOLD ? [] : [ "Explique melhor input, validação e critério de sucesso." ],
      "provider" => "mock"
    }
  end
end
