# IPIIA b20a9c9 source recovery provenance

## Result

This branch is a bounded reconstruction, not the recovered original Git object.
The original commit-like Kamal version
`b20a9c9e3eaf268d87d7dfd29dc8e89ce35f4c28` was unavailable from every
accessible Git ref/object store and carried no recoverable Git metadata in the
runtime image. The reconstructed source starts from accessible baseline
`a5828237556938f446943096883580ad5c90cf1f` (tree
`0b5c4c8cb2f9dd0c3cc1cbe1a1c10527c276323a`) and replaces/adds only bytes
proven by the immutable active image.

Selected immutable image:

- Registry index digest: `sha256:c3011a731dac5e58a7164bbe28000d2c0648d8b7e9282fccaa818d7ada3c8cf0`
- Linux/amd64 manifest: `sha256:1f452844b99a968c653d40fd8117b36772657333b16c51eff6581fa45e4cf5be`
- Image config/ID: `sha256:e0174861d09eb270ef761f9ebd89c117acffe7235c8ad93c9f0138219b294e50`
- Read-only Docker-save archive SHA-256: `b4a96bcc50ae6f7d678b8a27d7b783866aec5fb4108b78230388bf9328a0f400`

The active container name carries the target Kamal version, is running the
exact image ID above, and `docker diff` reported zero changes under the safe
source/config/test/docs projection. No production write, container creation,
restart, deploy, registry mutation, or data-volume read was performed.

## Reconstruction accounting

The accessible baseline contains 200 tracked files.

- 172 tracked runtime-source files match the immutable image byte-for-byte and
  mode-for-mode; their baseline bytes were retained.
- 10 tracked runtime-source files differ and were copied byte-for-byte from the
  immutable image projection.
- 4 image-only deployed source files were manually reviewed and added
  byte-for-byte: one generic branded image asset, one stylesheet, one explicitly
  illustrative synthetic UI partial, and one design document.
- 16 tracked files are intentionally baseline-only because Docker excluded them
  from the image or because encrypted credential ciphertext was deliberately not
  recovered from the image.
- 2 tracked baseline files were removed because the recovery contract explicitly
  excludes `.env*` and `.kamal/secrets`.
- 2 image-only empty runtime directory placeholders under `tmp/` were not added.

The runtime-relevant equivalence boundary is therefore 186 paths: 182 tracked
baseline paths compared against the image plus 4 image-only deployed source
paths. Every path in that boundary has the exact image SHA-256 and compatible
Git mode recorded in `baseline-vs-active-image.json` and
`active-image-source.json`.

## Explicit confidence boundary

This reconstruction does not and cannot prove the unavailable original Git
commit object, original tree object, parents, author, committer, timestamps,
message, signature, or branch. It also cannot prove the original b20a9c9 bytes
for Docker-context-excluded metadata. Those files are enumerated individually
as baseline-only in `recovery-exclusions.json`.

`config/deploy.yml` is deliberately absent from the image because
`.dockerignore` excludes `config/deploy*.yml`. It is preserved from the
accessible baseline after review: it contains deployment topology, public/static
configuration, registry identity, and names of secret environment variables,
but no credential values. Its bytes are not claimed to be the unavailable
original b20a9c9 bytes.

`config/credentials.yml.enc` is preserved byte-for-byte from the accessible Git
baseline. Its image copy was intentionally not read or recovered. No master key,
decrypted credentials, environment file, secret value, database, storage,
customer/user data, log, cache, PID, socket, bundled dependency, compiled asset,
coverage output, backup, or dump was recovered into the branch.

## Original-object recovery attempts

Read-only attempts covered:

1. All accessible remote heads, tags, and pull-request heads.
2. Direct fetch by full object ID and both GitHub commit APIs.
3. Reachable and unreachable objects/reflogs in the fresh clone.
4. Twenty-seven local Git repositories across workspaces and common source roots,
   including three clones of this repository.
5. Git repositories/object stores on the deployment host.
6. Active container filesystem metadata and immutable image labels/history.
7. Registry index/manifest inspection.

No target object holder was found. Exact non-secret commands and results are in
`command-ledger.json`, `original-object-local.json`, and
`original-object-host-and-image.json`.

## Quality and safety baseline

The accessible baseline and reconstructed working tree were exercised independently
with the same Ruby 3.3.0/Bundler dependency set:

- Rails tests: both pass, 8 runs / 28 assertions / 0 failures / 0 errors.
- `bin/importmap audit`: both pass.
- production `assets:precompile` with `SECRET_KEY_BASE_DUMMY=1`: both pass.
- RuboCop: both retain exactly 134 offenses; no new or resolved offense identity.
- direct Brakeman: both retain exactly 3 warnings; no new or resolved warning
  fingerprint. Exit 3 reflects the frozen warnings, not a scanner failure.

The pre-staging full intended tree scan found zero forbidden paths, private-key
markers, known token prefixes, or literal secret assignments. Twenty-four
email/phone-like lines and five otherwise-unclassified high-entropy strings were
manually reviewed: they are static business/application destinations,
example-domain test fixtures, and public official-source URL slugs. No
customer/user/runtime record was found. Exact value material is intentionally not
repeated in these recovery notes.

## Evidence files

- `accessible-baseline.json` — SHA-256 manifest and classification for all 200
  baseline tracked files.
- `active-image-source.json` — selected image/config/layer proof and the sanitized
  source projection manifest.
- `baseline-vs-active-image.json` — exact path-by-path comparison and all
  differences/additions/exceptions.
- `recovery-exclusions.json` — complete allowlist boundary, exclusions, reasons,
  and unprovable metadata.
- `command-ledger.json` — sanitized read-only command record.
- `original-object-local.json` — accessible remote and local object-store probes.
- `original-object-host-and-image.json` — deployment-host/container/image probes.

A post-commit attachment generated outside this commit will record the exact recovery
commit, tree, parent, and SHA-256 manifest of every committed path.

## Scope and rollback

This recovery contains no analytics implementation and no unrelated cleanup.
The only source/content changes are exact bytes from the active image plus the
mandated removal of two forbidden tracked paths and this provenance evidence.

The prior production rollback anchor is
`f47c889dc28c3fc654b3644b7fbf4f8541967d5b`. It was observed only; no rollback
or deploy command was executed. Git rollback for this branch is to delete the
remote recovery branch or revert its single recovery commit. Main and production
remain outside this task's authority.
