# Padputer Aquamarine integration

This fork carries the nested Wayland initial-configure ordering fix used by the
Android display bridge. The fix is commit
`4406f00889dfb5ab3828c847dd0c46cb066ea5b9` on branch `padputer/0.12.1`; later
commits add only Padputer build/recovery integration. The latest strict device
gate must run without the Smithay
`PADPUTER_AQUAMARINE_CONFIGURE_COMPAT=1` diagnostic workaround before that
workaround is deleted.

- `fetch-builddeps.sh` recreates ignored Arch Linux ARM build-dependency archives.
- `build-aarch64.sh` creates an ignored, component-local `.build/aarch64/`
  sysroot and incremental CMake tree, verifies the public ABI, and writes the
  deterministic deployment library under the component-local ignored `out/`
  directory. Its required SHA-256 is
  `b035b011944a67a68718b61ba967a815361ce1843576397a88904dc8479e9f0b`.
- `BUILDDEPS_SHA256SUMS` and `OUTPUT_SHA256SUMS` pin all ignored inputs/output.
- `patches/initial-configure.patch` is an export for audit or upstream submission;
  the fix itself is committed in this fork.
