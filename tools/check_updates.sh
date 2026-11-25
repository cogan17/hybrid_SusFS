#!/bin/bash
# Cek pembaruan: hanya membandingkan dan menampilkan, tidak mengubah apa pun.
# SideX dan Brene: commit baru sejak commit di upstream.env (diambil manual bila berguna). Commit yang
# sudah ditinjau tapi sengaja tidak diambil dicatat di tidak_diupdate.md dan tampil "⏭️ dilewati".
# simonpunk: mesin ikut otomatis saat build; di sini hanya dicek apakah lolos gate mesin.
set -uo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/upstream.env"
SKIP=$ROOT/tidak_diupdate.md
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fetch() { git clone -q --bare --filter=blob:none --single-branch -b "$2" "$1" "$3" 2>/dev/null; }

# skip_reason <sumber> <hash penuh>: alasan dari tidak_diupdate.md, kosong bila tidak tercatat
skip_reason() {
	[ -f "$SKIP" ] || return 0
	awk -F'|' -v s="$1" -v h="$2" '
		function trim(x) { gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
		trim($2) == s && trim($3) == h { print trim($5); exit }
	' "$SKIP"
}

# skip_count <sumber>: jumlah baris tercatat untuk sumber ini (riwayat keputusan)
skip_count() {
	[ -f "$SKIP" ] || { echo 0; return; }
	awk -F'|' -v s="$1" '
		function trim(x) { gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
		trim($2) == s && trim($3) ~ /^[0-9a-f]{40}$/ { n++ }
		END { print n + 0 }
	' "$SKIP"
}

report() { # nama repo cabang commit
	local dir=$TMP/$1 h subj r new=0 skipped=0
	echo "== $1 ($3)"
	if ! fetch "$2" "$3" "$dir"; then echo "   gagal mengambil $2"; return; fi
	local head
	head=$(git -C "$dir" rev-parse HEAD)
	if [ "$head" = "$4" ]; then
		echo "   ✅ Tidak ada perubahan (${4:0:7})"
	else
		while read -r h subj; do
			r=$(skip_reason "$1" "$h")
			if [ -n "$r" ]; then
				echo "      ⏭️ ${h:0:7}  $subj — dilewati: $r"
				skipped=$((skipped + 1))
			else
				echo "      🆕 ${h:0:7}  $subj"
				new=$((new + 1))
			fi
		done < <(git -C "$dir" log --format='%H %s' "$4..$head" 2>/dev/null)
		if [ "$new" -eq 0 ]; then
			echo "   ✅ Tidak ada pembaruan yang perlu ditinjau ($skipped dilewati): ${4:0:7} → ${head:0:7}"
		else
			echo "   🆕 $new commit belum ditinjau, $skipped dilewati: ${4:0:7} → ${head:0:7}"
			echo "   File berubah:"
			git -C "$dir" diff --stat=80 "$4" "$head" | tail -n 15 | sed 's/^/     /'
		fi
	fi
	echo "   Riwayat dilewati di tidak_diupdate.md: $(skip_count "$1") commit"
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
