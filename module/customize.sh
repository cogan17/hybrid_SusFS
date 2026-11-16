#!/bin/sh
PATH=/data/adb/ksu/bin:$PATH
KSU_BIN=/data/adb/ksu/bin/ksud
DEST_BIN_DIR=/data/adb/ksu/bin
SUSFS_BIN=$DEST_BIN_DIR/ksu_susfs
MODULE_UPDATE_DIR=/data/adb/modules_update/hybrid_susfs
PERSISTENT_DIR=/data/adb/hybrid_susfs
tmpfolder=/data/adb/ksu/hybrid_susfs

ui_print " "
ui_print "  hybrid_susfs $(grep '^version=' $MODPATH/module.prop | cut -d= -f2)"
ui_print " "

[ -z "$KSU" ] && abort '[!] Hanya untuk KernelSU / only for KernelSU'
[ "$ARCH" != "arm64" ] && abort '[!] Hanya arm64 / arm64 only'
[ -d $DEST_BIN_DIR ] || abort "[!] $DEST_BIN_DIR tidak ada / not found"

# Mesin: ksu_susfs hasil compile dari source simonpunk (tools/ksu_susfs_arm64)
cp -f $MODPATH/tools/ksu_susfs_arm64 $SUSFS_BIN
chmod 755 $SUSFS_BIN
ln -sf $SUSFS_BIN $DEST_BIN_DIR/susfs # nama yang dipakai skrip Brene
chmod 755 $MODPATH/inotify.sh $MODPATH/remove_ksu_directory.sh

SUSFS_VERSION_RAW="$($SUSFS_BIN show version 2>/dev/null)"
case "$SUSFS_VERSION_RAW" in
	v2.*) ui_print "[-] SUSFS kernel: $SUSFS_VERSION_RAW ($($SUSFS_BIN show variant 2>/dev/null))" ;;
	*) abort "[!] Kernel tanpa SUSFS v2 / kernel without SUSFS v2 ($SUSFS_VERSION_RAW)" ;;
esac

# Modul SUSFS lain bentrok (binary dan aturan ganda): matikan
for m in susfs4ksu brene susfs_manager; do
	[ -d /data/adb/modules/$m ] && [ ! -f /data/adb/modules/$m/disable ] && {
		touch /data/adb/modules/$m/disable
		ui_print "[-] Modul $m dimatikan / disabled"
	}
done

hybrid_config_check() {
	ui_print " "
	ui_print "  Config lama ditemukan / old config found"
	ui_print "  Vol + : reset ke default"
	ui_print "  Vol - : simpan config (otomatis 10 detik)"
	ui_print " "
	local start_time=$(date +%s)
	while [ $(( $(date +%s) - start_time )) -lt 10 ]; do
		local key_event=$(timeout 0.5 getevent -l 2>/dev/null)
		if echo "$key_event" | grep -q "KEY_VOLUMEUP"; then
			ui_print "[-] Reset ke default"
			rm -rf $PERSISTENT_DIR
			return
		elif echo "$key_event" | grep -q "KEY_VOLUMEDOWN"; then
			break
		fi
	done
	ui_print "[-] Config disimpan / kept"
}
[ -d $PERSISTENT_DIR ] && hybrid_config_check

ui_print "[-] Menyiapkan $PERSISTENT_DIR"
mkdir -p $PERSISTENT_DIR
cp $MODPATH/config.sh $MODPATH/config.default.sh
files="sus_mount.txt try_umount.txt sus_path.txt sus_path_loop.txt sus_maps.txt sus_open_redirect.txt legit_mounts.txt sus_kstat_statically.json config.sh"
for i in $files; do
	if [ ! -f $PERSISTENT_DIR/$i ]; then
		cat $MODPATH/$i > $PERSISTENT_DIR/$i
	elif [ "$i" = "config.sh" ]; then
		# Pastikan diakhiri newline, lalu tambah key baru saja
		[ -s "$PERSISTENT_DIR/$i" ] && [ "$(tail -c1 "$PERSISTENT_DIR/$i" | xxd -p)" != "0a" ] && echo "" >> "$PERSISTENT_DIR/$i"
		while IFS= read -r line; do
			case "$line" in ""|\#*) continue ;; esac
			key=$(echo "$line" | cut -d'=' -f1)
			grep -q "^${key}=" "$PERSISTENT_DIR/$i" || echo "$line" >> "$PERSISTENT_DIR/$i"
		done < "$MODPATH/$i"
	fi
	rm $MODPATH/$i
done

# Brene: tanggal untuk spoof security patch, folder file palsu
. $MODPATH/brene.sh
brene_update_config_date
rm -rf $PERSISTENT_DIR/fake_files
mkdir -p $PERSISTENT_DIR/fake_files

mkdir -p $tmpfolder/logs
for f in susfs_stats.txt susfs_stats1.txt; do
	[ -f $tmpfolder/$f ] || printf 'sus_map=0\nsus_path=0\nsus_mount=0\ntry_umount=0\n' > $tmpfolder/$f
done
touch $tmpfolder/logs/susfs_active

# WebUI bisa dibuka tanpa reboot
sed -i "s/^description=.*/description=status: ✅ SuS ඞ/" $MODPATH/module.prop
cp -r $MODULE_UPDATE_DIR /data/adb/modules 2>/dev/null

ui_print " "
ui_print "  Selesai. Reboot untuk mengaktifkan."
ui_print "  Done. Reboot to activate."
ui_print " "

rm -rf $MODPATH/tools
rm $MODPATH/customize.sh
