#!/system/bin/sh
# Hapus hanya yang milik modul ini, lalu pulihkan keadaan sebelum instalasi.
MODDIR=${0%/*}
BIN=/data/adb/ksu/bin

# Kepemilikan dicek per path: ksu_susfs = binary kita (hash cocok), susfs = symlink kita (-> ksu_susfs).
# Path yang sudah jadi milik komponen lain dibiarkan, dan cadangannya tidak dipulihkan.
note() { mkdir -p /data/adb/hybrid_susfs && echo "$*" >> /data/adb/hybrid_susfs/uninstall.log; }
# restore <nama>: cadangan hanya ke path yang kosong, lewat file sementara + rename (tidak menembus symlink)
restore() {
	src=$MODDIR/.bin_backup/$1
	[ -e $src ] || [ -L $src ] || return 0
	if [ -e $BIN/$1 ] || [ -L $BIN/$1 ]; then note "$1 dipakai komponen lain, cadangan tidak dipulihkan"; return 0; fi
	cp -P $src $BIN/.$1.restore && mv -f $BIN/.$1.restore $BIN/$1 || { rm -f $BIN/.$1.restore; note "gagal memulihkan $1"; }
}
own_bin=0; own_link=0
[ -f $MODDIR/.installed_bin.sha256 ] && [ -f $BIN/ksu_susfs ] && [ ! -L $BIN/ksu_susfs ] && \
	[ "$(sha256sum $BIN/ksu_susfs | cut -d' ' -f1)" = "$(cat $MODDIR/.installed_bin.sha256)" ] && own_bin=1
[ -L $BIN/susfs ] && [ "$(readlink $BIN/susfs)" = "$BIN/ksu_susfs" ] && own_link=1

if [ $own_bin = 1 ]; then
	rm -f $BIN/ksu_susfs && restore ksu_susfs
	if [ $own_link = 1 ]; then rm -f $BIN/susfs && restore susfs
	else note "susfs bukan symlink hybrid_susfs, dibiarkan"; fi
else
	note "ksu_susfs bukan milik hybrid_susfs lagi, ksu_susfs dan susfs dibiarkan"
fi

# Modul SUSFS lain yang dimatikan saat install diaktifkan lagi
[ -f $MODDIR/.disabled_by_hybrid ] && while read -r m; do
	[ -n "$m" ] && [ "$(cat /data/adb/modules/$m/disable 2>/dev/null)" = hybrid_susfs ] && rm -f /data/adb/modules/$m/disable
done < $MODDIR/.disabled_by_hybrid

rm -rf /data/adb/ksu/hybrid_susfs
