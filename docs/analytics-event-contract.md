# IPIIA analytics contract v1 — disabled local synthetic candidate

Base: https://github.com/zelusototmayor/ipiia.pt, recovery/ipiia-b20a9c9-preview
972e6af51dec933b09ae32dc197a65e4eac05dda, tree aae2f29d4c0622cceb2c660b858c8d2d38499cdb,
sole parent db7fa7f01b8a899dee090013d16b35364d7e0ada. Candidate branch analytics/t_2e812733.
Scope: LOCAL MOCK/SYNTHETIC only. Not production-ready privacy/release approval.

Historical phase only: the separately frozen official SDK/CMP/env successor is
documented in analytics-sdk-candidate.md. Do not use the mock-only storage/identity
claims below as current official SDK or production facts.

## Single site-local boundary

app/javascript/analytics/contract.js is the versioned exact 12-event/15-business-property
allowlist. provider.js owns track(eventName, controlledProps), explicit setConsent,
pageView, begin and confirmed-success helpers. index.js connects public DOM bindings;
application.js calls helpers at existing actual state transitions/success boundaries.
Unknown keys/names throw with production:false (development/tests); production drops
whole events. Static route dictionary supplies titles (never document.title), IDs and
labels (never DOM text). Query/hash never cross the boundary. Unknown or tokenized
routes have no page_path/title; booking uses /book-call.html as safe completion context.
UTMs: only five exact keys; lowercase/trim then ASCII slug 1–100 chars. No replacement
of personal text. Duplicate keys, emails, spaces, phone-like digit runs are dropped.
Referrer: external HTTP(S) hostname only, max253; no credentials/IPs/own subdomains.
device_type comes from viewport buckets desktop/tablet/mobile/unknown.

## Consent, storage, expiry — exact matching-copy facts

Default: collector=null. No SDK, analytics network, identifier, cookie, storage read or
write before consent; denial is silent. Consent alone cannot activate the disabled
instance. Only installLocalCollector on localhost/127.0.0.1 can install the mock.
No consent persistence key exists on this candidate: consent is in-memory and resets
on full document load. No anonymous identifier exists in the local mock. No session
storage or analytics cookie exists. Preview consent UI is test-only, not public copy.

After explicit local opt-in only: org_analytics_attribution_v1 in first-party localStorage,
JSON {version:1,first:{at,props}|null,last:{at,props}|null}. at is a local millisecond timestamp,
never an emitted business property. Each touch expires at 30days (2592000000ms).
First remains immutable until expiry; last refreshes on valid UTM/external document
referrer. SPA transitions do not reuse the old document referrer. Only normalized UTM
keys/referrer hostname are persisted. Expired/tampered records are sanitized/purged.
Events use valid last-touch properties; first-touch retained for future approved analysis,
not expanded into forbidden first_* event keys. Storage-unavailable browsing works.

Revoke setConsent(false): close send boundary first, stop collector, delete this one
attribution key, clear in-memory start/completion/page dedupe; no queued replay. Mock
stop creates no identity. The SYNTHETIC injected SDK adapter tests opt-out(clear_persistence),
reset, opt-out(clear_persistence) ordering, never identify/People. It is NOT a loaded/audited
live SDK and does not establish actual provider storage names or reset behavior.

Future SDK identity/consent storage names/TTLs are deliberately UNKNOWN until the actual
pinned official SDK is independently inspected/tested by the existing release gate.
Do not approve copy claiming no identifier or a particular mp_* key/TTL for a live SDK
based on this mock. No real MIXPANEL_TOKEN was read/generated/injected. Proven deployment
uses config/deploy.yml/.kamal/secrets; future approved wiring must source MIXPANEL_TOKEN
there, not hard-code it. This commit changes neither deployment env nor CSP nor policies.

## Surface mapping and integrity

All static PagesController routes plus five funding guides have static titles/bindings.
Nav/footer/page links to known routes -> cta_clicked; controlled section anchors -> intent.
Mail/tel -> cta_clicked plus email_clicked/phone_clicked with generic controlled metadata,
never address/number. Exact source-controlled outbound host set -> cta_clicked plus
outbound_clicked, including external PDFs. Checkout buttons -> cta_clicked only.
CTA IDs group area + destination; no arbitrary DOM text and no per-instance uniqueness
claim. No current tel surface. ASSETS is empty: resource_downloaded is NOT emitted.

Contact/waitlist: first focus or actual submission -> contact_started once per page;
contact_submitted only actual 2xx JSON ok:true in original handler. 200 idempotent waitlist
success remains success. Diagnostic: actual question-panel transition -> diagnostic_started;
actual 2xx ok:true -> diagnostic_completed (not finished answers/lead panel/click).
Booking: actual date selection/widget transition -> booking_started. Native form submission
with current opt-in adds analytics_consented=true (no form values read). After a saved row
only, server stores one-shot analytics_booking_completed flash in the necessary Rails
session; show consumes it into a boolean meta marker (no token/data). Browser consumes
and removes it; reload/bare persisted URL/failed save are not completion. Opt-in parameter
is a client assertion, NOT legal proof of a human decision. Revoke removes stale hidden
opt-in field on next submission. Existing saved booking is NOT a verified Calendar meeting;
no external provider-final success claim. Raw track cannot emit completed conversions.

page_view: initial opted-in route once; duplicate load/pageshow/Turbo hooks and same-path
query/hash suppressed; actual A-B-A navigation emits real views. No Turbo was newly enabled.

## EU/config facts, limits and release gates

Official https://docs.mixpanel.com/docs/tracking-methods/sdks/javascript documents EU
api_host https://api-eu.mixpanel.com. Synthetic adapter flags: autocapture:false,
track_pageview:false, record_sessions_percent:0, record_heatmap_data:false, ip:false,
stop_utm_persistence:true, secure cookie, no cross-subdomain cookie, no identify/People,
no batch queue. No external loader exists. SDK default envelope properties/identity,
remote settings, reset-persistence semantics and exact blacklist must be audited with
an actual pinned SDK BEFORE live wiring; synthetic calls do not prove those controls.
ip:false is geolocation suppression, NOT transport-IP elimination.

Configuration t_2f380690 v5 receipt402: existing Growth org2960153/project3855329 EU,
default published event retention2years; no configured custom7day retention proven.
Deletion undo7days is not retention; official cleanup can take up to30days. No forwarding
assurance. Organization-wide allowance/usage is shared and overage is chargeable, not
hard capped; Jose accepted existing Growth exposure, not guaranteed below1M. No billing
changes or report/provider writes here. First-party v3 remains uninstalled.

Marketing owns matching Mixpanel-specific processor/privacy/cookies/consent copy approval.
Existing independent t_09188703 and publisher t_bd58c92d remain mandatory. This parent
completion releases implementation handoff ONLY, never live copy/events/deploy. No new
cards, direct user notifications or files. Existing public policy/banner/footer unchanged.

## Verification and rollback

node --experimental-loader ./test/javascript/analytics_loader.mjs --test test/javascript/analytics_contract_test.mjs
bin/rails test (including test/integration/analytics_booking_confirmation_test.rb)
Direct bundle exec rubocop / brakeman, bin/importmap audit; production Dockerfile/tools
and assets through bin/recovery-preview build (filtered safe context, no credential files).
Local browser uses mock only; controlled synthetic fetch responses, no provider requests
or real submissions. Results/performance/evidence are in the native task handoff.
No package.json, JS formatter or typecheck was present; native Node syntax/unit checks and
JSDoc are used; no invented typecheck pass. Existing lint/security baselines are documented,
not unrelated autocorrected. Rollback: revert candidate commit; remove/disable any future
MIXPANEL_TOKEN deployment injection (unset on this run); bin/recovery-preview down removes
local preview/container/tmpfs only. Do not invoke Kamal on this card.
