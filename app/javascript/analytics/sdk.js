import { EVENTS, PROPERTIES, STORAGE_KEY, TTL } from 'analytics/contract';
import { MIXPANEL_CONFIG } from 'analytics/provider';

export const IDENTITY_KEY = 'org_analytics_identity_v1';
const anonymousId = value => typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(value);
export const TECHNICAL_PROPERTIES = Object.freeze(['token', 'distinct_id', '$device_id', '$insert_id', 'time', 'mp_lib', '$lib_version']);
export const SDK_CONFIG = Object.freeze({
  ...MIXPANEL_CONFIG, skip_first_touch_marketing: true, store_google: false,
  track_marketing: false, save_referrer: false, flags: false,
  remote_settings_mode: 'disabled', api_transport: 'XHR', api_method: 'POST',
  api_payload_format: 'json', batch_autostart: false,
  opt_out_tracking_persistence_type: 'localStorage'
});
export function storageKeys(token) {
  return { local: [`mp_${token}_mixpanel`, `__mp_opt_in_out_${token}`, IDENTITY_KEY, STORAGE_KEY],
    session: [`mp_tab_id_mixpanel_${token}`, `mp_gen_new_tab_id_mixpanel_${token}`] };
}
export function validConfig(config) {
  if (config?.enabled !== true || typeof config.token !== 'string' || !/^[A-Za-z0-9_-]{8,128}$/.test(config.token) || typeof config.asset !== 'string') return false;
  try {
    const asset = new URL(config.asset, window.location.href);
    return asset.origin === window.location.origin && asset.pathname.startsWith('/assets/mixpanel-2.84.0');
  } catch { return false; }
}
function probe(store) {
  // Reuse an exact owned metadata key, restoring its old value. No probe IDs.
  const old = store.getItem(IDENTITY_KEY);
  store.setItem(IDENTITY_KEY, 'probe');
  if (store.getItem(IDENTITY_KEY) !== 'probe') throw new Error('Storage unavailable');
  if (old === null) store.removeItem(IDENTITY_KEY); else store.setItem(IDENTITY_KEY, old);
}
function loadAsset(asset) {
  return new Promise((resolve, reject) => {
    window.mixpanel = []; window.mixpanel._i = []; window.mixpanel.__SV = 1.2;
    const script = document.createElement('script');
    script.src = asset;
    script.onload = () => { script.remove(); resolve(window.mixpanel); };
    script.onerror = () => { script.remove(); reject(new Error('SDK unavailable')); };
    document.head.append(script);
  });
}
// Official pinned globals build, deliberately not a CDN bootstrap. No queue/replay.
export function createSdkCollector(config, { now = () => Date.now(), load = loadAsset } = {}) {
  let sdk = null, active = false, generation = 0, createdAt = null, loading = null, deviceId = null;
  const keys = storageKeys(config?.token);
  function purge(includeAttribution = true) {
    for (const [name, owned] of [['localStorage', keys.local], ['sessionStorage', keys.session]]) {
      for (const key of owned) {
        if (!includeAttribution && key === STORAGE_KEY) continue;
        try { window[name].removeItem(key); } catch { /* best effort when browser denies deletion */ }
      }
    }
  }
  function stop() {
    active = false; generation++;
    // Do not reset: reset generates a new identity. Close hooks first, discard instance.
    try { sdk?.opt_out_tracking({ clear_persistence: true, delete_user: false }); } catch { /* still purge */ }
    sdk = null; createdAt = null; deviceId = null;
    purge();
    delete window.mixpanel;
  }
  function available() {
    try { probe(window.localStorage); probe(window.sessionStorage); return true; } catch { return false; }
  }
  function live() {
    if (!active || !available() || !Number.isFinite(createdAt) || now() < createdAt || now() - createdAt >= TTL) {
      if (active) stop();
      return false;
    }
    return true;
  }
  function beforeSend(envelope) {
    if (!live() || !EVENTS.includes(envelope?.event)) return null;
    // Business fields come ONLY from the pending controlled wrapper call. Not SDK
    // superprops, URL marketing enrichment or caller-mutated provider state.
    if (!pending || pending.event !== envelope.event) return null;
    const technical = envelope.properties;
    if (technical.token !== config.token || technical.$device_id !== deviceId || technical.distinct_id !== `$device:${deviceId}` ||
        technical.mp_lib !== 'web' || technical.$lib_version !== '2.84.0' || !/^[a-z0-9]{16}$/.test(technical.$insert_id) ||
        !Number.isFinite(technical.time)) return null;
    const properties = { ...pending.props };
    for (const key of TECHNICAL_PROPERTIES) if (Object.hasOwn(envelope.properties, key)) properties[key] = envelope.properties[key];
    return { event: envelope.event, properties };
  }
  let pending = null;
  return {
    async start() {
      if (!validConfig(config) || loading) return false;
      const attempt = ++generation;
      if (!available()) { purge(); return false; }
      try {
        // SDK has no TTL. Validate creation metadata AND matching anonymous ID,
        // replace old superprops/People queues before the SDK can read them.
        const saved = JSON.parse(window.localStorage.getItem(keys.local[0]) || 'null');
        const meta = JSON.parse(window.localStorage.getItem(IDENTITY_KEY) || 'null');
        const reusable = meta?.version === 1 && Number.isFinite(meta.created_at) && meta.created_at <= now() && now() - meta.created_at < TTL &&
          anonymousId(saved?.$device_id) && saved.distinct_id === `$device:${saved.$device_id}` && meta.device_id === saved.$device_id;
        purge(false);
        if (reusable) window.localStorage.setItem(keys.local[0], JSON.stringify({ distinct_id: saved.distinct_id, $device_id: saved.$device_id }));
        createdAt = reusable ? meta.created_at : now();
        loading = load(config.asset);
        const library = await loading;
        loading = null;
        if (attempt !== generation) { delete window.mixpanel; return false; }
        if (!available()) { stop(); return false; }
        // SDK-local compatibility guard: public config alone permits a cookie
        // fallback. Disable its cookie helper, not the browser/site cookie API.
        // Pinned 2.84.0 exports this helper; fail closed if that changes.
        if (!library?._?.cookie) { stop(); return false; }
        library._.cookie.get = () => null;
        library._.cookie.set = () => false;
        library._.cookie.remove = () => {};
        library.init(config.token, { ...SDK_CONFIG, hooks: { before_send_events: beforeSend, before_send_people: () => null, before_send_groups: () => null } });
        sdk = window.mixpanel;
        sdk.opt_in_tracking({ track: false });
        const id = sdk.get_distinct_id(), device = sdk.get_property('$device_id');
        if (!anonymousId(device) || id !== `$device:${device}` || !available()) { stop(); return false; }
        deviceId = device;
        window.localStorage.setItem(IDENTITY_KEY, JSON.stringify({ version: 1, created_at: createdAt, device_id: device }));
        const persisted = JSON.parse(window.localStorage.getItem(keys.local[0]) || 'null');
        if (persisted?.distinct_id !== id) { stop(); return false; }
        active = true;
        return true;
      } catch { loading = null; stop(); return false; }
    },
    send(event, props) {
      if (!live() || !EVENTS.includes(event) || !props || Object.keys(props).some(key => !PROPERTIES.includes(key))) return false;
      pending = { event, props: { ...props } };
      try { return sdk.track(event, props, { transport: 'XHR', send_immediately: true }) !== null; }
      finally { pending = null; }
    },
    stop,
    isActive: live
  };
}
