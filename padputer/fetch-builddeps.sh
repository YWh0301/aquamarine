#!/usr/bin/env bash
set -euo pipefail
component_root=$(cd "$(dirname "$0")/.." && pwd)
root=$(git -C "$component_root" rev-parse --show-superproject-working-tree)
[[ -n "$root" ]] || { echo "Aquamarine must be checked out as a Padputer submodule" >&2; exit 2; }
dest="$root/downloads/android/aquamarine-0.12.1-builddeps"
mkdir -p "$dest"
base=https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/aarch64
files=(
  hwdata-0.409-1-any.pkg.tar.xz
  libdisplay-info-0.3.0-1-aarch64.pkg.tar.xz
  libdrm-2.4.134-1-aarch64.pkg.tar.xz
  libffi-3.7.1-1-aarch64.pkg.tar.xz
  libglvnd-1.7.0-3-aarch64.pkg.tar.xz
  'mesa-1:26.1.4-1-aarch64.pkg.tar.xz'
  pixman-0.46.4-1.1-aarch64.pkg.tar.xz
  systemd-libs-261.1-1-aarch64.pkg.tar.xz
  wayland-1.25.0-1-aarch64.pkg.tar.xz
)
for file in "${files[@]}"; do
  [[ -f "$dest/$file" ]] && continue
  escaped=${file//:/%3A}
  curl -fL --retry 3 -o "$dest/$file.part" "$base/core/$escaped" ||
    curl -fL --retry 3 -o "$dest/$file.part" "$base/extra/$escaped"
  mv "$dest/$file.part" "$dest/$file"
done
(cd "$root" && sha256sum -c "$component_root/padputer/BUILDDEPS_SHA256SUMS")
