# Current-source local recovery preview

## Provenance and scope

The immutable source anchor is `db7fa7f01b8a899dee090013d16b35364d7e0ada`, tree `32f0d901624b6a859ee6f29725e388bbcd4cd17b`, on `provenance/ipiia-current-09a46cd72-20261006`. The preview branch is `recovery/ipiia-b20a9c9-preview`; its first support commit must have that anchor as its sole parent. Historical recovery is evidence, not the current implementation base.

This is local preview support, not deployment, analytics implementation, public-copy approval or integrated release approval. The source receipt establishes only 198 allowlisted files, with 6 build-context exceptions and 15 inherited excluded entries. Those inputs are not proof of complete live dirty-worktree equivalence. Existing QA, integrated review and canonical publisher gates remain mandatory.

## Prerequisites and operations

Use Python 3, Git and a working LOCAL Docker engine via a unix socket. No Ruby install is required on the host. Use a clean clone/checkout of the exact approved preview commit. Do not copy keys, `.env`, `.bundle`, database files, runtime data or production volumes. Unset inherited integration configuration. Builds contact package/image registries; interactive preview has no external runtime networking.

```
git clone --single-branch --branch recovery/ipiia-b20a9c9-preview https://github.com/zelusototmayor/ipiia.pt.git
cd ipiia.pt
git checkout <approved-exact-preview-commit>
python3 script/recovery_preview_test.py
bin/recovery-preview build
bin/recovery-preview up
bin/recovery-preview verify
bin/recovery-preview down
```

`build` requires a clean commit descending from the current anchor. It stages only tracked files, excluding the exact 15 inherited exceptions by path (and validating their unchanged Git object identities without reading their values). It creates empty runtime directories. Neither credentials ciphertext, `.kamal`, `.env`, host data nor untracked files are sent to Docker. The original Dockerfile is unchanged, including its `SECRET_KEY_BASE_DUMMY=1` production asset precompile. Two local images are tagged with the full candidate SHA: `ipiia-recovery-tools:<sha>` (original build stage) and `ipiia-recovery-app:<sha>` (original final production stage). The latter is the production-equivalent BUILD gate, not a claim of production-data/config equivalence. Credentials exclusion is an intentional safety difference.

`up` runs that final image in Rails `test`, with a freshly generated ephemeral secret, newly prepared empty SQLite database, test mail delivery and test-job behavior. No secrets are hardcoded or borrowed from the host. The container has `--network none`, no published ports, no bind mounts/volumes, dropped capabilities, no privilege escalation, a read-only root filesystem and tmpfs storage/log/tmp. Rails binds only its own `127.0.0.1`. A Python loopback proxy at `http://127.0.0.1:43187` tunnels approved GETs through `docker exec curl`. There is no Docker bridge or external-network path. `RECOVERY_PREVIEW_PORT` can select a different unprivileged port; `RECOVERY_PREVIEW_HOST` must remain `127.0.0.1`.

The proxy exposes only `/up`, the CURRENT sitemap's 24 public paths, local assets and synthetic empty availability (`{"slots":[],"preview":true}`). Forms/bookings/checkouts/login/learning/write routes are NOT available. Mutating requests return 405. Unknown paths and non-loopback Host headers return 403. External links and mail/tel actions are neutralized, form submission is blocked and CSP forbids external resources, connections, frames and form actions. The response-only filter removes Google Fonts imports: preview uses fallback fonts. No source template/style is changed. These deliberate restrictions mean the preview is for public-page code/rendering, not real integration flows.

`verify` GETs `/up` and every current sitemap path, deduplicates and fetches their referenced local assets, validates CSP, inspects network/port/mount/environment isolation, checks credential paths are absent in the container, ensures no production-named database exists and confirms every application table has zero rows. It never follows sitemap hosts, links or submits forms. For browser checks use this loopback URL only and do not submit workflows. Record browser requests, console/page errors and server logs. Record any preview-specific restrictions separately from source regressions.

`down` shuts down the owned loopback proxy, verifies the container's exact owner label, removes only that container (and its tmpfs), deletes its ignored `tmp/recovery-preview` state, and verifies the container is absent. It creates no named volumes or custom networks. Build images/cache remain local for reproducibility, not runtime data; optionally remove only the two explicit candidate image tags after review. Never prune/reset shared Docker. Repeated `down` is safe. A second `up` fails if state exists; run `down` first. Failed startup automatically cleans up.

## Gates and evidence

Run full Rails tests once per frozen candidate, plus focused harness tests, direct Brakeman, RuboCop, importmap audit and production assets precompile. Use disposable `--rm --network none` tools-image containers with tmpfs `/rails/storage`, `/rails/log` and `/rails/tmp`; supply synthetic configuration only. Rails tests: `RAILS_ENV=test bin/rails test`. The tooling gems are in the unchanged original build stage. Importmap advisory audit requires package-advisory access (no analytics/payment/calendar/email). Compare exact current anchor lint/security JSON fingerprints to candidate: zero new unexplained findings, not zero inherited findings. Do not reuse historical counts as current evidence.

Evidence must include exact commit/tree/sole parent, original/context exception object identities, source-only diff, image ID/size/repo digests (locally built images may have no registry digest), commands/exits, route/asset counts, isolation inspection, synthetic database row counts, browser/HTTP/server/network observations, secret/runtime scans of new files, inherited exception classifications and cleanup readback. No secrets, customer data or full inspect environment values belong in committed docs or reports. Existing public source email/copy stays approval-gated and unchanged.

## Rollback and authority

Run `bin/recovery-preview down`, then revert/remove only the preview-support commit through the authorized preview branch workflow. No production rollback, Kamal, main/default/historical ref changes, force-push, public URL, DNS, accounts, provider calls, payments or analytics are authorized. Technical return owner: Engineering Max; Marketing goal owner: Marketing Max through `t_4845f7ce`. Independent QA/release approval is downstream, never self-approved here.
