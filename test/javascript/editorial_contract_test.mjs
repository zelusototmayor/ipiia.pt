import test from 'node:test';
import assert from 'node:assert/strict';
import { ROUTES, BINDINGS, EDITORIAL_CTAS } from 'analytics/dictionary';
import { PROPERTIES } from 'analytics/contract';
import { createAnalytics } from 'analytics/provider';
import { clickBinding } from 'analytics';

const pairs = Object.entries(EDITORIAL_CTAS);
function anchor(href, id, label = 'editorial-canary@example.invalid') {
  return { closest: () => null, textContent: label, getAttribute: (key) => key === 'href' ? href : key === 'data-analytics-cta' ? id : null };
}
for (const [id, spec] of pairs) {
  test(`${id} has static routes and controlled exact CTA binding`, () => {
    globalThis.window = { location: new URL(`https://ipiia.pt${spec.page}.html?email=editorial-canary@example.invalid#private`) };
    assert.equal(ROUTES[spec.page], ROUTES[`${spec.page}.html`]);
    assert.equal(clickBinding(anchor(`/book-call.html?tema=${spec.tema}`, id)), BINDINGS[id]);
    window.location = new URL(`https://ipiia.pt${spec.page}`);
    assert.equal(clickBinding(anchor(`/book-call.html?tema=${spec.tema}`, id)), BINDINGS[id]);
    assert.notEqual(clickBinding(anchor(`https://evil.invalid/book-call.html?tema=${spec.tema}`, id)), BINDINGS[id]);
    assert.notEqual(clickBinding(anchor(`/book-call.html?tema=${spec.tema}&email=canary`, id)), BINDINGS[id]);
    assert.notEqual(clickBinding(anchor(`/book-call.html?tema=${spec.tema}#private`, id)), BINDINGS[id]);
    window.location = new URL('https://ipiia.pt/contacto.html');
    assert.notEqual(clickBinding(anchor(`/book-call.html?tema=${spec.tema}`, id)), BINDINGS[id]);
  });
  test(`${id} remains consent gated and emits no click-as-completion or caller text`, () => {
    const events = [];
    const store = new Map();
    const analytics = createAnalytics({ collector: { start: () => true, stop() {}, send: (event, properties) => { events.push({ event, properties }); return true; } }, storage: () => ({ getItem: (k) => store.get(k) || null, setItem: (k, v) => store.set(k, v), removeItem: (k) => store.delete(k) }), context: () => ({ url: `https://ipiia.pt${spec.page}.html?email=editorial-canary@example.invalid&gclid=CANARY#private`, referrer: '', width: 390 }) });
    assert.equal(analytics.track('cta_clicked', { cta_id: id }), false);
    assert.deepEqual(events, []);
    assert.equal(store.size, 0);
    analytics.setConsent(true);
    analytics.track('cta_clicked', { cta_id: id, cta_label: 'editorial-canary@example.invalid' });
    assert.deepEqual(events.map((e) => e.event), ['page_view', 'cta_clicked']);
    const props = events[1].properties;
    assert.equal(props.cta_id, id);
    assert.equal(props.cta_label, BINDINGS[id].cta_label);
    assert.equal(props.page_path, `${spec.page}.html`);
    assert.equal(props.page_title, ROUTES[`${spec.page}.html`]);
    assert.ok(Object.keys(props).every((k) => PROPERTIES.includes(k)));
    assert.equal(JSON.stringify(events).includes('canary'), false);
    assert.equal(analytics.track('booking_completed'), false);
    assert.equal(analytics.track('resource_downloaded'), false);
    analytics.setConsent(false);
    analytics.track('cta_clicked', { cta_id: id });
    assert.equal(events.length, 2);
  });
}
