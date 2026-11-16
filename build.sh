#!/bin/bash
# Build hybrid_susfs: compile ksu_susfs dari source simonpunk terbaru, cek gate, kemas ZIP modul.
# Pakai: NDK=/path/android-ndk ./build.sh
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
. "$ROOT/upstream.env"
WORK=$ROOT/out/work
: "${NDK:?set NDK ke folder Android NDK}"

# Versi modul, update.json dan CHANGELOG harus sama
VERSION=$(grep '^version=' "$ROOT/module/module.prop" | cut -d= -f2)
CODE=$(grep '^versionCode=' "$ROOT/module/module.prop" | cut -d= -f2)
grep -q "\"version\": \"$VERSION\"" "$ROOT/update.json" && grep -q "\"versionCode\": $CODE," "$ROOT/update.json" \
	|| { echo "GAGAL: update.json tidak sama dengan module.prop ($VERSION / $CODE)"; exit 1; }
grep -qE "^## $VERSION( |$)" "$ROOT/CHANGELOG.md" || { echo "GAGAL: CHANGELOG.md belum punya bagian $VERSION"; exit 1; }

rm -rf "$WORK" && mkdir -p "$WORK"
git clone -q --depth 1 -b "$SUSFS_BRANCH" "$SUSFS_REPO" "$WORK/susfs4ksu"
SUSFS_COMMIT=$(git -C "$WORK/susfs4ksu" rev-parse --short=8 HEAD)
SUSFS_VERSION=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$WORK/susfs4ksu/kernel_patches/include/linux/susfs.h" | head -1)

"$ROOT/tools/check_engine.sh" "$ROOT/module" "$WORK/susfs4ksu/ksu_susfs/jni/main.c"

# Android 10+ (GKI); bawaan upstream "latest" = API terbaru saja
(cd "$WORK/susfs4ksu/ksu_susfs" && "$NDK/ndk-build" -s APP_PLATFORM=android-29)

cp -r "$ROOT/module" "$WORK/module"
mkdir -p "$WORK/module/tools"
cp "$WORK/susfs4ksu/ksu_susfs/libs/arm64-v8a/ksu_susfs" "$WORK/module/tools/ksu_susfs_arm64"

ZIP=$ROOT/out/hybrid_susfs_${VERSION}.zip
rm -f "$ZIP"
(cd "$WORK/module" && zip -qr9 "$ZIP" .)
{
	echo "ZIP=$ZIP"
	echo "VERSION=$VERSION"
	echo "SUSFS=$SUSFS_VERSION ($SUSFS_BRANCH @ $SUSFS_COMMIT)"
	echo "SHA256=$(sha256sum "$ZIP" | cut -d' ' -f1)"
} | tee "$ROOT/out/build.env"
