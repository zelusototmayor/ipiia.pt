// IPIIA business event contract v1. No DOM text or form values are metadata.
export const VERSION = 1;
export const EVENTS = Object.freeze(['page_view', 'cta_clicked', 'contact_started', 'contact_submitted', 'booking_started', 'booking_completed', 'diagnostic_started', 'diagnostic_completed', 'resource_downloaded', 'email_clicked', 'phone_clicked', 'outbound_clicked']);
export const PROPERTIES = Object.freeze(['site', 'page_path', 'page_title', 'cta_id', 'cta_label', 'destination_type', 'form_id', 'asset_id', 'referrer_domain', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'device_type']);
export const UTM_KEYS = Object.freeze(['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term']);
export const STORAGE_KEY = 'org_analytics_attribution_v1';
export const TTL = 30 * 24 * 60 * 60 * 1000;
export const FORMS = Object.freeze({ contact: '#contact-form', course_waitlist: '#waitlist-form', diagnostic: '#ai-test-lead-form', booking: '#booking-form' });
export const DESTINATIONS = Object.freeze(['internal', 'booking', 'diagnostic', 'contact', 'email', 'phone', 'external', 'checkout', 'resource']);
// No proven completed-download surface exists. Keep the dictionary empty.
export const ASSETS = Object.freeze([]);

export function pathname(value) {
  try { return new URL(value, 'https://ipiia.pt').pathname.slice(0, 512); } catch { return null; }
}
export function slug(value) {
  if (typeof value !== 'string') return null;
  const normalized = value.trim().toLowerCase();
  // ASCII only, no punctuation replacement/transliteration of personal text.
  return /^[a-z0-9][a-z0-9._~-]{0,99}$/.test(normalized) && !/\d{7,}/.test(normalized) ? normalized : null;
}
export function externalHost(value) {
  try {
    const url = new URL(value);
    const host = url.hostname.toLowerCase();
    return ['https:', 'http:'].includes(url.protocol) && !url.username && !url.password &&
      host.length <= 253 && /^[a-z0-9.-]+$/.test(host) && !/^\d+(\.\d+){3}$/.test(host) &&
      host !== 'ipiia.pt' && !host.endsWith('.ipiia.pt') && host !== 'localhost' ? host : null;
  } catch { return null; }
}
export function touchFrom(url, referrer) {
  const props = {};
  try {
    const params = new URL(url, 'https://ipiia.pt').searchParams;
    for (const key of UTM_KEYS) {
      // Duplicate parameters are ambiguous; never take a convenient first one.
      const values = params.getAll(key);
      const value = values.length === 1 ? slug(values[0]) : null;
      if (value) props[key] = value;
    }
  } catch { /* malformed URL contributes nothing */ }
  const host = externalHost(referrer);
  if (host) props.referrer_domain = host;
  return props;
}
