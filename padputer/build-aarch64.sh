#!/usr/bin/env bash
set -euo pipefail
component_root=$(cd "$(dirname "$0")/.." && pwd)
root=$(git -C "$component_root" rev-parse --show-superproject-working-tree)
[[ -n "$root" ]] || { echo "Aquamarine must be checked out as a Padputer submodule" >&2; exit 2; }
source_repo="$component_root"
expected_commit=eddb24439dc8b61fbc82fb015b7df47cd25a3606
runtime_manifest="$root/utils/install/hyprland-0.55.4-aarch64/SHA256SUMS"
build_manifest="$component_root/padputer/BUILDDEPS_SHA256SUMS"
output_manifest="$component_root/padputer/OUTPUT_SHA256SUMS"
out_dir="$component_root/out"
out="$out_dir/libaquamarine.so.0.12.1"

[[ -d "$root/downloads/android/aquamarine-0.12.1-builddeps" ]] || "$component_root/padputer/fetch-builddeps.sh"
[[ -d "$root/downloads/android/hyprland-0.55.4-aarch64" ]] || \
  "$root/utils/install/hyprland-0.55.4-aarch64/fetch.sh"
git -C "$source_repo" cat-file -e "$expected_commit^{commit}" || {
  echo "missing audited Aquamarine source commit $expected_commit" >&2
  exit 2
}
(cd "$root" && sha256sum -c "$runtime_manifest" "$build_manifest" >/dev/null)
command -v aarch64-linux-gnu-g++ >/dev/null
command -v cmake >/dev/null
[[ $(aarch64-linux-gnu-g++ -dumpfullversion) == 16.1.0 ]] || {
  echo "patched Aquamarine requires audited aarch64 GCC 16.1.0" >&2
  exit 2
}

cache="$component_root/.build/aarch64"
sysroot="$cache/sysroot"
source="$cache/source"
build="$cache/build"
toolchain="$cache/toolchain.cmake"
cache_key=$(printf '%s\n' "$expected_commit" "$(sha256sum "$runtime_manifest" "$build_manifest")" | sha256sum | cut -d' ' -f1)
if [[ ! -f "$cache/.key" || $(<"$cache/.key") != "$cache_key" ]]; then
  echo "Refreshing persistent Aquamarine aarch64 sysroot cache"
  rm -rf "$cache"
  mkdir -p "$sysroot" "$source" "$build"
  # Runtime packages provide the exact Hyprland ABI dependencies; the separate
  # build-dependency set is never added to clientroot by stage-hyprland.sh.
  for archive in "$root"/downloads/android/hyprland-0.55.4-aarch64/*.pkg.tar.* \
                 "$root"/downloads/android/aquamarine-0.12.1-builddeps/*.pkg.tar.*; do
    tar -xf "$archive" -C "$sysroot" --exclude=.BUILDINFO --exclude=.MTREE --exclude=.PKGINFO
  done
  # Arch's libm.so is an absolute linker script. A relative symlink prevents the
  # cross linker from accidentally resolving its /usr/lib entries on the host.
  rm -f "$sysroot/usr/lib/libm.so"
  ln -s libm.so.6 "$sysroot/usr/lib/libm.so"
  git -C "$source_repo" archive "$expected_commit" | tar -x -C "$source"
  printf '%s\n' "$cache_key" > "$cache/.key"
fi
mkdir -p "$out_dir"
cat > "$toolchain" <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
set(CMAKE_FIND_ROOT_PATH "$sysroot" /usr/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF
export PKG_CONFIG_SYSROOT_DIR="$sysroot"
export PKG_CONFIG_LIBDIR="$sysroot/usr/lib/pkgconfig:$sysroot/usr/share/pkgconfig"
export SOURCE_DATE_EPOCH=$(git -C "$source_repo" show -s --format=%ct "$expected_commit")
cxxflags="-include cmath -ffile-prefix-map=$source=/usr/src/aquamarine -ffile-prefix-map=$sysroot=/usr"
cmake -S "$source" -B "$build" \
  -DCMAKE_TOOLCHAIN_FILE="$toolchain" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_SKIP_RPATH=ON "-DCMAKE_CXX_FLAGS=$cxxflags" >/dev/null
cmake --build "$build" --target aquamarine -j"${JOBS:-4}" >/dev/null
cp -fL "$build/libaquamarine.so.0.12.1" "$out"
file "$out" | grep -q 'ARM aarch64'
readelf -d "$out" | grep -q 'Library soname: \[libaquamarine.so.11\]'
! readelf -d "$out" | grep -Eq '(RPATH|RUNPATH)'
! strings "$out" | grep -Fq "$cache"
# Rebuilding with the pinned cross toolchain may add compiler-generated weak
# helpers, but it must not add or remove any strong public Aquamarine symbol.
original="$sysroot/usr/lib/libaquamarine.so.0.12.1"
comm -3 \
  <(nm -D --defined-only "$original" | awk '$2 != "W" {print $2, $3}' | sort) \
  <(nm -D --defined-only "$out"      | awk '$2 != "W" {print $2, $3}' | sort) \
  > "$cache/strong-abi.diff"
[[ ! -s "$cache/strong-abi.diff" ]] || { cat "$cache/strong-abi.diff" >&2; exit 1; }
sha256sum "$out" > "$out.sha256"
(cd "$root" && sha256sum -c "$output_manifest" >/dev/null)
echo "Patched Aquamarine ready: $out"
cat "$out.sha256"
