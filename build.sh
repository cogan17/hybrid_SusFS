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
# Opsional: pakai commit engine tertentu (mundur ke engine yang terbukti bagus bila simonpunk bermasalah);
# kosong = cabang terbaru. Commit wajib tercapai dari cabang, jadi bukan commit asing/fork.
: "${ENGINE_COMMIT:=}"
if [ -n "$ENGINE_COMMIT" ]; then
	echo "$ENGINE_COMMIT" | grep -qE '^[0-9a-fA-F]{7,40}$' || { echo "GAGAL: ENGINE_COMMIT harus hash commit (7-40 hex), bukan '$ENGINE_COMMIT'"; exit 1; }
	git clone -q --filter=blob:none -b "$SUSFS_BRANCH" "$SUSFS_REPO" "$WORK/susfs4ksu"
	git -C "$WORK/susfs4ksu" merge-base --is-ancestor "$ENGINE_COMMIT" HEAD 2>/dev/null \
		|| { echo "GAGAL: commit $ENGINE_COMMIT tidak ada di cabang $SUSFS_BRANCH (simonpunk)"; exit 1; }
	git -C "$WORK/susfs4ksu" checkout -q --detach "$ENGINE_COMMIT"
else
	git clone -q --depth 1 -b "$SUSFS_BRANCH" "$SUSFS_REPO" "$WORK/susfs4ksu"
fi
SUSFS_COMMIT=$(git -C "$WORK/susfs4ksu" rev-parse HEAD)
SUSFS_VERSION=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$WORK/susfs4ksu/kernel_patches/include/linux/susfs.h" | head -1)

"$ROOT/tools/check_engine.sh" "$ROOT/module" "$WORK/susfs4ksu/ksu_susfs/jni/main.c"

# Android 10+ (GKI); bawaan upstream "latest" = API terbaru saja
(cd "$WORK/susfs4ksu/ksu_susfs" && "$NDK/ndk-build" -s APP_PLATFORM=android-29)

cp -r "$ROOT/module" "$WORK/module"
mkdir -p "$WORK/module/tools"
cp "$WORK/susfs4ksu/ksu_susfs/libs/arm64-v8a/ksu_susfs" "$WORK/module/tools/ksu_susfs_arm64"

# Identitas build: ikut di log Send Logs (post-fs-data menyalinnya) supaya log bisa dicocokkan dengan ZIP
REPO_COMMIT=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo tidak-diketahui)
[ -z "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ] || REPO_COMMIT="$REPO_COMMIT+perubahan-lokal"
{
	echo "hybrid_susfs $VERSION (versionCode $CODE)"
	echo "repo: $REPO_COMMIT"
	echo "susfs: $SUSFS_VERSION ($SUSFS_BRANCH @ $SUSFS_COMMIT)"
	echo "sha256:"
	(cd "$WORK/module" && find . -type f ! -name MANIFEST.txt | sort | xargs sha256sum)
} > "$WORK/module/MANIFEST.txt"

ZIP=$ROOT/out/hybrid_susfs_${VERSION}.zip
rm -f "$ZIP"
(cd "$WORK/module" && zip -qr9 "$ZIP" .)
# build.env dibaca workflow dengan '. out/build.env': setiap nilai dikutip (ada spasi dan tanda kurung)
{
	printf "ZIP='%s'\n" "$ZIP"
	printf "VERSION='%s'\n" "$VERSION"
	printf "SUSFS='%s'\n" "$SUSFS_VERSION ($SUSFS_BRANCH @ $SUSFS_COMMIT)"
	printf "SHA256='%s'\n" "$(sha256sum "$ZIP" | cut -d' ' -f1)"
} | tee "$ROOT/out/build.env"
