#!/bin/sh
# Fitur Brene (rrr333nnn333/BRENE, AGPL-3.0) yang tidak ada di SideX.
# Fitur yang sama dengan SideX (spoof uname, avc log spoofing, hide sus mounts,
# spoof cmdline, log SUSFS, hide custom ROM, daftar custom) memakai versi SideX.
# Disource oleh customize.sh, post-fs-data.sh dan boot-completed.sh.

PATH=/data/adb/ksu/bin:$PATH
KSU_BIN=/data/adb/ksu/bin/ksud
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
PERSISTENT_DIR=/data/adb/hybrid_susfs
BRENE_LOG=/data/adb/ksu/hybrid_susfs/logs/susfs1.log
MODDIR_BRENE=/data/adb/modules/hybrid_susfs

brene_log() { echo "[hybrid_susfs] $*" >> $BRENE_LOG 2>/dev/null; }

brene_update_config_date() {
	sed -i "s/^CURRENT_YEAR=.*/CURRENT_YEAR='$(busybox date +%Y)'/" $PERSISTENT_DIR/config.sh
	sed -i "s/^CURRENT_MONTH=.*/CURRENT_MONTH='$(busybox date +%m)'/" $PERSISTENT_DIR/config.sh
	sed -i "s/^CURRENT_DAY=.*/CURRENT_DAY='$(busybox date +%d)'/" $PERSISTENT_DIR/config.sh
}

## brene_clone_perm <tujuan> <sumber>
brene_clone_perm() {
	[ -z "$1" ] || [ -z "$2" ] && return 1
	set -- "$1" "$2" $(busybox stat -c "%a %U %G" "$2")
	busybox chmod "$3" "$1"
	busybox chown "$4:$5" "$1"
	busybox chcon --reference="$2" "$1"
}

brene_sus_path() { $SUSFS_BIN add_sus_path "$1" && brene_log "sus_path $1"; }
brene_sus_path_loop() { $SUSFS_BIN add_sus_path_loop "$1" && brene_log "sus_path_loop $1"; }
brene_sus_map() { $SUSFS_BIN add_sus_map "$1" && brene_log "sus_map $1"; }
brene_open_redirect() {
	brene_clone_perm "$2" "$1"
	$SUSFS_BIN add_open_redirect "$1" "$2" "$3" && brene_log "open_redirect $1 -> $2 ($3)"
}

## Ubah prop hanya bila ada dan nilainya beda
brene_prop() {
	local cur=$(resetprop "$1")
	[ -z "$cur" ] || [ "$cur" = "$2" ] || resetprop -n "$1" "$2"
}
## Ubah prop bila nilainya memuat teks tertentu (dari SideX)
brene_prop_contains() {
	case "$(resetprop "$1")" in *"$2"*) resetprop -n "$1" "$3" ;; esac
}

spoof_system_properties() {
	brene_prop ro.secure 1
	brene_prop ro.debuggable 0
	brene_prop ro.adb.secure 1
	brene_prop persist.sys.usb.config mtp
	brene_prop ro.boot.verifiedbootstate green
	brene_prop ro.boot.flash.locked 1
	brene_prop ro.boot.veritymode enforcing
	brene_prop ro.boot.avb_version 1.3
	brene_prop ro.build.type user
	brene_prop ro.build.tags release-keys
	brene_prop ro.build.keys release-keys
	brene_prop ro.allow.mock.location 0
	brene_prop ro.boot.warranty_bit 0
	brene_prop ro.warranty_bit 0
	brene_prop ro.force.debuggable 0
	brene_prop ro.secureboot.devicelock 1
	brene_prop ro.secureboot.lockstate locked
	brene_prop ro.is_ever_orange 0
	brene_prop ro.bootmode normal
	brene_prop vendor.boot.verifiedbootstate green
	brene_prop ro.vendor.boot.warranty_bit 0
	brene_prop ro.vendor.warranty_bit 0
	brene_prop init.svc.adbd stopped
	brene_prop init.svc_debug_pid.adbd ""

	local fp=$(resetprop ro.build.fingerprint)
	brene_prop ro.build.fingerprint "$(echo "$fp" | sed 's/userdebug/user/g; s/test-keys/release-keys/g; s/eng//g; s/crdroid//g; s/lineage//g; s/evolution//g')"

	# Realme
	brene_prop ro.boot.realme.lockstate 1
	brene_prop ro.boot.realmebootstate green

	# Dari SideX: jejak boot recovery dan cloud phone
	brene_prop_contains ro.boot.bootmode recovery unknown
	brene_prop_contains vendor.boot.bootmode recovery unknown
	[ -n "$(resetprop ro.kernel.qemu)" ] && resetprop -n ro.kernel.qemu ""

	# Prop kosong lebih mencurigakan daripada tidak diubah: set hanya bila ukuran vbmeta terbaca
	local vbsize=$(blockdev --getsize64 "/dev/block/by-name/vbmeta$(resetprop ro.boot.slot_suffix)" 2>/dev/null)
	[ -n "$vbsize" ] && resetprop -n ro.boot.vbmeta.size "$vbsize"
	resetprop -n ro.boot.vbmeta.avb_version 1.3
	resetprop -n ro.boot.vbmeta.hash_alg sha256
	resetprop -n ro.boot.vbmeta.device_state locked
	resetprop -n ro.boot.vbmeta.invalidate_on_error yes
	resetprop -n vendor.boot.vbmeta.device_state locked

	for p in ro.boot.verifiedbooterror ro.boot.verifyerrorpart vendor.boot.verifyerrorpart \
		vendor.boot.verifiedbooterror crashrecovery.rescue_boot_count service.adb.root service.adb.tcp.port; do
		resetprop -d $p
	done

	# Android 16 menghapus sys.oem_unlock_allowed; membuatnya lagi justru mencurigakan
	if [ "$(resetprop ro.build.version.sdk)" -ge 36 ]; then
		resetprop -d sys.oem_unlock_allowed
	else
		brene_prop sys.oem_unlock_allowed 0
	fi
	resetprop -c --force
}

## Patch level: tanggal 1 (OS) / 5 (vendor) bulan ini, atau bulan lalu bila belum tanggal 5
brene_patch_date() {
	local day=$2
	if [ "${CURRENT_DAY#0}" -ge 5 ]; then
		echo "$CURRENT_YEAR-$CURRENT_MONTH-$day"
	elif [ "${CURRENT_MONTH#0}" -ge 2 ]; then
		echo "$CURRENT_YEAR-$(printf %02d $((${CURRENT_MONTH#0} - 1)))-$day"
	else
		echo "$((CURRENT_YEAR - 1))-12-$day"
	fi
}
spoof_os_security_patch_level_property() {
	[ -n "$CURRENT_YEAR" ] && brene_prop ro.build.version.security_patch "$(brene_patch_date os 01)"
}
spoof_vendor_security_patch_level_property() {
	[ -n "$CURRENT_YEAR" ] && brene_prop ro.vendor.build.security_patch "$(brene_patch_date vendor 05)"
}

brene_spoof_props() {
	[ "$config_spoof_system_properties" = 1 ] && spoof_system_properties
	[ "$config_spoof_os_security_patch_level_property" = 1 ] && spoof_os_security_patch_level_property
	[ "$config_spoof_vendor_security_patch_level_property" = 1 ] && spoof_vendor_security_patch_level_property
}

brene_post_fs_data() {
	brene_log "post-fs-data"

	[ "$config_hide_addon_d" = 1 ] && {
		brene_sus_map /system/addon.d
		brene_sus_path_loop /system/addon.d
	}

	[ "$config_hide_suspicious_pty" = 1 ] && for i in 0 1 2 3 4 5; do
		brene_sus_path_loop /dev/pts/$i
	done

	[ "$config_spoof_hosts" = 1 ] && {
		mkdir -p $PERSISTENT_DIR/fake_files
		[ -f $PERSISTENT_DIR/fake_files/hosts ] || printf '127.0.0.1       localhost\n::1             ip6-localhost\n\n' > $PERSISTENT_DIR/fake_files/hosts
		brene_open_redirect /system/etc/hosts $PERSISTENT_DIR/fake_files/hosts 3
		$SUSFS_BIN add_sus_kstat_statically /system/etc/hosts 100 default default 56 default default default default default default 1 4096
	}

	brene_spoof_props
}

brene_ksud_feature() {
	case "$2" in 0|1) $KSU_BIN feature set $1 $2 || brene_log "ksud feature $1 tidak didukung manager ini" ;; esac
}

brene_fake_file_redirect() {
	local fake=$PERSISTENT_DIR/fake_files/$(basename "$1")
	[ -f "$fake" ] || touch "$fake"
	brene_open_redirect "$1" "$fake" 3
}

brene_boot_completed() {
	brene_log "boot-completed"

	# Fitur KernelSU
	brene_ksud_feature su_compat "$config_su_compat"
	brene_ksud_feature kernel_umount "$config_kernel_umount"
	brene_ksud_feature selinux_hide "$config_selinux_hide"
	$KSU_BIN feature save || brene_log "ksud feature save gagal"

	# Pengaturan Android
	case "$config_developer_options" in 0|1) settings put global development_settings_enabled $config_developer_options ;; esac
	case "$config_usb_debugging" in 0|1) settings put global adb_enabled $config_usb_debugging ;; esac
	case "$config_wireless_debugging" in 0|1) settings put global adb_wifi_enabled $config_wireless_debugging ;; esac
	# Hanya di memori (-n tanpa -p, tidak lewat property_service): nilai tersimpan pemilik tidak disentuh,
	# jadi saat toggle mati prop otomatis kembali ke nilai asli setelah reboot. Jangan hapus dengan -p.
	[ "$config_disable_child_process_restrictions" = 1 ] && resetprop -n persist.sys.fflag.override.settings_enable_monitor_phantom_procs false
	[ "$config_saturation" = 1 ] && service call SurfaceFlinger 1022 f 2.0
	[ "$config_show_refresh_rate" = 1 ] && service call SurfaceFlinger 1034 i32 1
	[ "$config_shrink_buffer_size" = 1 ] && logcat -G 64K
	[ "$config_hide_oem_unlocking_toggle" = 1 ] && brene_prop ro.oem_unlock_supported 0

	[ "$config_hide_vector_injection" = 1 ] && {
		brene_sus_map /data/adb/modules/zygisk_vector/zygisk/arm64-v8a.so
		brene_sus_map /data/adb/modules/zygisk_vector/zygisk/armeabi-v7a.so
	}

	[ "$config_rom_props" = 1 ] && {
		CUSTOM_ROM_NAMES="lineage|infinity|evolution|crdroid|mistos|axion|pixelos|rising|lunaris|halcyon|havoc|alphadroid|bliss|calyx|derpfest|graphene|lmodroid|lumine|matrixx|clover|yaap|aospa"
		resetprop | grep -iE "$CUSTOM_ROM_NAMES" | awk -F'[][]' '{print $2}' | while read -r prop; do
			resetprop -d "$prop"
		done
		resetprop -d ro.modversion
	}

	# Permanen: prop persist yang dihapus tidak dikembalikan saat toggle dimatikan (label WebUI menyebutnya)
	[ "$config_pif_props" = 1 ] && resetprop | grep -iE "pihook|pixelprops|spoof" | awk -F'[][]' '{print $2}' | while read -r prop; do
		resetprop -d -p "$prop"
	done

	[ "$config_hide_lineage_strings" = 1 ] && {
		find /system /system_ext /vendor /product \( -iname "*sepolicy.cil" -o -iname "*file_contexts" \) | while read -r path; do
			brene_fake_file_redirect "$path"
		done
		find /system /system_ext /vendor /product -iname "*.rc" | while read -r path; do
			grep -iq lineage "$path" && brene_fake_file_redirect "$path"
		done
		[ -e /system_ext/etc/permissions/Updater.xml ] && brene_fake_file_redirect /system_ext/etc/permissions/Updater.xml
	}

	# Tidak butuh storage: jalan dulu supaya tidak ikut tertahan bila storage belum siap
	[ "$config_paths_hiding__data_local_tmp" = 1 ] && for i in /data/local/tmp/*; do
		[ -e "$i" ] && brene_sus_path_loop "$i"
	done

	[ "$config_hide_framework_res_apk" = 1 ] && find /system -iname "*framework-res.apk" | while read -r path; do
		brene_sus_map "$path"
	done

	[ -n "$config_spoof_verified_boot_hash" ] && resetprop -n ro.boot.vbmeta.digest "$config_spoof_verified_boot_hash"

	[ "$config_fix_data_local_tmp_inconsistencies" = 1 ] && {
		mkdir -p /data/local/tmp
		chmod 0771 /data/local/tmp
		chown shell:shell /data/local/tmp
		chcon u:object_r:shell_data_file:s0 /data/local/tmp
		$SUSFS_BIN add_sus_kstat_statically /data/local/tmp 100 default default 4096 default default default default default default 8 4096
	}

	# Filter UID prioritas (pendamping HMA-OSS): satu mode, satu panggilan, status di priority_uid_status.txt
	sh $MODDIR_BRENE/priority_uid.sh apply > /dev/null 2>&1 || brene_log "filter UID gagal, lihat priority_uid_status.txt"

	# Butuh storage: tunggu maksimal 1 jam di latar belakang (mis. HP belum dibuka kunci setelah reboot)
	local t=0
	# Status tertunda terlihat di deskripsi modul (manager) selama menunggu, dihapus saat storage siap
	[ -e /storage/emulated/0/Android ] || sed -i 's/^\(description=.*\)$/\1 | ⏳ menunggu HP dibuka kunci/' $MODDIR_BRENE/module.prop
	until [ -e /storage/emulated/0/Android ] || [ $t -ge 3600 ]; do sleep 5; t=$((t + 5)); done
	# Belum siap setelah 1 jam (HP belum dibuka kunci): tetap dicoba tiap 60 detik, fitur lain sudah jalan
	[ -e /storage/emulated/0/Android ] || brene_log "storage belum siap setelah 1 jam, menunggu sampai HP dibuka kunci"
	until [ -e /storage/emulated/0/Android ]; do sleep 60; done
	sed -i 's/ | ⏳ menunggu HP dibuka kunci//' $MODDIR_BRENE/module.prop

	# Jam sudah sinkron saat boot-completed (bukan 1970): pakai tanggal hari ini untuk spoof patch level
	if [ "$(busybox date +%Y)" -ge 2025 ]; then
		brene_update_config_date
		CURRENT_YEAR=$(busybox date +%Y); CURRENT_MONTH=$(busybox date +%m); CURRENT_DAY=$(busybox date +%d)
	fi
	brene_spoof_props
	[ "$config_spoof_system_properties" = 1 ] && brene_prop ro.crypto.state encrypted

	if [ -e /storage/emulated/0/Android ]; then
		# Hapus sisa '..5.u.S' (dibuat SUSFS saat aplikasi punya akses semua file)
		sh $MODDIR_BRENE/inotify.sh
		inotifyd $MODDIR_BRENE/inotify.sh /storage/emulated/0:n &

		# Sembunyikan (bukan hapus) folder eksternal aplikasi root manager
		[ "$config_hide_ksu_directories" = 1 ] && for pkg in me.weishu.kernelsu com.rifsxd.ksunext com.resukisu.resukisu com.sukisu.ultra com.cogan.su org.frknkrc44.hma_oss com.termux; do
			for d in data media obb; do
				[ -e /storage/emulated/0/Android/$d/$pkg ] && brene_sus_path_loop /storage/emulated/0/Android/$d/$pkg
			done
		done

		[ "$config_paths_hiding__non_standard_sdcard" = 1 ] && {
			standard="Alarms Android Audiobooks DCIM Documents Download Movies Music Notifications Pictures Podcasts Recordings Ringtones"
			[ -n "$(resetprop ro.miui.ui.version.name)" ] && standard="$standard MIUI"
			for i in /storage/emulated/0/*; do
				case " $standard " in *" ${i##*/} "*) continue ;; esac
				brene_sus_path_loop "$i"
			done
		}

		[ "$config_paths_hiding__non_standard_sdcard_android" = 1 ] && for i in /storage/emulated/0/Android/*; do
			case "${i##*/}" in data|media|obb) continue ;; esac
			brene_sus_path_loop "$i"
		done
	fi

	[ "$config_hide_custom_recovery" = 1 ] && for p in /storage/emulated/0/Fox /storage/emulated/0/TWRP /data/recovery /vendor/bin/install-recovery.sh /system/bin/install-recovery.sh; do
		[ -e $p ] && brene_sus_path_loop $p
	done

	resetprop -c --force
	brene_update_config_date

	# Statistik WebUI ditulis sekali, setelah hitungan SideX (boot-completed.sh) selesai
	t=0
	until [ -f /data/adb/ksu/hybrid_susfs/stats_done ] || [ $t -ge 180 ]; do sleep 1; t=$((t + 1)); done
	if [ ! -f /data/adb/ksu/hybrid_susfs/stats_done ]; then
		brene_log "statistik tidak diperbarui: hitungan SideX belum selesai"
		return
	fi
	local np nm
	if dmesg | grep -q 'is successfully added to LH_SUS_PATH'; then
		# Dari catatan kernel: hanya aturan yang diterima kernel, tiap path/map dihitung sekali
		np=$(dmesg | grep 'is successfully added to LH_SUS_PATH' | sed "s/.*target_pathname: '\(.*\)', is successfully.*/\1/" | sort -u | wc -l)
		nm=$(dmesg | grep 'is flagged as AS_FLAGS_SUS_MAP' | sed "s/.*pathname: '\(.*\)', is flagged.*/\1/" | sort -u | wc -l)
		# dmesg adalah ring buffer: pesan lama bisa tergeser, jadi jangan lebih kecil dari hitungan log modul
		local lp=$(grep '^\[hybrid_susfs\] sus_path' $BRENE_LOG | sort -u | wc -l) lm=$(grep '^\[hybrid_susfs\] sus_map' $BRENE_LOG | sort -u | wc -l)
		[ $lp -gt $np ] && np=$lp
		[ $lm -gt $nm ] && nm=$lm
	else
		# Log kernel SUSFS mati: tambahkan hitungan dari log modul ini ke hitungan SideX
		np=+$(grep -c '^\[hybrid_susfs\] sus_path' $BRENE_LOG)
		nm=+$(grep -c '^\[hybrid_susfs\] sus_map' $BRENE_LOG)
	fi
	for f in /data/adb/ksu/hybrid_susfs/susfs_stats.txt /data/adb/ksu/hybrid_susfs/susfs_stats1.txt; do
		[ -f $f ] || continue
		awk -F= -v p="$np" -v m="$nm" '
			function upd(old, x) { return (substr(x, 1, 1) == "+") ? old + substr(x, 2) : x }
			$1 == "sus_path" { $2 = upd($2, p); sp = 1 } $1 == "sus_map" { $2 = upd($2, m); sm = 1 } { print $1 "=" $2 }
			END { if (!sp) print "sus_path=" upd(0, p); if (!sm) print "sus_map=" upd(0, m) }' $f > $f.tmp && mv -f $f.tmp $f
	done
}
