# IPIIA official SDK/CMP/env candidate (local, disabled by default)

This supersedes only the SDK/CMP/env unknowns of the historical mock-only
39da731 candidate documented in analytics-event-contract.md. It is NOT privacy,
public-copy, release, production consent, real conversion or provider approval.
The existing independent t_09188703 and publisher t_bd58c92d gates remain intact.
No application.js, deployment configuration, live token or public policy is changed.

## Artifact and activation boundary

Official self-hosted mixpanel-browser 2.84.0, dist/mixpanel.min.js, exactly
SHA256 1a10e96045c70c048725f81778fa82fbb731513a4876f0e0daa96a57a9bed279.
Package provenance/SRI/SHA1 is the preserved Engineering Max audit3e13512;
license is docs/mixpanel-2.84.0-LICENSE. No CDN/latest loader, package scripts,
remote settings, feature flags or dynamic third-party code are permitted.

AnalyticsHelper renders the local explicit-choice panel ONLY when runtime
IPIIA_ANALYTICS_ENABLED=true and MIXPANEL_TOKEN is a valid browser-token string.
Both remain unset/disabled by default; neither deploy-env source nor global env
was changed. Candidate tests use SDK_CANDIDATE_DUMMY_NO_PROJECT only.
The server's asset_path gives a same-origin versioned lazy asset URL; importing
analytics/sdk does not load the library. Only explicit Accept loads/initializes it.
Reject and Revoke have equal native-button styling, keyboard activation, visible
focus, >=44px targets, status announcements and wrapping mobile layout. Consent
is memory-only and resets on a full load. This UI text is candidate copy, not a
published or approved replacement policy. There is no consent persistence key.

All original 12 events and 15 business keys remain unchanged. Production drops
unknown events/properties; development/test rejection remains available via
production:false. Wrapper supplies static titles/labels, pathname only, normalized
UTMs and hostname-only attribution; no form values or arbitrary DOM text is read.

## Real SDK serialized envelope (separate from business properties)

Only these seven SDK technical fields additionally cross the before_send_events
hook: token, distinct_id, $device_id, $insert_id, time, mp_lib, $lib_version.
Token must equal config; IDs must equal the validated anonymous UUIDv4 instance
and $device:<UUID> respectively; insert ID is the pinned random 16-character
lowercase alphanumeric format; time is finite SDK epoch seconds; library is web,
version 2.84.0. They are not permission for gclid, arbitrary properties or People.
The hook requires a synchronous pending controlled wrapper send; direct SDK events
and stale/delayed hooks are dropped. It rebuilds properties from that pending call,
not SDK superprops. Legacy IDs containing personal text are not reusable.

Explicit EU api_host=https://api-eu.mixpanel.com, ip=false, XHR POST JSON,
batch_requests=false, batch_autostart=false, autocapture=false,
track_pageview=false, record_sessions_percent=0, record_heatmap_data=false,
skip_first_touch_marketing=true, store_google=false, track_marketing=false,
save_referrer=false, flags=false, remote_settings_mode=disabled,
stop_utm_persistence=true. No application identify/People calls; People/group send
hooks always return null. No queued event replay. SDK-local cookie helper is
suppressed (not the browser cookie API); if the pinned helper is absent, fail closed.
No unreviewed cookie fallback. Ordinary processor network-IP receipt is unavoidable;
ip=false requests suppression of geolocation enrichment, not network anonymity.

## Exact owned key inventory and expiry

After permission only, first-party localStorage:
  mp_<token>_mixpanel — exactly anonymous distinct_id/$device_id in normal use.
  __mp_opt_in_out_<token> — SDK opt-in marker "1"; NOT persisted legal consent.
  org_analytics_identity_v1 — version1, created_at milliseconds, device_id UUID.
  org_analytics_attribution_v1 — original separate version1 first/last touch records.

SessionStorage:
  mp_tab_id_mixpanel_<token> — SDK random tab identifier.
  mp_gen_new_tab_id_mixpanel_<token> — SDK generation marker.

Availability probing transiently writes/restores org_analytics_identity_v1 in
both storage types after choice; it leaves no extra session metadata key.
No analytics cookies or batch keys were observed. No persistent consent key.

SDK localStorage has no native TTL. This wrapper enforces 30days FROM CREATION,
not last use, using org_analytics_identity_v1. Reuse requires matching valid
anonymous IDs and unexpired creation metadata. Before SDK initialization, it
purges this instance namespace and rebuilds only the safe identity pair; legacy
superprops/People queues are never loaded into the SDK. Missing/malformed metadata,
invalid/PII ID, future timestamp or expiry prevents reuse. Existing JSON parse
failure fails closed and purges, rather than guessing a usable identity.

On the next permitted start, expired identity is replaced. On the next permitted
send/isActive check after expiry, the boundary closes and namespace is purged.
There is NO automatic deletion while code is not running: existing expired browser
records can remain until next permitted access. Full reload before new consent does
not touch retained state or load SDK, even if it is old/unsafe. Existing first/last
attribution expiry remains separate (30days per touch); no new first_* wire fields.

Revoke closes boundary first, opts out with clear_persistence:true/delete_user:false,
purges all four local and both session keys, discards the instance/global reference,
and clears wrapper state. It deliberately does NOT reset the SDK (reset creates a
new ID). Unrelated storage is preserved. In-flight requests already dispatched
while permission was valid cannot be recalled; no new delayed/queued dispatch is
permitted after revoke. Lazy accept/reject race is generation-guarded. If browser
policy denies reads/writes, activation fails closed; deletion is best effort if
browser policy also denies removal. Do not promise physical erasure in that case.

## Reproduction and scope of proof

Generate actual panel/config/importmap evidence with the isolated native test:
  RAILS_ENV=test bin/rails test test/integration/analytics_sdk_candidate_test.rb
Then, with a locally installed Playwright and Chrome:
  IPIIA_PLAYWRIGHT_MODULE=/path/to/playwright/index.mjs node test/javascript/analytics_sdk_candidate.mjs
Default module specifier is playwright. There is no new project package manifest.
The harness reads the actual Rails-rendered CMP partial/config and candidate modules
into a minimal loopback-origin fixture, NOT a full deployed-page equivalence claim.
EVERY browser request is locally fulfilled or aborted; no route.continue, provider
connection, real token or actual submission. Raw envelopes/storage snapshots and
mobile screenshot are saved in tmp/sdk-evidence. A deliberate legacy PII fixture
is retained only in the labelled pre-choice snapshot, then purged before SDK init.
All 12 events are tested at the real SDK boundary; this does NOT fabricate an
unsupported site surface or provider-confirmed conversion. Original mock/surface
proof is preserved, not backfilled as official SDK acceptance.

Changed-byte production-Dockerfile/asset build and native gates must run from the
exact frozen candidate. Use the existing filtered bin/recovery-preview builder,
not the unfiltered repo as Docker context (credentials exclusions remain unchanged).
Retain inherited lint/security findings separately from any new findings.

Rollback: revert this single SDK/CMP/env candidate commit, then (if the earlier
mock phase is also being removed) revert39da731 followed by0396010. Keep
IPIIA_ANALYTICS_ENABLED unset/false and MIXPANEL_TOKEN unset; no production env
has been modified. Do not invoke Kamal/deploy or send provider traffic on this card.
Marketing Max owns matching processor/retention/cookies copy and approval;
Engineering Max owns integration/publisher and application.js hotspot.
