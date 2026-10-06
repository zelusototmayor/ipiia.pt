import { createAnalytics } from 'analytics/provider';
import { ROUTES, BINDINGS, EXTERNAL_HOSTS, EDITORIAL_CTAS, bindingId } from 'analytics/dictionary';
import { FORMS } from 'analytics/contract';
import { createSdkCollector, validConfig } from 'analytics/sdk';
import { mountConsent } from 'analytics/consent';

// Server-rendered env candidate, absent/disabled by default. No query override.
let analytics = createAnalytics();
export const track = (event, props) => analytics.track(event, props);
export const begin = (flow) => analytics.begin(flow);
export const confirm = (flow, proof) => analytics.confirm(flow, proof);
export const setConsent = (value) => analytics.setConsent(value);
export const hasConsent = () => analytics.hasConsent();
export function installLocalCollector(collector, options = {}) {
  if (!['127.0.0.1', 'localhost'].includes(window.location.hostname)) throw new Error('Synthetic loopback only');
  analytics.setConsent(false);
  analytics = createAnalytics({ ...options, collector });
  return analytics;
}
export function clickBinding(anchor) {
  const area = anchor.closest('#nav') ? 'nav' : anchor.closest('footer') ? 'footer' : 'page';
  const raw = anchor.getAttribute('href') || '';
  let id;
  if (raw.startsWith('mailto:')) id = `${area}_email`;
  else if (raw.startsWith('tel:')) id = `${area}_phone`;
  else if (raw.startsWith('#')) id = `${area}_section`;
  else {
    try {
      const url = new URL(raw, window.location.href);
      const editorialId = anchor.getAttribute('data-analytics-cta');
      const editorial = Object.hasOwn(EDITORIAL_CTAS, editorialId) ? EDITORIAL_CTAS[editorialId] : null;
      if (editorial && window.location.pathname.replace(/\.html$/, '') === editorial.page &&
          url.origin === window.location.origin && url.pathname === '/book-call.html' &&
          url.searchParams.size === 1 && url.searchParams.get('tema') === editorial.tema && !url.hash) {
        return BINDINGS[editorialId];
      }
      if (url.origin === window.location.origin && Object.hasOwn(ROUTES, url.pathname)) id = bindingId(area, url.pathname);
      else if (url.protocol === 'https:' && EXTERNAL_HOSTS.includes(url.hostname)) id = `${area}_external`;
    } catch { return null; }
  }
  return BINDINGS[id] || null;
}
const seenMarkers = new WeakSet();
function loaded() {
  const panel = document.querySelector('[data-analytics-consent]');
  if (panel && !panel.dataset.mounted) {
    let config;
    try { config = JSON.parse(panel.dataset.config); } catch { config = null; }
    if (validConfig(config)) {
      if (!analytics.hasConsent()) analytics = createAnalytics({ collector: createSdkCollector(config) });
      mountConsent(panel, analytics);
    }
  }
  analytics.pageView();
  const marker = document.querySelector('meta[name="ipiia-booking-confirmed"]');
  if (marker && !seenMarkers.has(marker)) {
    seenMarkers.add(marker);
    analytics.confirm('booking', { serverMarker: true });
    marker.remove(); // Turbo snapshots/reloads cannot replay consumed completion
  }
}
if (typeof document !== 'undefined') {
  document.addEventListener('click', (event) => {
    const anchor = event.target.closest('a');
    if (anchor) {
      const binding = clickBinding(anchor);
      if (binding) {
        analytics.track('cta_clicked', binding);
        const specialized = { email: 'email_clicked', phone: 'phone_clicked', external: 'outbound_clicked' }[binding.destination_type];
        if (specialized) analytics.track(specialized, binding);
      }
    }
    const checkout = event.target.closest('form[action="/checkout"] button');
    if (checkout) analytics.track('cta_clicked', BINDINGS.page_checkout);
  });
  document.addEventListener('focusin', (event) => {
    for (const [flow, selector] of Object.entries(FORMS)) {
      if (flow !== 'diagnostic' && flow !== 'booking' && event.target.closest(selector)) analytics.begin(flow);
    }
  });
  document.addEventListener('submit', (event) => {
    if (event.target.id !== 'booking-form') return;
    if (!analytics.hasConsent()) {
      event.target.querySelector('input[name="analytics_consented"]')?.remove();
      return;
    }
    // Only a valid actual submission with current analytics opt-in may request
    // a server one-shot saved-booking marker. No form contents inspected.
    let input = event.target.querySelector('input[name="analytics_consented"]');
    if (!input) {
      input = document.createElement('input');
      input.type = 'hidden'; input.name = 'analytics_consented'; event.target.append(input);
    }
    input.value = 'true';
  });
  document.addEventListener('turbo:load', loaded);
  window.addEventListener('pageshow', loaded);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', loaded);
  else loaded();
}
