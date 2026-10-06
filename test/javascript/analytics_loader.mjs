// Resolve exactly the Rails Importmap site-local names for Node's native tests.
export async function resolve(specifier, context, nextResolve) {
  if (/^analytics\/(contract|dictionary|provider|index)$/.test(specifier)) {
    return { url: new URL(`../../app/javascript/${specifier}.js`, import.meta.url).href, shortCircuit: true };
  }
  return nextResolve(specifier, context);
}
