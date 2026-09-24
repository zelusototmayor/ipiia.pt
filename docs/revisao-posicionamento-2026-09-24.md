# Revisão local do posicionamento

Estado: publicação do site autorizada em 24 de setembro. Os agentes de voz alojados permanecem inalterados.

## Decisões

- Hero com uma frase: “Automatizamos tarefas que ainda faz à mão.”
- Hero centrada, sem fotografia. Fotografia no contacto final, à direita do texto alinhado à esquerda, com disposição vertical em telemóveis.
- Exemplos de faturas, atendimento por voz e gestão com o mesmo destaque.
- Removido o funil obrigatório de automações para Agente de Gestão.
- Formação em página própria, sem quebrar URLs dos cursos ou do teste.
- Mantidos cores, fotografia, clientes, animação e destaques tipográficos.
- Skill Humanizer procurada, mas não encontrada entre as skills instaladas. Revisão editorial manual, sem alegar aplicação da skill.

## Faturas

O utilizador descreveu receção por email, extração e inserção no ERP. A localização do projeto e o ERP concreto foram pedidos. Enquanto não forem confirmados, a página apresenta um exemplo de aplicação, não um caso com resultados medidos. Duplicados, campos em falta e ligações são requisitos a confirmar, não funcionalidades verificadas.

## Voz

Inspecionados README, prompt, backend e configuração da demo local em `../..` fora deste repositório: `/Users/zelu/Documents/Chefe de staff - restaurantes/brevauto-demo`.

A demo existente tem login e um painel partilhado de pedidos. Não foi transformada num serviço anónimo nem foram expostos dados. A página do site permite pedir acesso. Apenas em desenvolvimento mostra uma ligação à pré-visualização local em `http://127.0.0.1:8001/`.

Alterados localmente o título, marca, saudação, vocabulário de reconhecimento e instruções Vapi/Retell para Reboques IPIIA. A empresa passou a ser explicitamente fictícia. Mantidos os identificadores internos, cookies, rotas e cabeçalhos de integração para não quebrar o serviço existente.

`PREVIEW_ONLY=1` bloqueia criação de chamadas, oculta o telefone e deixa ready=false. O servidor local usa dados temporários separados e não tem chaves de serviços de voz no ambiente. Nenhuma configuração foi enviada aos fornecedores. As chamadas em produção continuam na versão anterior até autorização específica de publicação.

Antes de disponibilizar uma demo anónima, separar sessões e pedidos, definir limites de utilização e rever as permissões das chaves. Não ligar o público ao painel de administração atual.

Backup dos ficheiros de apresentação/instruções anteriores à mudança de nome: `/tmp/ipiia-voice-before-hIBIz4`. O site publicado está guardado no commit `0a94ba7`.
