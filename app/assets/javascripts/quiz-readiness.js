(function(root){'use strict';
function score(model,answers){
 const totals={},max={},signals={},use={},feedback=[];
 for(const q of model.questions){
  const selected=q.options.find(o=>o.id===answers[q.id]);
  if(!selected)throw Error('Resposta em falta ou inválida: '+q.id);
  if(q.measure==='self_report'){use[q.id]=selected.text;continue;}
  const k=q.dimension;
  max[k]=(max[k]||0)+Math.max(...q.options.map(o=>o.scores[k]||0));
  totals[k]=(totals[k]||0)+(selected.scores[k]||0);
  for(const s of selected.signals)signals[s]=(signals[s]||0)+1;
  if(selected.signals.length)feedback.push({question:q.id,answer:selected.text,focus:q.feedback||'Valide o resultado com exemplos e critérios independentes.'});
 }
 const dimensions={};for(const k of Object.keys(model.dimensions))dimensions[k]=Math.max(0,Math.min(100,Math.round(100*(totals[k]||0)/(max[k]||1))));
 const overall=Math.round(Object.values(dimensions).reduce((a,b)=>a+b,0)/Object.keys(dimensions).length);
 const critical=(signals.privacy_risk||0)>0||(signals.premature_automation||0)>0||(signals.safety_unknown||0)>0;
 const profile=critical?'review_controls':overall>=78?'strong_scenario_choices':overall>=55?'consolidating':'foundations';
 return {dimensions,overall,profile,signals,critical,selfReportedUse:use,feedback,limitations:'Índice editorial dos cenários, sem validação psicométrica. Hábitos declarados não pontuam. Não demonstra competência, segurança, conformidade ou prontidão de implementação.'};
}
const api={score};if(typeof module!=='undefined')module.exports=api;root.IPIIAReadiness=api;
})(typeof window!=='undefined'?window:globalThis);
