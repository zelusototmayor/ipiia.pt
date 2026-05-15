require "test_helper"

class WorkflowEvaluatorTest < ActiveSupport::TestCase
  test "mock evaluation returns structured rubric without api key" do
    previous_key = ENV.delete("OPENAI_API_KEY")

    result = WorkflowEvaluator.evaluate(
      "Tarefa recorrente: preparar follow-ups comerciais. Frequência: semanal. Input: notas de reunião. Passos: resumir, escrever e validar. Output: email. Validação: rever dados e promessas. Critério de sucesso: poupar 20 minutos."
    )

    assert_equal "mock", result["provider"]
    assert result["score"].between?(0, 100)
    assert result["criteria"].any?
  ensure
    ENV["OPENAI_API_KEY"] = previous_key if previous_key
  end
end
