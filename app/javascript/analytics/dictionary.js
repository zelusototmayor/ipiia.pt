// Static metadata from PagesController/FundingSupportPages on approved source972e6af.
const pages = {
  home: 'IPIIA · Instituto Português de Implementação de IA', index: 'IPIIA · Instituto Português de Implementação de IA',
  missao: 'Missão · IPIIA', metodo: 'Método · IPIIA', servicos: 'Soluções de IA e automação · IPIIA',
  'agente-de-gestao-ia': 'Agente de Gestão com IA · IPIIA', 'fundos-europeus-ia-pmes': 'Fundos Europeus para IA em PMEs | IPIIA',
  casos: 'Exemplos e demos · IPIIA', formacao: 'Formação em IA · IPIIA', 'automacao-faturas': 'Faturas do email ao ERP · IPIIA',
  'reboques-ipiia': 'Demonstração de voz Reboques IPIIA', teste: 'Teste IA gratuito · IPIIA', sobre: 'Sobre · IPIIA',
  contacto: 'Contacto · IPIIA', 'book-call': 'Intro call · IPIIA', 'curso-fundamentos': 'Fundamentos de IA para o Trabalho · IPIIA',
  'curso-proficiencia': 'Proficiência em Implementação de IA · IPIIA', privacidade: 'Política de Privacidade · IPIIA',
  termos: 'Termos e Condições · IPIIA', cookies: 'Política de Cookies · IPIIA'
};
const funding = {
  'sice-qualificacao-pme': 'SICE Qualificação das PME para Projetos de IA | IPIIA',
  'linha-ia-nas-pme-prr': 'Linha IA nas PME PRR / IFIC | Guia de Candidatura | IPIIA',
  'sice-inovacao-produtiva': 'SICE Inovação Produtiva para Projetos com IA | IPIIA',
  'incentivos-base-territorial': 'Incentivos de Base Territorial para Modernização com IA | IPIIA',
  'siqrh-formacao-empresarial': 'SIQRH Formação Empresarial para IA nas Empresas | IPIIA'
};
const routes = { '/': pages.home };
for (const [key, title] of Object.entries(pages)) {
  routes[`/${key}`] = title;
  routes[`/${key}.html`] = title;
}
for (const [key, title] of Object.entries(funding)) routes[`/fundos-europeus-ia-pmes/${key}`] = title;
export const ROUTES = Object.freeze(routes);
const bindings = {};
export function bindingId(area, path) {
  return `${area}_${path.replace(/\.html$/, '').replace(/^\//, '').replace(/[/-]/g, '_') || 'home'}`;
}
for (const area of ['nav', 'footer', 'page']) {
  for (const [path, title] of Object.entries(ROUTES)) {
    const destination = /^\/book-call(?:\.html)?$/.test(path) ? 'booking' : /^\/teste(?:\.html)?$/.test(path) ? 'diagnostic' : /^\/contacto(?:\.html)?$/.test(path) ? 'contact' : 'internal';
    const id = bindingId(area, path);
    bindings[id] = Object.freeze({ cta_id: id, cta_label: title, destination_type: destination });
  }
  for (const [key, label, destination] of [
    ['email', 'Enviar email', 'email'], ['phone', 'Telefonar', 'phone'],
    ['external', 'Consultar fonte externa', 'external'], ['checkout', 'Comprar curso', 'checkout'], ['section', 'Ver secção', 'internal']
  ]) {
    const id = `${area}_${key}`;
    bindings[id] = Object.freeze({ cta_id: id, cta_label: label, destination_type: destination });
  }
}
export const BINDINGS = Object.freeze(bindings);
export const EXTERNAL_HOSTS = Object.freeze(['zelusottomayor.com', 'portugal2030.pt', 'www.compete2030.gov.pt', 'www3.compete2030.gov.pt', 'balcaofundosue.pt', 'recuperarportugal.gov.pt', 'portal.recuperarportugal.gov.pt', 'benef.recuperarportugal.gov.pt', 'algarve.portugal2030.pt']);
