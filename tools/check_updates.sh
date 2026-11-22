#!/bin/bash
# Cek pembaruan: hanya membandingkan dan menampilkan, tidak mengubah apa pun.
# SideX dan Brene: commit baru sejak commit di upstream.env (diambil manual bila berguna).
# simonpunk: mesin ikut otomatis saat build; di sini hanya dicek apakah lolos gate mesin.
set -uo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/upstream.env"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fetch() { git clone -q --bare --filter=blob:none --single-branch -b "$2" "$1" "$3" 2>/dev/null; }

report() { # nama repo cabang commit
	local dir=$TMP/$1
	echo "== $1 ($3)"
	if ! fetch "$2" "$3" "$dir"; then echo "   gagal mengambil $2"; return; fi
	local head=$(git -C "$dir" rev-parse HEAD)
	if [ "$head" = "$4" ]; then
		echo "   ✅ Tidak ada perubahan (${4:0:7})"
		return
	fi
	local n=$(git -C "$dir" rev-list --count "$4..$head" 2>/dev/null || echo "?")
	echo "   🆕 $n commit baru: ${4:0:7} → ${head:0:7}"
	git -C "$dir" log --format='      %cd  %s' --date=short "$4..$head" | head -20
	echo "   File berubah:"
	git -C "$dir" diff --stat=80 "$4" "$head" | tail -n 15 | sed 's/^/     /'
}

report SideX "$SIDEX_REPO" "$SIDEX_BRANCH" "$SIDEX_COMMIT"
echo
report Brene "$BRENE_REPO" "$BRENE_BRANCH" "$BRENE_COMMIT"
echo
echo "== simonpunk ($SUSFS_BRANCH) — mesin, otomatis setiap build"
if fetch "$SUSFS_REPO" "$SUSFS_BRANCH" "$TMP/susfs"; then
	head=$(git -C "$TMP/susfs" rev-parse HEAD)
	if [ "$head" = "${SUSFS_COMMIT:-}" ]; then
		echo "   ✅ Tidak ada perubahan (${SUSFS_COMMIT:0:7})"
	elif [ -n "${SUSFS_COMMIT:-}" ]; then
		n=$(git -C "$TMP/susfs" rev-list --count "$SUSFS_COMMIT..$head" 2>/dev/null || echo "?")
		echo "   🆕 $n commit baru sejak rilis terakhir: ${SUSFS_COMMIT:0:7} → ${head:0:7}"
		git -C "$TMP/susfs" log --format='      %cd  %s' --date=short "$SUSFS_COMMIT..$head" 2>/dev/null | head -20
	fi
	git -C "$TMP/susfs" log -1 --format='   Terbaru: %h  %cd  %s' --date=short
	git -C "$TMP/susfs" show HEAD:kernel_patches/include/linux/susfs.h | grep -oE 'SUSFS_VERSION "v[0-9.]+"' | sed 's/^/   /'
	git -C "$TMP/susfs" show HEAD:ksu_susfs/jni/main.c > "$TMP/main.c"
	"$ROOT/tools/check_engine.sh" "$ROOT/module" "$TMP/main.c" | sed 's/^/   /'
else
	echo "   gagal mengambil $SUSFS_REPO"
fi
