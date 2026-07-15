# Padputer Aquamarine integration

This fork carries the nested Wayland initial-configure ordering fix used by the
Android display bridge. The audited source state is commit
`4406f00889dfb5ab3828c847dd0c46cb066ea5b9` on branch `padputer/0.12.1`.

- `fetch-builddeps.sh` recreates ignored Arch Linux ARM build-dependency archives.
- `build-aarch64.sh` creates an ignored, component-local `.build/aarch64/`
  sysroot and incremental CMake tree, verifies the public ABI, and writes the
  deterministic deployment library under the component-local ignored `out/`
  directory.
- `BUILDDEPS_SHA256SUMS` and `OUTPUT_SHA256SUMS` pin all ignored inputs/output.
- `patches/initial-configure.patch` is an export for audit or upstream submission;
  the fix itself is committed in this fork.
