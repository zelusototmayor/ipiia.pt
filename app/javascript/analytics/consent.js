// Memory-only explicit choice. Never infer acceptance from browsing/dismissal.
export function mountConsent(panel, analytics) {
  panel.dataset.mounted = 'true';
  let generation = 0;
  const status = panel.querySelector('[data-consent-status]');
  const accept = panel.querySelector('[data-consent-choice="accept"]');
  const reject = panel.querySelector('[data-consent-choice="reject"]');
  const revoke = panel.querySelector('[data-consent-choice="revoke"]');
  function update() {
    const enabled = analytics.hasConsent();
    accept.hidden = enabled; reject.hidden = enabled; revoke.hidden = !enabled;
    status.textContent = enabled ? 'Analytics autorizado nesta página. Pode revogar a qualquer momento.' : 'Analytics não autorizado.';
  }
  panel.addEventListener('click', async event => {
    const choice = event.target.closest('[data-consent-choice]')?.dataset.consentChoice;
    if (!choice) return;
    const attempt = ++generation;
    if (choice !== 'accept') {
      analytics.setConsent(false);
      update(); accept.focus();
      return;
    }
    accept.disabled = true;
    status.textContent = 'A ativar analytics…';
    await analytics.setConsent(true);
    accept.disabled = false;
    if (attempt !== generation) return;
    update();
    if (analytics.hasConsent()) revoke.focus();
  });
  update();
}
