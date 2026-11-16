#!/bin/bash
# Gate mesin: setiap perintah ksu_susfs yang dipakai skrip/WebUI harus ada di source simonpunk.
# Pakai: tools/check_engine.sh <folder module> <main.c simonpunk>
set -euo pipefail
MODULE=$1 MAIN_C=$2

# Perintah SUSFS v1 yang masih ada di skrip SideX; selalu dijaga cek versi/fallback, jadi boleh tidak ada.
LEGACY="add_sus_mount add_try_umount hide_sus_mnts_for_all_procs set_android_data_root_path set_sdcard_root_path set_proc_cmdline sus_su umount_for_zygote_iso_service"

available=$(grep -oE 'strcmp\(argv\[1\], "[a-z_]+"\)' "$MAIN_C" | grep -oE '"[a-z_]+"' | tr -d '"' | sort -u)
used=$(grep -rhE '(\$\{?SUSFS_BIN\}?|ksu_susfs|\$\{k\}) +[a-z_]+' --include=*.sh --include=*.js "$MODULE" \
	| grep -vE '^\s*#' | grep -oE '(\$\{?SUSFS_BIN\}?|ksu_susfs|\$\{k\}) +[a-z_]+' | awk '{print $NF}' | sort -u)

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
