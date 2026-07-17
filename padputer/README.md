# Padputer Aquamarine integration

This fork carries the nested Wayland fixes used by the Android display bridge.
Commit `cd3fe558399fbda0c785ead7620a5965b6dc4001` handles the fixed
launcher-validated DRM fd when SELinux denies metadata ioctls after domain drop.
Commit `eddb24439dc8b61fbc82fb015b7df47cd25a3606` consumes an early output
buffer without attaching it, then schedules a fresh frame only after the initial
`xdg_surface.configure` ACK. Strict 300-frame device validation passed after the
old Smithay compatibility exception was deleted. Commit
`74991e0cd14e451290d1be3cf566f836f5c240e9` preserves nested pointer axis
source, high-resolution/discrete values, direction and stop events across the
Aquamarine input abstraction. Commit `33249e6` preserves the nested backend's
unbounded cursor-plane sentinel; Hyprland explicitly maps it to the current
cursor image size. Commits `04a9c44` and `074279a` add bounded `AQ_TRACE`
diagnostics for nested cursor buffer/enter ordering and enter-target identity
without changing protocol behavior.

- `fetch-builddeps.sh` recreates ignored Arch Linux ARM build-dependency archives.
- `build-aarch64.sh` creates an ignored, component-local `.build/aarch64/`
  sysroot and incremental CMake tree, verifies the public ABI, and writes the
  deterministic deployment library under the component-local ignored `out/`
  directory. Its required SHA-256 is
  `d6dba1fcf0c7178d306ae77ee1146df4bb771ae368ccba71acf52c55e4bfa62e`.
- `BUILDDEPS_SHA256SUMS` and `OUTPUT_SHA256SUMS` pin all ignored inputs/output.
- `patches/initial-configure.patch` is an export for audit or upstream submission;
  the fix itself is committed in this fork.
