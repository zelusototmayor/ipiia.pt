// Resolve exactly the Rails Importmap site-local names for Node's native tests.
export async function resolve(specifier, context, nextResolve) {
  if (specifier === 'analytics') {
    return { url: new URL('../../app/javascript/analytics/index.js', import.meta.url).href, shortCircuit: true };
  }
  if (/^analytics\/(contract|dictionary|provider|sdk|consent)$/.test(specifier)) {
    return { url: new URL(`../../app/javascript/${specifier}.js`, import.meta.url).href, shortCircuit: true };
  }
  return nextResolve(specifier, context);
}
