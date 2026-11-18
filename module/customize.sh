#!/bin/sh
PATH=/data/adb/ksu/bin:$PATH
KSU_BIN=/data/adb/ksu/bin/ksud
DEST_BIN_DIR=/data/adb/ksu/bin
SUSFS_BIN=$DEST_BIN_DIR/ksu_susfs
PERSISTENT_DIR=/data/adb/hybrid_susfs
tmpfolder=/data/adb/ksu/hybrid_susfs

ui_print " "
ui_print "  hybrid_susfs $(grep '^version=' $MODPATH/module.prop | cut -d= -f2)"
ui_print " "

[ -z "$KSU" ] && abort '[!] Hanya untuk KernelSU / only for KernelSU'
[ "$ARCH" != "arm64" ] && abort '[!] Hanya arm64 / arm64 only'
[ -d $DEST_BIN_DIR ] || abort "[!] $DEST_BIN_DIR tidak ada / not found"

# Mesin: ksu_susfs hasil compile dari source simonpunk (tools/ksu_susfs_arm64).
# Cek kernel dulu dari binary di ZIP, supaya binary modul lain tidak tertimpa bila install batal.
NEW_BIN=$MODPATH/tools/ksu_susfs_arm64
chmod 755 $NEW_BIN
SUSFS_VERSION_RAW="$($NEW_BIN show version 2>/dev/null)"
case "$SUSFS_VERSION_RAW" in
	v2.*) ui_print "[-] SUSFS kernel: $SUSFS_VERSION_RAW ($($NEW_BIN show variant 2>/dev/null))" ;;
	*) abort "[!] Kernel tanpa SUSFS v2 / kernel without SUSFS v2 ($SUSFS_VERSION_RAW)" ;;
esac

# Cadangkan ksu_susfs/susfs milik modul lain apa adanya (symlink tetap symlink) untuk dipulihkan saat uninstall.
# Saat update modul ini, binary yang ada adalah milik kita: cadangan dari instalasi pertama yang dibawa.
# Cadangan wajib berhasil sebelum ada yang diubah.
LIVE_DIR=/data/adb/modules/hybrid_susfs
BAK=$MODPATH/.bin_backup
mkdir -p $BAK || abort "[!] Gagal membuat cadangan / backup failed"
if [ -f $LIVE_DIR/.installed_bin.sha256 ] && [ "$(sha256sum $SUSFS_BIN 2>/dev/null | cut -d' ' -f1)" = "$(cat $LIVE_DIR/.installed_bin.sha256)" ]; then
	for b in $LIVE_DIR/.bin_backup/ksu_susfs $LIVE_DIR/.bin_backup/susfs; do
		if [ -e $b ] || [ -L $b ]; then cp -P $b $BAK/ || abort "[!] Gagal membawa cadangan / backup failed"; fi
	done
	if [ -f $LIVE_DIR/.disabled_by_hybrid ]; then cp -f $LIVE_DIR/.disabled_by_hybrid $MODPATH/ || abort "[!] Gagal membawa cadangan / backup failed"; fi
else
	for b in ksu_susfs susfs; do
		if [ -e $DEST_BIN_DIR/$b ] || [ -L $DEST_BIN_DIR/$b ]; then
			cp -P $DEST_BIN_DIR/$b $BAK/$b || abort "[!] Gagal mencadangkan $b / backup failed"
		fi
	done
fi

# Snapshot transaksi: keadaan ksu_susfs/susfs TEPAT sebelum pemasangan ini (berbeda dengan cadangan uninstall
# di atas). Bila langkah mana pun gagal, keadaan ini yang dikembalikan persis, termasuk "tidak ada".
# Disimpan di luar folder update (yang dihapus manager bila install gagal), supaya tetap ada untuk pemulihan manual
TXN=/data/adb/hybrid_susfs.txn
# Snapshot dari install yang gagal sebelumnya adalah bahan pemulihan: jangan dihapus diam-diam
{ [ -e $TXN ] || [ -L $TXN ]; } && abort "[!] Ada snapshot pemulihan dari install yang gagal: $TXN. Salin isinya ke $DEST_BIN_DIR bila binary hilang, lalu hapus folder itu dan pasang ulang / recovery snapshot exists, check it first"
mkdir -p $TXN || abort "[!] Gagal membuat snapshot / snapshot failed"
for b in ksu_susfs susfs; do
	if [ -e $DEST_BIN_DIR/$b ] || [ -L $DEST_BIN_DIR/$b ]; then
		cp -P $DEST_BIN_DIR/$b $TXN/$b || abort "[!] Gagal membuat snapshot $b / snapshot failed"
	fi
done
txn_rollback() {
	local ok=1 b d
	rm -f $DEST_BIN_DIR/.ksu_susfs.new
	for b in ksu_susfs susfs; do
		d=$DEST_BIN_DIR/$b
		rm -f $d || ok=0
		if [ -e $TXN/$b ] || [ -L $TXN/$b ]; then
			cp -P $TXN/$b $d.restore && mv -f $d.restore $d || { rm -f $d.restore; ok=0; }
		fi
		# Verifikasi: symlink -> target sama, file -> isi sama, dulu tidak ada -> tetap tidak ada
		if [ -L $TXN/$b ]; then [ "$(readlink $d)" = "$(readlink $TXN/$b)" ] || ok=0
		elif [ -e $TXN/$b ]; then [ -f $d ] && [ ! -L $d ] && cmp -s $TXN/$b $d || ok=0
		else [ ! -e $d ] && [ ! -L $d ] || ok=0
		fi
	done
	[ $ok = 1 ] && { rm -rf $TXN; abort "[!] Gagal memasang ksu_susfs, keadaan sebelumnya dikembalikan / install failed, previous state restored"; }
	# Pemulihan tidak lengkap: snapshot dibiarkan di $TXN untuk dipulihkan manual
	abort "[!] Gagal memasang ksu_susfs DAN pemulihan tidak lengkap. Snapshot: $TXN (salin ke $DEST_BIN_DIR) / install AND restore failed"
}

# Binary baru disiapkan di folder yang sama lalu ditukar dengan mv: rename tidak menulis menembus symlink
# modul lain (mis. Brene: ksu_susfs -> susfs) dan binary lama tetap utuh sampai pertukaran berhasil.
cp $NEW_BIN $DEST_BIN_DIR/.ksu_susfs.new && chmod 755 $DEST_BIN_DIR/.ksu_susfs.new && \
	mv -f $DEST_BIN_DIR/.ksu_susfs.new $SUSFS_BIN || txn_rollback
rm -f $DEST_BIN_DIR/susfs && ln -s $SUSFS_BIN $DEST_BIN_DIR/susfs || txn_rollback # nama yang dipakai skrip Brene
rm -rf $TXN
sha256sum $SUSFS_BIN | cut -d' ' -f1 > $MODPATH/.installed_bin.sha256
chmod 755 $MODPATH/inotify.sh

# Modul SUSFS lain bentrok (binary dan aturan ganda): matikan dengan penanda, dicatat untuk uninstall.
# Uninstall hanya mengaktifkan lagi bila file disable masih berisi penanda kita (bukan pilihan pemilik).
for m in susfs4ksu brene susfs_manager; do
	[ -d /data/adb/modules/$m ] && [ ! -f /data/adb/modules/$m/disable ] && {
		echo hybrid_susfs > /data/adb/modules/$m/disable
		echo $m >> $MODPATH/.disabled_by_hybrid
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
# Kegagalan menyiapkan config harus terlihat (abort), bukan dilaporkan sukses dengan config setengah jadi.
mkdir -p $PERSISTENT_DIR || abort "[!] Gagal membuat $PERSISTENT_DIR (penyimpanan penuh/izin?); pemasangan dibatalkan / failed to create config dir, install aborted"
cp $MODPATH/config.sh $MODPATH/config.default.sh || abort "[!] Gagal menyiapkan config.default.sh / failed to write config.default.sh"
files="sus_mount.txt try_umount.txt sus_path.txt sus_path_loop.txt sus_maps.txt sus_open_redirect.txt legit_mounts.txt sus_kstat_statically.json priority_extra_packages.txt config.sh"
for i in $files; do
	if [ ! -f $PERSISTENT_DIR/$i ]; then
		# Jangan hapus sumber staging sebelum salinan tujuan sah
		cat $MODPATH/$i > $PERSISTENT_DIR/$i || abort "[!] Gagal menulis $PERSISTENT_DIR/$i; pemasangan dibatalkan / write failed, install aborted"
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

rm -rf $MODPATH/tools
rm $MODPATH/customize.sh

# WebUI bisa dibuka tanpa reboot: salin dari MODPATH asli (path modules_update beda antar manager)
sed -i "s/^description=.*/description=status: ✅ SuS ඞ/" $MODPATH/module.prop
if [ "$MODPATH" != "$LIVE_DIR" ]; then
	# Tukar utuh (bukan timpa) supaya file yang sudah dicabut dari paket tidak tertinggal. Versi lama baru
	# dihapus setelah versi baru berhasil masuk; bila gagal, versi lama dikembalikan. Ini hanya untuk membuka
	# WebUI sebelum reboot: pemasangan sebenarnya tetap dari modules_update oleh manager saat reboot.
	rm -rf $LIVE_DIR.new $LIVE_DIR.old
	if cp -rf $MODPATH $LIVE_DIR.new; then
		if [ -d $LIVE_DIR ] && ! mv $LIVE_DIR $LIVE_DIR.old; then
			# Rename pertama gagal: jangan lanjut (mv ke folder yang masih ada akan menyarangkan versi baru)
			rm -rf $LIVE_DIR.new
			ui_print "[!] WebUI baru bisa dibuka setelah reboot (versi lama tetap aktif) / WebUI available after reboot"
		elif mv $LIVE_DIR.new $LIVE_DIR && [ -f $LIVE_DIR/module.prop ] && [ ! -e $LIVE_DIR/hybrid_susfs.new ]; then
			rm -rf $LIVE_DIR.old
		else
			# Versi baru tidak masuk utuh: singkirkan sisanya dan kembalikan versi lama (selama .old masih ada)
			[ -d $LIVE_DIR.old ] && { rm -rf $LIVE_DIR; mv $LIVE_DIR.old $LIVE_DIR; }
			rm -rf $LIVE_DIR.new
			ui_print "[!] WebUI baru bisa dibuka setelah reboot (versi lama tetap aktif) / WebUI available after reboot"
		fi
	else
		rm -rf $LIVE_DIR.new
		ui_print "[!] WebUI baru bisa dibuka setelah reboot / WebUI available after reboot"
	fi
fi

ui_print " "
ui_print "  Selesai. Reboot untuk mengaktifkan."
ui_print "  Done. Reboot to activate."
ui_print " "
