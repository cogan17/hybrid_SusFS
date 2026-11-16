#!/system/bin/sh
# Impor backup config dari WebUI: ekstrak di folder sementara, ambil hanya file yang dikenal
# (file biasa, bukan symlink/hardlink), saring config.sh, baru ganti config lama.
# Pakai: config_import.sh <arsip.tar.gz>
MODDIR=${0%/*}
PERSISTENT_DIR=/data/adb/hybrid_susfs
. $MODDIR/utils.sh
ALLOW="config.sh sus_path.txt sus_path_loop.txt sus_maps.txt sus_mount.txt try_umount.txt sus_open_redirect.txt legit_mounts.txt sus_kstat_statically.json"

STAGE=$(mktemp -d /data/adb/ksu/hybrid_susfs/import.XXXXXX) || exit 1
trap 'rm -rf "$STAGE"' EXIT
tar -xzf "$1" -C "$STAGE" || { echo "arsip tidak bisa dibuka" >&2; exit 1; }
[ -f "$STAGE/config.sh" ] && [ ! -L "$STAGE/config.sh" ] || { echo "config.sh tidak ada" >&2; exit 1; }

for f in $ALLOW; do
	src=$STAGE/$f
	[ -f "$src" ] && [ ! -L "$src" ] && [ "$(stat -c %h "$src")" = 1 ] || continue
	if [ "$f" = config.sh ]; then
		grep -E "$HYBRID_CFG_RE" "$src" > "$src.ok"
		src=$src.ok
	fi
	cat "$src" > "$PERSISTENT_DIR/$f.new" && mv -f "$PERSISTENT_DIR/$f.new" "$PERSISTENT_DIR/$f"
done
# Key yang tidak ada di backup (mis. backup versi lama) diisi dari default modul
[ -f $MODDIR/config.default.sh ] && grep -E "$HYBRID_CFG_RE" $MODDIR/config.default.sh | while IFS= read -r line; do
	grep -q "^${line%%=*}=" $PERSISTENT_DIR/config.sh || echo "$line" >> $PERSISTENT_DIR/config.sh
done
echo ok
