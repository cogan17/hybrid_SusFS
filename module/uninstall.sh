#!/system/bin/sh
# Hapus hanya yang milik modul ini, lalu pulihkan keadaan sebelum instalasi.
MODDIR=${0%/*}
BIN=/data/adb/ksu/bin

# Binary: hapus hanya bila masih milik kita (modul SUSFS lain bisa sudah menggantinya), lalu kembalikan cadangan
if [ -f $MODDIR/.installed_bin.sha256 ] && [ ! -L $BIN/ksu_susfs ] && \
	[ "$(sha256sum $BIN/ksu_susfs 2>/dev/null | cut -d' ' -f1)" = "$(cat $MODDIR/.installed_bin.sha256)" ]; then
	rm -f $BIN/ksu_susfs
	[ "$(readlink $BIN/susfs)" = "$BIN/ksu_susfs" ] && rm -f $BIN/susfs
	for b in ksu_susfs susfs; do
		[ -e $MODDIR/.bin_backup/$b ] || [ -L $MODDIR/.bin_backup/$b ] && cp -P $MODDIR/.bin_backup/$b $BIN/$b
	done
fi

# Modul SUSFS lain yang dimatikan saat install diaktifkan lagi
[ -f $MODDIR/.disabled_by_hybrid ] && while read -r m; do
	[ -n "$m" ] && rm -f /data/adb/modules/$m/disable
done < $MODDIR/.disabled_by_hybrid

# Prop persist yang kita tulis (Disable child process restrictions)
[ -f /data/adb/hybrid_susfs/.phantom_procs_set ] && \
	resetprop -p -d persist.sys.fflag.override.settings_enable_monitor_phantom_procs && rm -f /data/adb/hybrid_susfs/.phantom_procs_set

rm -rf /data/adb/ksu/hybrid_susfs
