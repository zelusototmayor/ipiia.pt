/* Editorial routing, not supplier evaluation or a safety audit. */
(function(root){'use strict';
const questions=[
{id:'problem',title:'O processo está definido?',options:[['clear','Sei qual é a entrada, o resultado esperado e as exceções.'],['partial','Conheço a tarefa, mas faltam regras ou exemplos.'],['unknown','Quero usar IA, mas ainda não escolhi uma tarefa.']]},
{id:'benefit',title:'Que benefício quer validar?',options:[['measured','Tenho um ponto de partida e consigo comparar tempo, qualidade ou despesa.'],['hypothesis','Tenho uma hipótese e consigo medir num pequeno teste.'],['unknown','Ainda não sei que melhoria justificaria o trabalho.']]},
{id:'recurrence',title:'Com que frequência acontece?',options:[['occasional','É pontual ou pouco frequente.'],['weekly','Repete-se todas as semanas.'],['daily','Acontece todos os dias e precisa de continuidade.']]},
{id:'sensitivity',title:'Que dados seriam necessários?',options:[['public','Dados públicos ou exemplos sintéticos.'],['internal','Informação interna sem dados pessoais ou segredos.'],['sensitive','Dados pessoais, financeiros, confidenciais ou sujeitos a regras específicas.'],['unknown','Ainda não sei que dados seriam usados ou onde seriam tratados.']]},
{id:'integrations',title:'A que sistemas precisa de se ligar?',options:[['none','Nenhum: trabalho manual num ficheiro ou numa ferramenta aprovada.'],['simple','Uma ligação documentada, com acesso limitado e reversível.'],['complex','Vários sistemas ou permissões de escrita.'],['unknown','Ainda não conheço as ligações ou permissões necessárias.']]},
{id:'impact',title:'O que acontece se falhar?',options:[['low','O erro é fácil de detetar e corrigir antes de afetar alguém.'],['medium','Pode atrasar trabalho ou exigir retrabalho.'],['high','Pode enviar algo errado, alterar registos, causar perdas ou afetar direitos e segurança.'],['unknown','Não sei quem seria afetado nem se o erro seria detetado.']]},
{id:'capacity',title:'Quem consegue construir e operar o primeiro teste?',options:[['capable','Existe uma pessoa com tempo e competência para testar, rever e corrigir.'],['learning','Existe uma pessoa disponível, mas precisa de orientação prática.'],['none','Não há capacidade interna disponível neste momento.'],['unknown','Ainda não confirmei a capacidade interna.']]},
{id:'validation',title:'Como vai saber se funciona?',options:[['ready','Tenho exemplos normais e exceções, critérios de aceitação e revisão humana.'],['partial','Consigo comparar resultados, mas faltam critérios ou exceções.'],['none','Não tenho forma fiável de validar o resultado.']]},
{id:'maintenance',title:'Quem fica responsável depois do protótipo?',options:[['owner','Há um responsável interno por acessos, falhas, alterações e revisões.'],['limited','Há alguém, mas com disponibilidade limitada.'],['none','Ainda não existe um responsável pela operação.']]},
{id:'existing',title:'Uma função já disponível resolve a tarefa?',options:[['yes','Sim: há uma função aprovada, ou um método sem IA, que posso testar.'],['no','Já comparei opções disponíveis e falta uma função concreta.'],['unknown','Ainda não comparei com a ferramenta atual ou com resolver sem IA.']]},
{id:'expertise',title:'Se houver risco relevante, quem o consegue avaliar?',options:[['internal','Especialistas internos qualificados podem avaliar os dados, o domínio e as integrações.'],['external','Será necessário identificar apoio especializado externo.'],['unknown','Ainda não confirmei quem tem competência para avaliar estes riscos.']]}
].map(q=>({...q,options:q.options.map(([id,text])=>({id,text}))}));
const routes={
 define:{title:'Defina primeiro o problema e a validação',summary:'Ainda não há base suficiente para escolher uma implementação.',next:'Escreva entrada, saída, exceções, benefício esperado e quem valida. Compare o processo manual com exemplos sintéticos. Não automatize antes de conseguir verificar o resultado.'},
 existing:{title:'Teste primeiro uma função existente ou uma solução sem IA',summary:'Construir um agente pode não ser necessário para esta tarefa.',next:'Compare a função aprovada ou o método manual com o resultado esperado, o tempo e os erros. Se ainda não conhece as opções, faça essa comparação antes de construir. Ferramenta existente não dispensa validação, acessos mínimos nem responsável.'},
 internal:{title:'Experimente internamente, num teste pequeno',summary:'As respostas indicam âmbito limitado, capacidade e validação. Isso não prova segurança.',next:'Comece com exemplos sintéticos e sem escrita automática. Compare com o processo atual, incluindo revisão e retrabalho. Claude Code ou Codex podem apoiar a construção; a equipa continua responsável por permissões, testes e manutenção.'},
 guidance:{title:'Construa com orientação prática',summary:'Há capacidade disponível, mas faltam método, critérios ou limites claros.',next:'Feche as lacunas num exercício acompanhado, dentro ou fora da equipa. Defina critérios de aceitação e um responsável. Não é necessário contratar uma mensalidade para aprender a operar.'},
 oneoff:{title:'Faça uma avaliação especializada antes de avançar',summary:'Os riscos, as incertezas ou a falta de capacidade exigem avaliação qualificada, não uma contratação automática.',next:'Avalie dados, permissões, efeitos de erro, validação e capacidade. Especialistas internos qualificados podem fazer esta avaliação. Só procure apoio externo se faltar competência ou disponibilidade; peça âmbito fechado, documentação e critérios de aceitação. Não comece por comprar uma implementação.'},
 managed:{title:'Defina quem assegura a continuidade',summary:'Falta responsabilidade ou disponibilidade para manter um processo recorrente.',next:'Compare nomear ou formar um responsável interno, reduzir o âmbito ou contratar apoio de operação. Nenhuma destas respostas obriga a operação externa ou mensalidade. Não deixe o processo em produção sem responsável.'}
};
function evaluate(a){
 for(const q of questions)if(!q.options.some(o=>o.id===a[q.id]))throw Error('Resposta em falta ou inválida: '+q.id);
 const reasons=[];let route;const uncertain=['sensitivity','integrations','impact','capacity'].filter(k=>a[k]==='unknown');
 const risk=a.sensitivity==='sensitive'||a.impact==='high'||a.integrations==='complex';
 const continuity=(a.recurrence!=='occasional'&&a.maintenance==='none')||(a.recurrence==='daily'&&(a.capacity==='none'||a.maintenance==='limited'));
 // Availability alone is not a specialist-risk gate for a confirmed low-risk approved alternative.
 const capacityComparison=a.capacity==='unknown'&&a.existing==='yes'&&a.sensitivity==='public'&&a.integrations==='none'&&a.impact==='low'&&!continuity;
 const requiresAssessment=risk||(uncertain.length>0&&!capacityComparison);
 if(a.problem!=='clear'||a.benefit==='unknown'||a.validation==='none'){route='define';reasons.push('Faltam definição, benefício verificável ou critérios para validar.');}
 else if(requiresAssessment){route='oneoff';reasons.push(risk?'Há dados, efeitos de erro ou integrações que exigem avaliação qualificada.':'Há respostas desconhecidas; não as tratámos como sinal de segurança.');}
 else if(continuity){route='managed';reasons.push('É preciso assegurar responsabilidade e continuidade antes de operar.');}
 else if(a.existing!=='no'){route='existing';reasons.push(a.existing==='yes'?'Existe uma alternativa que vale testar antes de construir.':'Ainda não comparou as funções disponíveis ou uma solução sem IA.');}
 else if(a.capacity==='none'){route='oneoff';reasons.push('Não há capacidade disponível para construir e testar agora.');}
 else if(a.capacity==='learning'||a.validation==='partial'||a.maintenance!=='owner'){route='guidance';reasons.push('Orientação pode fechar lacunas de teste, competências ou disponibilidade.');}
 else{route='internal';reasons.push('Há capacidade, responsável e validação num âmbito declarado de menor risco.');}
 if(requiresAssessment)reasons.push(a.expertise==='internal'?'A avaliação pode ser feita por especialistas internos qualificados; este quiz não verificou as suas competências.':'Identifique quem tem competência para avaliar estes riscos. Apoio externo só se essa capacidade não existir internamente.');
 if(capacityComparison&&route==='existing')reasons.push('Confirme a capacidade disponível e o responsável antes de qualquer operação. A disponibilidade por confirmar, por si só, não exige avaliação especializada neste âmbito declarado de menor risco.');
 if(a.sensitivity==='sensitive'||a.sensitivity==='unknown')reasons.push('Não introduza dados reais antes de aprovar ferramenta, permissões e tratamento dos dados.');
 if(a.impact==='high'||a.impact==='unknown')reasons.push('Mantenha aprovação humana e reversão para ações com consequências relevantes ou ainda desconhecidas.');
 if(continuity&&route!=='managed')reasons.push('Além disso, defina um responsável e capacidade para manter o processo.');
 return{route,...routes[route],reasons,risk,uncertain,limitations:'Orientação editorial baseada nas suas respostas. Não é auditoria técnica, certificação de segurança, aconselhamento jurídico ou cálculo de retorno. Não avalia fornecedores nem verifica competências. Não precisa de contratar o IPIIA.'};
}
function shuffled(options,random){const arr=options.slice();for(let i=arr.length-1;i>0;i--){const j=Math.floor(random()*(i+1));[arr[i],arr[j]]=[arr[j],arr[i]];}return arr;}
const api={questions,routes,evaluate,shuffled};if(typeof module!=='undefined')module.exports=api;root.IPIIADiagnostic=api;
})(typeof window!=='undefined'?window:globalThis);
