import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createAnalytics, syntheticSdkAdapter, MIXPANEL_CONFIG } from 'analytics/provider';
import { EVENTS, PROPERTIES, STORAGE_KEY, TTL, slug, pathname, externalHost, touchFrom } from 'analytics/contract';
import { ROUTES, BINDINGS, EXTERNAL_HOSTS } from 'analytics/dictionary';
import { track as boundTrack } from 'analytics';

test('application uses the Rails directory-index importmap alias', () => {
  const application = readFileSync(new URL('../../app/javascript/application.js', import.meta.url), 'utf8');
  assert.match(application, /from 'analytics';/);
  assert.ok(!application.includes("from 'analytics/index'"));
  assert.equal(typeof boundTrack, 'function');
});

function fixture(production = false) {
  const entries = new Map(); const events = []; const calls = [];
  let time = 1000000000000;
  const ctx = { url: 'https://ipiia.pt/', referrer: '', width: 1280 };
  const store = { getItem: (key) => { calls.push('read'); return entries.get(key) || null; }, setItem: (key, value) => { calls.push('write'); entries.set(key, value); }, removeItem: (key) => { calls.push('remove'); entries.delete(key); } };
  const collector = { start: () => { calls.push('start'); }, send: (event, props) => { events.push({ event, props }); }, stop: () => calls.push('stop') };
  const api = createAnalytics({ collector, storage: () => store, context: () => ctx, now: () => time, production });
  return { api, entries, events, calls, ctx, advance: (delta) => { time += delta; }, store, collector };
}
test('exact v1 event/property dictionary', () => {
  assert.equal(EVENTS.length, 12); assert.equal(new Set(EVENTS).size, 12);
  assert.equal(PROPERTIES.length, 15); assert.equal(new Set(PROPERTIES).size, 15);
});
test('no init/send/read/write before consent or on denial', () => {
  const f = fixture(); f.api.track('page_view'); f.api.begin('contact'); f.api.confirm('booking', { serverMarker: true }); f.api.pageView(); f.api.setConsent(false);
  assert.deepEqual(f.calls, []); assert.deepEqual(f.events, []); assert.equal(f.entries.size, 0);
});
test('disabled default cannot be activated by consent', () => {
  const api = createAnalytics({ storage: () => { throw new Error('access'); } });
  assert.equal(api.setConsent(true), false); assert.equal(api.track('page_view'), false);
});
test('unknown names throw in tests and drop whole event in production', () => {
  const f = fixture(); assert.throws(() => f.api.track('purchase'), TypeError); assert.throws(() => f.api.track('cta_clicked', { email: 'canary@example.test' }), TypeError);
  const p = fixture(true); p.api.setConsent(true); const count = p.events.length;
  assert.equal(p.api.track('purchase'), false); assert.equal(p.api.track('cta_clicked', { arbitrary: 'secret' }), false); assert.equal(p.events.length, count);
});
test('path query/hash stripped, unknown/tokenized routes never sent', () => {
  const f = fixture(); f.ctx.url = 'https://ipiia.pt/contacto.html?email=canary@example.test#secret'; f.api.setConsent(true);
  assert.equal(f.events[0].props.page_path, '/contacto.html'); assert.equal(f.events[0].props.page_title, ROUTES['/contacto.html']);
  assert.equal(pathname('/contacto.html?a=1#x'), '/contacto.html');
  f.ctx.url = 'https://ipiia.pt/bookings/PRIVATE_TOKEN'; assert.equal(f.api.pageView(), false);
  f.api.track('cta_clicked', { cta_id: 'page_email' }); assert.equal('page_path' in f.events.at(-1).props, false);
});
test('UTMs strict normalization, no arbitrary query, duplicate/PII rejected', () => {
  assert.equal(slug(' Newsletter '), 'newsletter');
  for (const value of ['canary@example.test', '+351912345678', '351912345678', 'João Silva', 'Free text!', 'https://evil.test', 'a'.repeat(101)]) assert.equal(slug(value), null);
  assert.deepEqual(touchFrom('/?utm_source=NEWSLETTER&utm_campaign=summer-26&name=Alice&email=canary%40example.test&utm_term=Jane%20Doe', ''), { utm_source: 'newsletter', utm_campaign: 'summer-26' });
  assert.deepEqual(touchFrom('/?utm_source=a&utm_source=b', ''), {});
});
test('referrer is hostname only excluding own/subdomains/IP/credentials', () => {
  assert.equal(externalHost('https://search.example.test/private?email=canary#secret'), 'search.example.test');
  for (const value of ['https://ipiia.pt/x', 'https://www.ipiia.pt/x', 'https://user:secret@evil.test/x', 'https://127.0.0.1/x', 'bad']) assert.equal(externalHost(value), null);
});
test('first immutable, last refresh valid touch only; SPA stale referrer not reused', () => {
  const f = fixture(); f.ctx.url += '?utm_source=first'; f.ctx.referrer = 'https://search.example.test?q=secret'; f.api.setConsent(true);
  const first = JSON.parse(f.entries.get(STORAGE_KEY)).first;
  f.advance(1000); f.ctx.url = 'https://ipiia.pt/contacto.html?utm_source=second'; f.api.pageView();
  const second = JSON.parse(f.entries.get(STORAGE_KEY)); assert.deepEqual(second.first, first); assert.equal(second.last.props.utm_source, 'second');
  f.advance(1000); f.ctx.url = 'https://ipiia.pt/teste.html'; f.api.pageView();
  assert.deepEqual(JSON.parse(f.entries.get(STORAGE_KEY)).last, second.last);
});
test('expiry exactly 30days purges first/last and invalid stored properties', () => {
  const f = fixture(); f.ctx.url += '?utm_source=first'; f.api.setConsent(true); f.advance(TTL); f.ctx.url = 'https://ipiia.pt/contacto.html'; f.api.pageView();
  assert.equal(f.entries.has(STORAGE_KEY), false); assert.equal('utm_source' in f.events.at(-1).props, false);
  f.api.setConsent(false); f.entries.set(STORAGE_KEY, JSON.stringify({ version: 1, first: { at: 1, props: { email: 'secret' } }, last: { at: 1, props: { name: 'secret' } } }));
  f.api.setConsent(true); assert.equal(f.entries.has(STORAGE_KEY), false);
});
test('revocation closes boundary immediately, purge then fresh opt-in no replay', () => {
  const f = fixture(); f.ctx.url += '?utm_source=first'; f.api.setConsent(true); f.api.begin('contact');
  f.api.setConsent(false); assert.equal(f.entries.has(STORAGE_KEY), false); assert.ok(f.calls.includes('stop'));
  const count = f.events.length; f.api.track('cta_clicked'); f.api.confirm('contact', { status: 201, ok: true }); assert.equal(f.events.length, count);
  f.api.setConsent(true); assert.equal(f.events.length, count + 1); assert.equal(f.api.confirm('contact', { status: 201, ok: true }), false);
});
test('initial route once, same path/query/hash no duplicate, real A-B-A navigation', () => {
  const f = fixture(); f.api.setConsent(true); f.api.pageView(); f.ctx.url += '?email=secret#x'; f.api.pageView();
  assert.equal(f.events.length, 1); f.ctx.url = 'https://ipiia.pt/teste.html'; f.api.pageView(); f.ctx.url = 'https://ipiia.pt/'; f.api.pageView(); assert.equal(f.events.length, 3);
});
for (const flow of ['contact', 'course_waitlist', 'diagnostic']) test(`${flow} actual start/confirmed success once, failed/missing status not completion`, () => {
  const f = fixture(); f.api.setConsent(true);
  assert.equal(f.api.confirm(flow, { status: 201, ok: true }), false);
  f.api.begin(flow); f.api.begin(flow);
  for (const proof of [{ status: 422, ok: false }, { status: 500, ok: true }, { status: 200, ok: false }, { ok: true }, { status: 302, ok: true }]) assert.equal(f.api.confirm(flow, proof), false);
  assert.equal(f.api.confirm(flow, { status: 201, ok: true }), true); assert.equal(f.api.confirm(flow, { status: 201, ok: true }), false);
  assert.deepEqual(f.events.slice(1).map((e) => e.event), flow === 'diagnostic' ? ['diagnostic_started', 'diagnostic_completed'] : ['contact_started', 'contact_submitted']);
  assert.equal(f.events.at(-1).props.form_id, flow);
});
test('booking click/redirect/bare URL cannot complete; saved server marker once', () => {
  const f = fixture(); f.ctx.url = 'https://ipiia.pt/book-call.html'; f.api.setConsent(true); f.api.track('cta_clicked', BINDINGS.page_book_call);
  assert.equal(f.api.confirm('booking', { status: 302, ok: true }), false); assert.equal(f.api.track('booking_completed'), false);
  f.api.begin('booking'); f.ctx.url = 'https://ipiia.pt/bookings/PRIVATE_TOKEN';
  assert.equal(f.api.pageView(), false); assert.equal(f.api.confirm('booking', { serverMarker: true }), true); assert.equal(f.api.confirm('booking', { serverMarker: true }), false);
  assert.equal(f.events.at(-1).props.page_path, '/book-call.html'); assert.ok(!JSON.stringify(f.events).includes('PRIVATE_TOKEN'));
});
test('external PDF never counted as completed resource', () => {
  const f = fixture(); f.api.setConsent(true); assert.equal(f.api.track('resource_downloaded', { asset_id: 'invented' }), false);
  f.api.track('outbound_clicked', BINDINGS.page_external); assert.equal(f.events.at(-1).event, 'outbound_clicked');
});
test('every controlled CTA binding emits only allowed keys and exact IDs/labels', () => {
  const f = fixture(); f.api.setConsent(true);
  for (const binding of Object.values(BINDINGS)) { f.api.track('cta_clicked', binding); assert.equal(f.events.at(-1).props.cta_id, binding.cta_id); assert.equal(f.events.at(-1).props.cta_label, binding.cta_label); }
  for (const event of ['email_clicked', 'phone_clicked', 'outbound_clicked']) f.api.track(event, BINDINGS[`page_${event === 'email_clicked' ? 'email' : event === 'phone_clicked' ? 'phone' : 'external'}`]);
  for (const { props } of f.events) assert.ok(Object.keys(props).every((key) => PROPERTIES.includes(key)));
});
test('PII canaries in all caller props, URL, title, forms cannot cross boundary', () => {
  const f = fixture(); f.ctx.url = 'https://ipiia.pt/?email=canary%40example.test&name=Jane%20Doe&phone=351912345678&utm_campaign=Free%20text'; f.api.setConsent(true);
  f.api.track('email_clicked', { cta_id: 'page_email', cta_label: 'Jane Doe', page_title: 'canary@example.test', site: 'evil', page_path: '/?secret=351912345678', utm_term: 'Free text', referrer_domain: 'canary', device_type: 'name' });
  const text = JSON.stringify([...f.events, ...f.entries.values()]); for (const canary of ['canary@example.test', 'Jane Doe', '351912345678', 'Free text', 'secret=']) assert.ok(!text.includes(canary));
  f.api.track('cta_clicked', { cta_id: '__proto__', form_id: '__proto__' }); assert.equal('cta_label' in f.events.at(-1).props, false);
});
test('storage denied and collector failures remain no-throw, no queue', () => {
  const f = fixture(); const api = createAnalytics({ collector: f.collector, context: () => f.ctx, storage: () => { throw new Error('denied'); } });
  assert.equal(api.setConsent(true), true); assert.equal(api.track('cta_clicked'), true); assert.equal(api.setConsent(false), false);
  const bad = createAnalytics({ collector: { start: () => { throw new Error('init'); } } }); assert.equal(bad.setConsent(true), false);
});
test('SDK adapter lazy factory, EU/privacy flags, no automatic opt-in event, revoke reset', () => {
  const calls = []; const sdk = { init: (_, config) => calls.push(['init', config]), opt_in_tracking: (opts) => calls.push(['in', opts]), track: (...args) => calls.push(['track', ...args]), opt_out_tracking: (opts) => calls.push(['out', opts]), reset: () => calls.push(['reset']) };
  const f = fixture(); const api = createAnalytics({ collector: syntheticSdkAdapter(() => { calls.push(['factory']); return sdk; }, 'SYNTHETIC_NOT_A_TOKEN'), context: () => f.ctx, storage: () => f.store });
  assert.deepEqual(calls, []); api.setConsent(true); assert.equal(calls[0][0], 'factory'); assert.equal(calls[1][1].api_host, 'https://api-eu.mixpanel.com'); assert.deepEqual(calls[2], ['in', { track: false }]);
  assert.equal(MIXPANEL_CONFIG.autocapture, false); assert.equal(MIXPANEL_CONFIG.ip, false); assert.equal(MIXPANEL_CONFIG.record_sessions_percent, 0);
  api.setConsent(false); assert.deepEqual(calls.slice(-3).map((c) => c[0]), ['out', 'reset', 'out']);
});
test('static route metadata and outbound host dictionary match all approved source', () => {
  const pages = readFileSync(new URL('../../app/controllers/pages_controller.rb', import.meta.url), 'utf8');
  for (const match of pages.matchAll(/"([a-z0-9-]+)" => \{\s*template: "[^"]+",\s*title: "([^"]+)"/g)) assert.equal(ROUTES[`/${match[1]}.html`], match[2]);
  const funding = readFileSync(new URL('../../app/services/funding_support_pages.rb', import.meta.url), 'utf8');
  for (const match of funding.matchAll(/"([a-z0-9-]+)" => \{\s*label: "[^"]+",\s*title: "([^"]+)"/g)) assert.equal(ROUTES[`/fundos-europeus-ia-pmes/${match[1]}`], match[2]);
  for (const match of funding.matchAll(/https:\/\/([a-zA-Z0-9.-]+)\//g)) assert.ok(EXTERNAL_HOSTS.includes(match[1]), match[1]);
});
