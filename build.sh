#!/bin/bash
# Build Hybrid SusFS: compile ksu_susfs dari source simonpunk, lalu kemas ZIP modul.
# Pakai: NDK=/path/android-ndk ./build.sh [cabang-susfs]   (default gki-android14-6.1)
set -euo pipefail
BRANCH=${1:-gki-android14-6.1}
ROOT=$(cd "$(dirname "$0")" && pwd)
WORK=$ROOT/out/work
: "${NDK:?set NDK ke folder Android NDK}"

rm -rf "$WORK" && mkdir -p "$WORK"
git clone -q --depth 1 -b "$BRANCH" https://gitlab.com/simonpunk/susfs4ksu.git "$WORK/susfs4ksu"
SUSFS_COMMIT=$(git -C "$WORK/susfs4ksu" rev-parse --short=8 HEAD)
SUSFS_VERSION=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$WORK/susfs4ksu/kernel_patches/include/linux/susfs.h" | head -1)

(cd "$WORK/susfs4ksu/ksu_susfs" && "$NDK/ndk-build" -s)

cp -r "$ROOT/module" "$WORK/module"
mkdir -p "$WORK/module/tools"
cp "$WORK/susfs4ksu/ksu_susfs/libs/arm64-v8a/ksu_susfs" "$WORK/module/tools/ksu_susfs_arm64"

VERSION=$(grep '^version=' "$ROOT/module/module.prop" | cut -d= -f2)
ZIP=$ROOT/out/Hybrid_SusFS_${VERSION}.zip
rm -f "$ZIP"
(cd "$WORK/module" && zip -qr9 "$ZIP" .)
echo "ZIP      : $ZIP"
echo "SUSFS    : $SUSFS_VERSION ($BRANCH @ $SUSFS_COMMIT)"
echo "SHA256   : $(sha256sum "$ZIP" | cut -d' ' -f1)"
