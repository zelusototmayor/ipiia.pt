(function(){'use strict';if(window.ipiiaDiagnosticLifecycle1114)return;window.ipiiaDiagnosticLifecycle1114=true;
function mount(){const root=document.querySelector('[data-quiz-kind="diagnostic"]');if(!root||root.dataset.quizMounted)return;root.dataset.quizMounted='true';
const D=IPIIADiagnostic,$=id=>document.getElementById(id);if(!$('start'))return;
let index=0,answers={},ordered={},notes={};
const random=()=>{const v=new Uint32Array(1);crypto.getRandomValues(v);return v[0]/4294967296};
const context=()=>({task:$('task-description').value,output:$('desired-output').value,notes:Object.entries(notes).filter(([,v])=>v).map(([id,v])=>D.questions.find(q=>q.id===id).title+' '+v).join('\n')});
function contextReady(){return $('task-description').value.trim().length>0&&$('desired-output').value.trim().length>0;}
function updateStart(){$('start').disabled=!contextReady();}
$('task-description').oninput=updateStart;$('desired-output').oninput=updateStart;
function render(){const q=D.questions[index];$('position').textContent=`Pergunta ${index+1} de ${D.questions.length}`;$('progress').max=D.questions.length;$('progress').value=index;$('question').textContent=q.title;$('question-help').textContent=q.help||'Confirme a opção que descreve a sua situação. Se não sabe, indique-o.';$('choices').replaceChildren();ordered[q.id]??=D.shuffled(q.options,random);
for(const o of ordered[q.id]){const l=document.createElement('label'),r=document.createElement('input'),s=document.createElement('span');r.type='radio';r.name=q.id;r.value=o.id;r.checked=answers[q.id]===o.id;s.textContent=o.text;r.onchange=()=>{answers[q.id]=o.id;$('next').disabled=false;updateClarification(q)};l.append(r,s);$('choices').append(l)}
$('question-note').value=notes[q.id]||'';$('question-note').oninput=()=>{notes[q.id]=$('question-note').value};updateClarification(q);$('back').disabled=false;$('next').disabled=!answers[q.id];$('next').textContent=index===D.questions.length-1?'Ver resultado →':'Seguinte →';$('question').focus();}
function updateClarification(q){$('clarification-help').textContent=answers[q.id]==='unknown'?(D.questions.find(x=>x.id===q.id).help||'Confirme o que falta saber antes de avançar.')+' Pode explicar abaixo, mas o texto não é avaliado. Só mude a opção acima depois de confirmar os factos.':'Pode acrescentar contexto para o seu prompt. Não alteramos a avaliação com base neste texto.';}
function showResult(){const r=D.evaluate(answers);$('quiz').hidden=true;$('result').hidden=false;$('result-title').textContent=r.title;$('summary').textContent=r.summary;$('next-action').textContent=r.next;$('limitations').textContent=r.limitations;$('reasons').replaceChildren(...r.reasons.map(text=>{const li=document.createElement('li');li.textContent=text;return li}));$('followups').replaceChildren();
for(const f of r.followups){const li=document.createElement('li'),btn=document.createElement('button');li.append(document.createTextNode(f.text+' '));btn.className='secondary';btn.textContent='Confirmar esta resposta';btn.onclick=()=>{index=D.questions.findIndex(q=>q.id===f.id);$('result').hidden=true;$('quiz').hidden=false;render()};li.append(btn);$('followups').append(li)}$('followup-section').hidden=r.followups.length===0;
$('answers').replaceChildren();for(const q of D.questions){const dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=q.title;dd.textContent=q.options.find(o=>o.id===answers[q.id]).text+(notes[q.id]?' Contexto não avaliado: '+notes[q.id]:'');$('answers').append(dt,dd)}
$('context-review').textContent='Tarefa: '+context().task+'\nResultado esperado: '+context().output;$('prompt-text').value=D.prompt(context(),answers);$('prompt-heading').textContent=r.route==='internal'?'Texto para começar no ChatGPT ou Claude':'Texto para esclarecer a tarefa, não autorização para a executar';$('copy-status').textContent='';$('result-title').focus();}
$('start').onclick=()=>{if(!contextReady())return;$('quiz').hidden=false;$('intro').hidden=true;render()};
$('back').onclick=()=>{if(index>0){index--;render()}else{$('quiz').hidden=true;$('intro').hidden=false;$('task-description').focus()}};
$('next').onclick=()=>{if(!answers[D.questions[index].id])return;if(index<D.questions.length-1){index++;render()}else showResult()};
$('edit-answers').onclick=()=>{index=0;$('result').hidden=true;$('quiz').hidden=false;render()};
$('edit-context').onclick=()=>{$('result').hidden=true;$('intro').hidden=false;$('task-description').focus()};
$('copy-prompt').onclick=async()=>{try{await navigator.clipboard.writeText($('prompt-text').value);$('copy-status').textContent='Texto copiado. Reveja-o antes de o colar noutra ferramenta.'}catch(e){$('prompt-text').focus();$('prompt-text').select();$('copy-status').textContent='Selecione e copie o texto. Reveja-o antes de o colar noutra ferramenta.'}};
function reset(){index=0;answers={};ordered={};notes={};for(const id of ['task-description','desired-output','question-note','prompt-text'])$(id).value='';for(const id of ['context-review','copy-status','summary','next-action','limitations','result-title'])$(id).textContent='';for(const id of ['answers','reasons','followups','choices'])$(id).replaceChildren();$('result').hidden=true;$('quiz').hidden=true;$('intro').hidden=false;updateStart();}
$('restart').onclick=()=>{reset();$('task-description').focus()};root.quizReset=reset;
for(const r of Object.values(D.routes)){const a=document.createElement('article'),h=document.createElement('h3'),p=document.createElement('p'),n=document.createElement('p');h.textContent=r.title;p.textContent=r.summary;n.textContent=r.next;a.append(h,p,n);$('route-guide').append(a)}updateStart();

}

function clear(){const root=document.querySelector('[data-quiz-kind="diagnostic"]');if(!root)return;if(root.quizReset)root.quizReset();delete root.dataset.quizMounted;const guide=root.querySelector('#route-guide');if(guide)guide.replaceChildren();}
document.addEventListener('DOMContentLoaded',mount);document.addEventListener('turbo:load',mount);document.addEventListener('turbo:before-cache',clear);document.addEventListener('turbo:before-render',clear);window.addEventListener('pagehide',clear);if(document.readyState!=='loading')mount();
})();
