#!/bin/bash
# Gate mesin: setiap perintah ksu_susfs yang dipakai skrip/WebUI harus ada di source simonpunk.
# Pakai: tools/check_engine.sh <folder module> <main.c simonpunk>
set -euo pipefail
MODULE=$1 MAIN_C=$2

# Perintah SUSFS v1 yang masih ada di skrip SideX. Semua pemanggilnya dijaga cek versi (hanya v1) atau
# berupa fallback dengan pengganti v2 (hide_sus_mnts_for_all_procs -> _non_su_procs), jadi boleh tidak ada.
LEGACY="add_sus_mount add_try_umount hide_sus_mnts_for_all_procs set_android_data_root_path set_sdcard_root_path set_proc_cmdline sus_su umount_for_zygote_iso_service"

available=$(grep -oE 'strcmp\(argv\[1\], "[a-z_]+"\)' "$MAIN_C" | grep -oE '"[a-z_]+"' | tr -d '"' | sort -u)
# Hanya bentuk pemanggilan sungguhan: $SUSFS_BIN cmd / ${SUSFS_BIN} cmd, ksu_susfs cmd di awal perintah,
# ${k} cmd (WebUI) dan helper _add_sus_paths "<file>" cmd. Baris komentar dilewati.
used=$( {
	grep -rhE --include=*.sh '\$\{?SUSFS_BIN\}? +[a-z_]+|^[[:space:]]*ksu_susfs +[a-z_]+|_add_sus_paths "[^"]*" [a-z_]+' "$MODULE" | grep -vE '^[[:space:]]*#' \
		| grep -oE '\$\{?SUSFS_BIN\}? +[a-z_]+|^[[:space:]]*ksu_susfs +[a-z_]+|_add_sus_paths "[^"]*" [a-z_]+'
	grep -rhoE --include=*.js '\$\{k\} +[a-z_]+' "$MODULE"
} | awk '{print $NF}' | sort -u)

missing=0
for cmd in $used; do
	echo "$available" | grep -qx "$cmd" && continue
	case " $LEGACY " in *" $cmd "*) continue ;; esac
	echo "GAGAL: perintah ksu_susfs '$cmd' dipakai hybrid_susfs tapi tidak ada di SUSFS terbaru"
	missing=1
done
if [ $missing = 1 ]; then
	echo "Tunggu penyesuaian hybrid_susfs dengan SUSFS terbaru (simonpunk)."
	exit 1
fi
echo "Gate mesin lolos: $(echo "$used" | wc -w) perintah dipakai, semua ada atau termasuk legacy v1."
