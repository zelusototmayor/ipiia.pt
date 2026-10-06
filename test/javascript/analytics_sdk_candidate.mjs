const { chromium } = await import(process.env.IPIIA_PLAYWRIGHT_MODULE || 'playwright');
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { createHash } from 'node:crypto';
import assert from 'node:assert/strict';
const root = new URL('../../', import.meta.url).pathname;
const origin = 'http://127.0.0.1:43489';
const sdk = readFileSync(`${root}app/assets/javascripts/mixpanel-2.84.0.min.js`);
assert.equal(createHash('sha256').update(sdk).digest('hex'), '1a10e96045c70c048725f81778fa82fbb731513a4876f0e0daa96a57a9bed279');
const panel = readFileSync(`${root}tmp/sdk-evidence/cmp.html`, 'utf8');
const css = readFileSync(`${root}app/assets/stylesheets/analytics-consent.css`, 'utf8');
const imports = Object.fromEntries(['contract', 'dictionary', 'provider', 'sdk', 'consent'].map(x => [`analytics/${x}`, `/modules/${x}.js`]));
const html = `<!doctype html><html lang="pt"><head><meta name="viewport" content="width=device-width"><style>${css}</style><script type="importmap">${JSON.stringify({ imports })}</script></head><body>${panel}<script type="module">import * as api from '/modules/index.js'; window.api=api;</script></body></html>`;
const receipt = { scope: 'LOCAL CANDIDATE ONLY: actual Rails-rendered CMP/env, official pinned SDK, all network intercepted. NOT privacy/release/provider approval.', sdk_sha256: createHash('sha256').update(sdk).digest('hex'), scenarios: [] };
const business = ['site','page_path','page_title','cta_id','cta_label','destination_type','form_id','asset_id','referrer_domain','utm_source','utm_medium','utm_campaign','utm_content','utm_term','device_type'];
const technical = ['token','distinct_id','$device_id','$insert_id','time','mp_lib','$lib_version'];
const dummy = 'SDK_CANDIDATE_DUMMY_NO_PROJECT';
const identity = 'org_analytics_identity_v1';
let browser;
function decode(req) {
  const raw = req.postData() || '';
  const data = new URLSearchParams(raw).get('data');
  for (const value of [raw, data, data && Buffer.from(data, 'base64').toString('utf8')]) { try { return JSON.parse(value); } catch {} }
  throw new Error(`Unparsed payload ${raw}`);
}
try {
  browser = await chromium.launch({ channel: 'chrome', headless: true, args: ['--disable-background-networking','--disable-component-update','--no-first-run'] });
  async function scenario(name, operation, options = {}) {
    const context = await browser.newContext({ serviceWorkers: 'block', viewport: { width: options.mobile ? 375 : 1280, height: 900 } });
    await context.addInitScript(() => {
      window.storageAccesses = [];
      for (const name of ['getItem', 'setItem', 'removeItem']) {
        const original = Storage.prototype[name];
        Storage.prototype[name] = function (...args) { window.storageAccesses.push({ method: name, key: args[0] }); return original.apply(this, args); };
      }
    });
    const record = { name, requests: [], envelopes: [], snapshots: [], errors: [] };
    receipt.scenarios.push(record);
    let release;
    const gate = new Promise(resolve => { release = resolve; });
    await context.route('**/*', async route => {
      const req = route.request(), url = new URL(req.url());
      if (url.origin === origin) {
        if (url.pathname.startsWith('/assets/mixpanel-2.84.0')) {
          record.requests.push({ type: 'lazy-sdk', url: req.url() });
          if (options.delay) await gate;
          if (options.assetFail) return route.abort('blockedbyclient');
          return route.fulfill({ contentType: 'text/javascript', body: sdk });
        }
        if (url.pathname.startsWith('/modules/')) return route.fulfill({ contentType: 'text/javascript', body: readFileSync(`${root}app/javascript/analytics/${url.pathname.split('/').at(-1)}`) });
        return route.fulfill({ contentType: 'text/html', body: options.disabled ? html.replace(panel, '') : html });
      }
      record.requests.push({ type: 'intercepted', url: req.url(), method: req.method() });
      if (url.hostname === 'api-eu.mixpanel.com' && url.pathname === '/track/') {
        const envelope = decode(req); record.envelopes.push(...(Array.isArray(envelope) ? envelope : [envelope]));
        return route.fulfill({ status: 200, headers: { 'access-control-allow-origin': origin }, body: '{"status":1,"error":null}' });
      }
      return route.abort('blockedbyclient');
    });
    const page = await context.newPage();
    page.on('pageerror', err => record.errors.push(err.message));
    await page.goto(`${origin}/contacto.html?email=PII_CANARY%40fixture.invalid&gclid=PII_CANARY&utm_source=campaign#PII_CANARY`);
    await page.waitForFunction(() => window.api);
    await page.evaluate(() => Object.defineProperty(document, 'referrer', { configurable: true, value: 'https://source.invalid/path?email=PII_CANARY#PII_CANARY' }));
    async function snap(stage) {
      const value = await page.evaluate(() => ({ accesses: [...window.storageAccesses], local: { ...localStorage }, session: { ...sessionStorage }, cookies: document.cookie, sdk: !!window.mixpanel, consent: window.api.hasConsent() }));
      record.snapshots.push({ stage, ...value }); return value;
    }
    const accept = async () => { await page.locator('[data-consent-choice="accept"]').focus(); await page.keyboard.press('Enter'); await page.waitForFunction(() => window.api.hasConsent()); await page.waitForTimeout(100); };
    const revoke = async () => { await page.locator('[data-consent-choice="revoke"]').focus(); await page.keyboard.press('Space'); await page.waitForTimeout(100); };
    await operation({ page, record, snap, accept, revoke, release });
    assert.deepEqual(record.errors, []);
    for (const envelope of record.envelopes) {
      assert.ok(Object.keys(envelope.properties).every(k => [...business, ...technical].includes(k)));
      assert.equal(envelope.properties.token, dummy);
    }
    assert.ok(!JSON.stringify(record.envelopes).includes('PII_CANARY'));
    // Deliberately poisoned legacy state remains untouched before permission;
    // candidate must purge it before SDK init on the next explicit acceptance.
    assert.ok(!JSON.stringify(record.snapshots.filter(s => s.stage !== 'reload-before-choice')).includes('PII_CANARY'));
    assert.ok(record.requests.filter(r => r.type === 'intercepted').every(r => new URL(r.url).pathname === '/track/' && new URL(r.url).hostname === 'api-eu.mixpanel.com'));
    record.passed = true;
    await context.close();
  }
  await scenario('keyboard/mobile explicit accept, revoke and namespace preservation', async ({ page, record, snap, accept, revoke }) => {
    const before = await snap('before-choice'); assert.deepEqual(before.accesses, []); assert.deepEqual(before.local, {}); assert.deepEqual(before.session, {}); assert.equal(before.sdk, false); assert.equal(record.requests.length, 0);
    await page.locator('[data-consent-choice="reject"]').click(); assert.equal((await snap('reject')).sdk, false);
    const dimensions = await page.locator('[data-consent-choice="accept"]').boundingBox(); assert.ok(dimensions.height >= 44);
    const rejectDimensions = await page.locator('[data-consent-choice="reject"]').boundingBox(); assert.equal(dimensions.height, rejectDimensions.height);
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
    await page.screenshot({ path: `${root}tmp/sdk-evidence/mobile-choice.png` });
    await page.evaluate(() => localStorage.setItem('unrelated-site', 'preserve'));
    await accept(); const active = await snap('accepted'); assert.equal(active.consent, true); assert.equal(record.envelopes.length, 1);
    await revoke(); const stopped = await snap('revoked'); assert.deepEqual(stopped.local, { 'unrelated-site': 'preserve' }); assert.deepEqual(stopped.session, {}); assert.equal(stopped.sdk, false);
    await page.evaluate(() => window.api.track('page_view')); await page.waitForTimeout(100); assert.equal(record.envelopes.length, 1);
    await page.reload(); await page.waitForFunction(() => window.api);
    const reloaded = await snap('revoked-reload'); assert.deepEqual(reloaded.local, { 'unrelated-site': 'preserve' }); assert.deepEqual(reloaded.session, {}); assert.equal(record.envelopes.length, 1); assert.equal(reloaded.sdk, false);
  }, { mobile: true });
  await scenario('reload safe identity reuse, unsafe superprop purge and creation-based 30day expiry', async ({ page, record, snap, accept }) => {
    await accept(); const first = await snap('first'); const id = JSON.parse(first.local[identity]);
    await page.evaluate(token => { const key = `mp_${token}_mixpanel`; const saved = JSON.parse(localStorage.getItem(key)); saved.gclid = 'PII_CANARY'; saved.__mps = { email: 'PII_CANARY' }; localStorage.setItem(key, JSON.stringify(saved)); }, dummy);
    await page.reload(); await page.waitForFunction(() => window.api); assert.equal((await snap('reload-before-choice')).consent, false);
    await accept(); const reused = await snap('reaccepted'); assert.deepEqual(JSON.parse(reused.local[identity]), id);
    await page.clock.setFixedTime(new Date(id.created_at + 30 * 24 * 60 * 60 * 1000));
    await page.reload(); await page.waitForFunction(() => window.api); await accept(); const renewed = await snap('30day-renewed'); assert.notEqual(JSON.parse(renewed.local[identity]).device_id, id.device_id);
    assert.equal(record.envelopes.length, 3);
  });
  await scenario('denied storage fails closed', async ({ page, record, snap }) => {
    await page.evaluate(() => { Storage.prototype.setItem = () => { throw new Error('Denied'); }; });
    await page.locator('[data-consent-choice="accept"]').click(); await page.waitForTimeout(100);
    const denied = await snap('denied-storage'); assert.equal(denied.consent, false); assert.equal(denied.sdk, false); assert.equal(record.requests.length, 0);
  });
  await scenario('PII-tainted legacy anonymous identity is not reusable', async ({ page, record, accept, snap }) => {
    await page.evaluate(({ token, key }) => {
      localStorage.setItem(key, JSON.stringify({ version: 1, created_at: Date.now(), device_id: 'PII_CANARY@fixture.invalid' }));
      localStorage.setItem(`mp_${token}_mixpanel`, JSON.stringify({ distinct_id: '$device:PII_CANARY@fixture.invalid', $device_id: 'PII_CANARY@fixture.invalid' }));
    }, { token: dummy, key: identity });
    await accept(); await snap('sanitized-identity'); assert.equal(record.envelopes.length, 1);
  });
  await scenario('all 12 event envelopes; SDK superprops and direct People attempts blocked from wire', async ({ page, record, accept, snap }) => {
    await accept();
    await page.evaluate(async () => {
      const { createSdkCollector } = await import('/modules/sdk.js');
      const { EVENTS } = await import('/modules/contract.js');
      const config = JSON.parse(document.querySelector('[data-analytics-consent]').dataset.config);
      window.api.setConsent(false);
      const collector = createSdkCollector(config);
      if (!await collector.start()) throw new Error('Collector did not start');
      window.mixpanel.register({ gclid: 'PII_CANARY', arbitrary: 'PII_CANARY' });
      window.mixpanel.track('page_view', { email: 'PII_CANARY' });
      window.mixpanel.people.set({ email: 'PII_CANARY' });
      for (const event of EVENTS) collector.send(event, { site: 'ipiia.pt', page_path: '/contacto.html' });
      if (collector.send('arbitrary_event', {}) !== false || collector.send('page_view', { email: 'PII_CANARY' }) !== false) throw new Error('Unknown boundary did not reject');
      window.mixpanel.register({ $device_id: 'PII_CANARY' });
      collector.send('page_view', { site: 'ipiia.pt' });
      collector.stop();
      collector.send('page_view', { site: 'ipiia.pt' });
    });
    await page.waitForTimeout(150);
    assert.equal(record.envelopes.length, 13);
    assert.equal(new Set(record.envelopes.map(e => e.event)).size, 12);
    assert.deepEqual((await snap('all-events-after-stop')).local, {});
  });
  await scenario('running identity expiry closes boundary and purges before another send', async ({ page, record, accept, snap }) => {
    await accept(); const first = await snap('initial-active'); const created = JSON.parse(first.local[identity]).created_at;
    await page.clock.setFixedTime(new Date(created + 30 * 24 * 60 * 60 * 1000));
    assert.equal(await page.evaluate(() => window.api.track('cta_clicked', { destination_type: 'email' })), false);
    const expired = await snap('expired-closed'); assert.equal(expired.consent, false); assert.deepEqual(expired.local, {}); assert.deepEqual(expired.session, {}); assert.equal(record.envelopes.length, 1);
  });
  await scenario('malformed asset config is rejected without throwing or accessing storage', async ({ page, snap, record }) => {
    assert.equal(await page.evaluate(async () => {
      const { validConfig } = await import('/modules/sdk.js');
      return validConfig({ enabled: true, token: 'SDK_CANDIDATE_DUMMY_NO_PROJECT', asset: 'http://[' });
    }), false);
    assert.deepEqual((await snap('invalid-config')).accesses, []); assert.equal(record.requests.length, 0);
  });
  await scenario('failed lazy SDK download purges candidate state and fails closed', async ({ page, snap, record }) => {
    await page.locator('[data-consent-choice="accept"]').click(); await page.waitForTimeout(150);
    const failure = await snap('asset-failure'); assert.equal(failure.consent, false); assert.equal(failure.sdk, false); assert.deepEqual(failure.local, {}); assert.deepEqual(failure.session, {}); assert.equal(record.envelopes.length, 0);
  }, { assetFail: true });
  await scenario('accept/reject during lazy load prevents stale init', async ({ page, record, snap, release }) => {
    await page.locator('[data-consent-choice="accept"]').click(); await page.waitForTimeout(50);
    await page.locator('[data-consent-choice="reject"]').click(); release(); await page.waitForTimeout(150);
    const stopped = await snap('lazy-race-rejected'); assert.equal(stopped.consent, false); assert.equal(stopped.sdk, false); assert.deepEqual(stopped.local, {}); assert.deepEqual(stopped.session, {}); assert.equal(record.envelopes.length, 0);
  }, { delay: true });
  await scenario('disabled env has no CMP SDK or state', async ({ page, record, snap }) => { assert.equal(await page.locator('[data-analytics-consent]').count(), 0); assert.deepEqual((await snap('disabled')).local, {}); assert.equal(record.requests.length, 0); }, { disabled: true });
  receipt.status = 'PASSED';
} catch (err) { receipt.status = 'FAILED'; receipt.failure = { message: err.message, stack: err.stack }; process.exitCode = 1; }
finally { if (browser) await browser.close(); mkdirSync(`${root}tmp/sdk-evidence`, { recursive: true }); writeFileSync(`${root}tmp/sdk-evidence/receipt.json`, JSON.stringify(receipt, null, 2)); }
console.log(JSON.stringify({ status: receipt.status, scenarios: receipt.scenarios.map(s => ({ name: s.name, passed: s.passed, envelopes: s.envelopes.length, errors: s.errors })), failure: receipt.failure }, null, 2));
