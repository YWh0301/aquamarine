# Padputer Aquamarine integration

This fork carries the nested Wayland fixes used by the Android display bridge.
Commit `cd3fe558399fbda0c785ead7620a5965b6dc4001` handles the fixed
launcher-validated DRM fd when SELinux denies metadata ioctls after domain drop.
Commit `eddb24439dc8b61fbc82fb015b7df47cd25a3606` consumes an early output
buffer without attaching it, then schedules a fresh frame only after the initial
`xdg_surface.configure` ACK. Strict 300-frame device validation passed after the
old Smithay compatibility exception was deleted.

- `fetch-builddeps.sh` recreates ignored Arch Linux ARM build-dependency archives.
- `build-aarch64.sh` creates an ignored, component-local `.build/aarch64/`
  sysroot and incremental CMake tree, verifies the public ABI, and writes the
  deterministic deployment library under the component-local ignored `out/`
  directory. Its required SHA-256 is
  `ab5542cc6f590a735c02db6e50e53c80f8909e822ad3549abb3c88e3636c3f73`.
- `BUILDDEPS_SHA256SUMS` and `OUTPUT_SHA256SUMS` pin all ignored inputs/output.
- `patches/initial-configure.patch` is an export for audit or upstream submission;
  the fix itself is committed in this fork.
