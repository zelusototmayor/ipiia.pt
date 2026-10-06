import { EVENTS, PROPERTIES, UTM_KEYS, STORAGE_KEY, TTL, FORMS, ASSETS, DESTINATIONS, pathname, slug, externalHost, touchFrom } from 'analytics/contract';
import { ROUTES, BINDINGS } from 'analytics/dictionary';

/** @typedef {'desktop'|'tablet'|'mobile'|'unknown'} DeviceType */
/** Site-local boundary. collector is disabled by default; no buffering/replay. */
export function createAnalytics({ collector = null, storage = () => window.localStorage, now = () => Date.now(), production = true, context = () => ({ url: window.location.href, referrer: document.referrer, width: window.innerWidth }) } = {}) {
  let consent = false;
  let consentGeneration = 0;
  let pendingConsent = false;
  let attribution = { version: 1, first: null, last: null };
  let lastPage = null;
  let lastAttributionUrl = null;
  const started = new Set();
  const completed = new Set();
  const reject = (message) => { if (!production) throw new TypeError(message); return false; };
  const io = (fn) => { try { return fn(storage()); } catch { return null; } };
  const safeTouch = (record) => {
    if (!record || !Number.isFinite(record.at) || record.at > now() || now() - record.at >= TTL) return null;
    const props = {};
    for (const key of UTM_KEYS) {
      const value = slug(record.props?.[key]);
      if (value) props[key] = value;
    }
    const host = externalHost(`https://${record.props?.referrer_domain || ''}`);
    if (host) props.referrer_domain = host;
    return Object.keys(props).length ? { at: record.at, props } : null;
  };
  function updateAttribution() {
    if (!consent) return;
    if (collector?.isActive && !collector.isActive()) { setConsent(false); return; }
    const saved = io((store) => JSON.parse(store.getItem(STORAGE_KEY) || 'null'));
    attribution = { version: 1, first: safeTouch(saved?.version === 1 ? saved.first : null), last: safeTouch(saved?.version === 1 ? saved.last : null) };
    const ctx = context();
    const props = ctx.url === lastAttributionUrl ? {} : touchFrom(ctx.url, lastAttributionUrl === null ? ctx.referrer : '');
    lastAttributionUrl = ctx.url;
    if (Object.keys(props).length) {
      const touch = { at: now(), props };
      attribution.first ||= touch;
      attribution.last = touch;
    }
    if (attribution.first || attribution.last) io((store) => store.setItem(STORAGE_KEY, JSON.stringify(attribution)));
    else io((store) => store.removeItem(STORAGE_KEY));
  }
  function setConsent(value) {
    const generation = ++consentGeneration;
    if (value === true && !consent) {
      // No SDK init, identity creation or storage access before explicit opt-in.
      const accepted = (result) => {
        if (generation !== consentGeneration || result === false) return false;
        pendingConsent = false;
        consent = true;
        updateAttribution();
        pageView();
        return true;
      };
      try {
        if (!collector) return false;
        pendingConsent = true;
        const result = collector.start();
        if (result?.then) return result.then(accepted, () => accepted(false));
        return accepted(result);
      } catch { pendingConsent = false; return false; }
    } else if (value !== true) {
      const wasConsented = consent;
      consent = false; // close boundary before reset/opt-out (including callbacks)
      if (wasConsented || pendingConsent || collector?.isActive) {
        try { collector?.stop(); } catch { /* transport failure cannot reopen consent */ }
        io((store) => store.removeItem(STORAGE_KEY));
      }
      pendingConsent = false;
      attribution = { version: 1, first: null, last: null };
      lastPage = null;
      lastAttributionUrl = null;
      started.clear();
      completed.clear();
    }
    return consent;
  }
  function emit(eventName, controlledProps = {}) {
    if (!EVENTS.includes(eventName)) return reject('Unknown event');
    if (!controlledProps || typeof controlledProps !== 'object' || Array.isArray(controlledProps)) return reject('Invalid properties');
    if (Object.keys(controlledProps).some((key) => !PROPERTIES.includes(key))) return reject('Unknown property');
    if (!hasConsent()) return false;
    const props = { site: 'ipiia.pt' };
    const ctx = context();
    const path = pathname(controlledProps.page_path || ctx.url);
    // Only static public paths: never booking/auth/checkout tokens or arbitrary paths.
    if (path && Object.hasOwn(ROUTES, path)) {
      props.page_path = path;
      props.page_title = ROUTES[path].slice(0, 200);
    }
    const width = ctx.width;
    props.device_type = Number.isFinite(width) ? width < 768 ? 'mobile' : width < 1024 ? 'tablet' : 'desktop' : 'unknown';
    const binding = Object.hasOwn(BINDINGS, controlledProps.cta_id) ? BINDINGS[controlledProps.cta_id] : null;
    if (binding) Object.assign(props, binding);
    if (DESTINATIONS.includes(controlledProps.destination_type) && !binding) props.destination_type = controlledProps.destination_type;
    if (Object.hasOwn(FORMS, controlledProps.form_id)) props.form_id = controlledProps.form_id;
    if (ASSETS.includes(controlledProps.asset_id)) props.asset_id = controlledProps.asset_id;
    const last = safeTouch(attribution.last);
    if (last) Object.assign(props, last.props);
    // Never accept caller-supplied title/label/UTM/referrer/device/site values.
    try { return collector.send(eventName, props) !== false; } catch { return false; }
  }
  function track(eventName, controlledProps = {}) {
    if (!EVENTS.includes(eventName)) return reject('Unknown event');
    if (controlledProps && Object.keys(controlledProps).some((key) => !PROPERTIES.includes(key))) return reject('Unknown property');
    // Completion has no public click/URL shortcut. Only verified helpers emit it.
    if (['contact_submitted', 'booking_completed', 'diagnostic_completed', 'resource_downloaded'].includes(eventName)) return false;
    return emit(eventName, controlledProps);
  }
  function pageView() {
    if (!consent) return false;
    const path = pathname(context().url);
    if (!path || !Object.hasOwn(ROUTES, path) || path === lastPage) return false;
    updateAttribution();
    if (!track('page_view')) return false;
    lastPage = path;
    started.clear();
    completed.clear();
    return true;
  }
  function begin(flow) {
    if (!consent || !Object.hasOwn(FORMS, flow) || started.has(flow)) return false;
    const event = flow === 'booking' ? 'booking_started' : flow === 'diagnostic' ? 'diagnostic_started' : 'contact_started';
    if (!track(event, { form_id: flow })) return false;
    started.add(flow);
    return true;
  }
  function confirm(flow, { status, ok, serverMarker = false } = {}) {
    if (!consent || !Object.hasOwn(FORMS, flow) || completed.has(flow)) return false;
    // Booking marker is consumed from one-shot server flash after a saved row.
    if (flow === 'booking' ? !serverMarker : !started.has(flow) || !Number.isInteger(status) || status < 200 || status >= 300 || ok !== true) return false;
    const event = flow === 'booking' ? 'booking_completed' : flow === 'diagnostic' ? 'diagnostic_completed' : 'contact_submitted';
    if (!emit(event, { form_id: flow, ...(flow === 'booking' ? { page_path: '/book-call.html' } : {}) })) return false;
    completed.add(flow);
    return true;
  }
  function hasConsent() {
    if (consent && collector?.isActive && !collector.isActive()) setConsent(false);
    return consent;
  }
  return Object.freeze({ track, setConsent, pageView, begin, confirm, hasConsent });
}

// Historical mock adapter retained for the preserved local preview proof. Real
// pinned SDK candidate applies additional controls in analytics/sdk.
export const MIXPANEL_CONFIG = Object.freeze({
  api_host: 'https://api-eu.mixpanel.com', autocapture: false, track_pageview: false,
  record_sessions_percent: 0, record_heatmap_data: false, ip: false,
  cross_subdomain_cookie: false, secure_cookie: true, stop_utm_persistence: true,
  opt_out_tracking_by_default: true, persistence: 'localStorage', batch_requests: false,
  property_blacklist: ['$current_url', '$referrer', '$initial_referrer', '$initial_referring_domain', '$referring_domain', '$browser', '$browser_version', '$os', '$screen_height', '$screen_width', '$search_engine', 'mp_keyword']
});
export function syntheticSdkAdapter(factory, token) {
  let sdk = null;
  return {
    start() {
      sdk = factory();
      sdk.init(token, { ...MIXPANEL_CONFIG });
      sdk.opt_in_tracking({ track: false });
      return true;
    },
    send(event, props) { if (!sdk) return false; sdk.track(event, props); return true; },
    stop() {
      if (!sdk) return;
      try { sdk.opt_out_tracking({ clear_persistence: true }); }
      finally { sdk.reset(); sdk.opt_out_tracking({ clear_persistence: true }); sdk = null; }
    }
  };
}
