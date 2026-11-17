#!/bin/sh
MODDIR=/data/adb/modules/hybrid_susfs
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
. ${MODDIR}/utils.sh
PERSISTENT_DIR=/data/adb/hybrid_susfs
tmpfolder=/data/adb/ksu/hybrid_susfs
logfile1="$tmpfolder/logs/susfs1.log"
logfile="$tmpfolder/logs/susfs.log"
version=$(${SUSFS_BIN} show version)
susfs_features=$(${SUSFS_BIN} show enabled_features)
# SUSFS_DECIMAL_MAIN = '1'
SUSFS_DECIMAL_MAIN=$(echo "$version" | sed 's/^v//;' | cut -d'.' -f1)
# SUSFS_DECIMAL_SUB = '5'
SUSFS_DECIMAL_SUB=$(echo "$version" | sed 's/^v//;' | cut -d'.' -f2)
# SUSFS_DECIMAL_PATCH = '3'
SUSFS_DECIMAL_PATCH=$(echo "$version" | sed 's/^v//;' | cut -d'.' -f3)

# Mount folder of susfs4ksu
[ -w /mnt ] && mntfolder=/mnt/hybrid_susfs
[ -w /mnt/vendor ] && mntfolder=/mnt/vendor/hybrid_susfs

post_mount=0
[ -f $tmpfolder/logs/boot_stage_time.sh ] && . $tmpfolder/logs/boot_stage_time.sh

hide_loops=1
hide_vendor_sepolicy=0
hide_compat_matrix=0
fake_service_list=0
susfs_log=1
sus_su=2
hybrid_load_config

# SUS_SU 2#
sus_su_2(){
	# Enable sus_su or abort the function if sus_su is not supported #
	if ! ${SUSFS_BIN} sus_su 2; then
		sed -i "s/^sus_su=.*/sus_su=-1/" ${PERSISTENT_DIR}/config.sh
		return
	fi
	sed -i "s/^sus_su=.*/sus_su=2/" ${PERSISTENT_DIR}/config.sh
	sed -i "s/^sus_su_active=.*/sus_su_active=2/" ${PERSISTENT_DIR}/config.sh
	return
}

# sus_su #
# sus_su hanya ada di SUSFS v1; di v2 semua cabang di bawah dilewati (config diset -1 di akhir)
[ "$SUSFS_DECIMAL_MAIN" -ge 2 ] 2>/dev/null && sus_su=v2
[ $sus_su = -1 ] && {
	if [ -n "$version" ] && [ "$SUSFS_DECIMAL_MAIN" -ge 1 ] && [ "$SUSFS_DECIMAL_SUB" -ge 5 ] && [ "$SUSFS_DECIMAL_PATCH" -ge 3 ] 2>/dev/null; then
		# Check if sus_su is supported
		if echo "$susfs_features" | grep -q "CONFIG_KSU_SUSFS_SUS_SU"; then
  			sed -i "s/^sus_su=.*/sus_su=0/" ${PERSISTENT_DIR}/config.sh
			${SUSFS_BIN} sus_su 0
			sed -i "s/^sus_su_active=.*/sus_su_active=0/" ${PERSISTENT_DIR}/config.sh
		fi
	else
		if ${SUSFS_BIN} sus_su 0; then
  			sed -i "s/^sus_su=.*/sus_su=0/" ${PERSISTENT_DIR}/config.sh
			sed -i "s/^sus_su_active=.*/sus_su_active=0/" ${PERSISTENT_DIR}/config.sh
		fi
	fi
}

[ $sus_su = 0 ] && {
	if [ -n "$version" ] && [ "$SUSFS_DECIMAL_MAIN" -ge 1 ] && [ "$SUSFS_DECIMAL_SUB" -ge 5 ] && [ "$SUSFS_DECIMAL_PATCH" -ge 3 ] 2>/dev/null; then
		# Check if sus_su is supported
		if ! echo "$susfs_features" | grep -q "CONFIG_KSU_SUSFS_SUS_SU"; then
			sed -i "s/^sus_su=.*/sus_su=-1/" ${PERSISTENT_DIR}/config.sh
		else
			${SUSFS_BIN} sus_su 0
			sed -i "s/^sus_su_active=.*/sus_su_active=0/" ${PERSISTENT_DIR}/config.sh
		fi
	else
		if ! ${SUSFS_BIN} sus_su 0; then
			sed -i "s/^sus_su=.*/sus_su=-1/" ${PERSISTENT_DIR}/config.sh
		else
			sed -i "s/^sus_su_active=.*/sus_su_active=0/" ${PERSISTENT_DIR}/config.sh
		fi
	fi
}

[ $sus_su = 2 ] && {
	# Check for susfs version (1.5.3 and above)
	if [ -n "$version" ] && [ "$SUSFS_DECIMAL_MAIN" -ge 1 ] && [ "$SUSFS_DECIMAL_SUB" -ge 5 ] && [ "$SUSFS_DECIMAL_PATCH" -ge 3 ] 2>/dev/null; then
		# Check if sus_su is supported
		if echo "$susfs_features" | grep -q "CONFIG_KSU_SUSFS_SUS_SU"; then
			${SUSFS_BIN} sus_su 2
			sed -i "s/^sus_su=.*/sus_su=2/" ${PERSISTENT_DIR}/config.sh
			sed -i "s/^sus_su_active=.*/sus_su_active=2/" ${PERSISTENT_DIR}/config.sh
		else
			sed -i "s/^sus_su=.*/sus_su=-1/" ${PERSISTENT_DIR}/config.sh
		fi
	else
	# this one is for older verisons of susfs
		sus_su_2
	fi
}

[ "$SUSFS_DECIMAL_MAIN" -ge 2 ] 2>/dev/null && {
	# sus_su is deprecated in susfs v2.0.0 and above
	sed -i "s/^sus_su=.*/sus_su=-1/" ${PERSISTENT_DIR}/config.sh
}

## Disable susfs kernel log ##
[ $susfs_log = 1 ] && {
	${SUSFS_BIN} enable_log 1
}

# SUSFS Logging
dmesg_snapshot=$(dmesg)
echo "$dmesg_snapshot" | sed -n "/^\[ *$post_mount/,\$p" | grep -iE "susfs_auto_add|ksu_susfs|susfs:" >> $logfile
endmsg=$(echo "$dmesg_snapshot" | grep -E '^\[ *[0-9]' | cut -d']' -f1 | sed 's/^\[ *//' | cut -d' ' -f1 | tail -n 1)
echo "service=$endmsg" >> $tmpfolder/logs/boot_stage_time.sh

## Props ##
resetprop -w sys.boot_completed 0
# Spoof props SideX digabung ke spoof_system_properties di brene.sh (toggle config_spoof_system_properties)


# Add open redirect paths (service.sh)
if echo "$susfs_features" | grep -q "CONFIG_KSU_SUSFS_OPEN_REDIRECT"; then
	grep -v "#" "$PERSISTENT_DIR/sus_open_redirect.txt" | while IFS= read -r line; do
		original_path=$(echo "$line" | awk '{print $1}')
		redirected_path=$(echo "$line" | awk '{print $2}')
		execute_on=$(echo "$line" | awk '{print $3}')
		[ "$execute_on" != "1" ] && continue
		# Get inode and device of redirected path
		SUS_KSTAT=$(stat -c "%i %d default default %X 0 %Y 0 %Z 0 %b %B" "$original_path")
		if [ "$SUSFS_DECIMAL_MAIN" -ge 2 ] 2>/dev/null; then
			uid_scheme=$(echo "$line" | awk '{print $4}')
			if [ -z $uid_scheme ]; then
				${SUSFS_BIN} add_open_redirect "$original_path" "$redirected_path" 2 && echo "[open_redirect]: hybrid_susfs/boot-completed $original_path -> $redirected_path default_uid_scheme: 2" >> $logfile1
			else
				${SUSFS_BIN} add_open_redirect "$original_path" "$redirected_path" $uid_scheme && echo "[open_redirect]: hybrid_susfs/boot-completed $original_path -> $redirected_path uid_scheme: $uid_scheme" >> $logfile1
			fi
		else
		# Add open redirect
		${SUSFS_BIN} add_open_redirect "$original_path" "$redirected_path" && echo "[open_redirect]: hybrid_susfs/boot-completed $original_path -> $redirected_path" >> $logfile1
		fi
		# Spoof kstat for open redirected paths
		${SUSFS_BIN} add_sus_kstat_statically "$redirected_path" $SUS_KSTAT && echo "[add_sus_kstat_statically]: hybrid_susfs/boot-completed $original_path" >> $logfile1
	done
fi

# echo "hide_loops=1" >> /data/adb/hybrid_susfs/config.sh
[ $hide_loops = 1 ] && {
	echo "hybrid_susfs/service: [hide_loops]" >> $logfile1
	for device in $(ls -Ld /proc/fs/jbd2/loop*8 | sed 's|/proc/fs/jbd2/||; s|-8||'); do
		${SUSFS_BIN} add_sus_path /proc/fs/jbd2/${device}-8 && echo "[sus_path]: hybrid_susfs/service /proc/fs/jbd2/${device}-8" >> $logfile1
		${SUSFS_BIN} add_sus_path /proc/fs/ext4/${device} && echo "[sus_path]: hybrid_susfs/service /proc/fs/ext4/${device}" >> $logfile1
	done
}

# echo "hide_vendor_sepolicy=1" >> /data/adb/hybrid_susfs/config.sh
[ $hide_vendor_sepolicy = 1 ] && {
	echo "hybrid_susfs/service: [hide_vendor_sepolicy]" >> $logfile1
	for sepolicy_cil in \
		/vendor/etc/selinux/vendor_sepolicy.cil \
		/vendor/etc/selinux/vendor_file_contexts \
		/system_ext/etc/selinux/system_ext_sepolicy.cil
	do
		grep -q lineage $sepolicy_cil && {
			cil_name=`basename "$sepolicy_cil"`
			grep -v "lineage" $sepolicy_cil > $mntfolder/$cil_name
			[ "$SUSFS_DECIMAL_MAIN" -ge 2 ] && ${SUSFS_BIN} add_sus_kstat $sepolicy_cil && echo "[update_sus_kstat]: hybrid_susfs/service $sepolicy_cil" >> $logfile1
			[ "$SUSFS_DECIMAL_MAIN" = 2 ] && [ "$SUSFS_DECIMAL_SUB" = 0 ] || [ "$SUSFS_DECIMAL_MAIN" -lt 2 ] && susfs_clone_perm $mntfolder/$cil_name $sepolicy_cil
			mount --bind $mntfolder/$cil_name $sepolicy_cil && echo "[bind_mount]: hybrid_susfs/service $sepolicy_cil" >> $logfile1
			[ "$SUSFS_DECIMAL_MAIN" -ge 2 ] && ${SUSFS_BIN} update_sus_kstat $sepolicy_cil && echo "[update_sus_kstat]: hybrid_susfs/service $sepolicy_cil" >> $logfile1
			# add_sus_mount hanya ada di SUSFS v1; di v2 mount disembunyikan oleh kstat + hide_sus_mnts (engine v2 tidak punya command ini)
			[ "$SUSFS_DECIMAL_MAIN" -lt 2 ] && ${SUSFS_BIN} add_sus_mount $sepolicy_cil && echo "[sus_mount]: hybrid_susfs/service $sepolicy_cil" >> $logfile1
		}
	done
}

# echo "hide_compat_matrix=1" >> /data/adb/hybrid_susfs/config.sh
[ $hide_compat_matrix = 1 ] && {
	echo "hybrid_susfs/service: [hide_compat_matrix] - compatibility_matrix.device.xml" >> $logfile1
	compatibility_matrix=/system/etc/vintf/compatibility_matrix.device.xml
	grep -q lineage $compatibility_matrix && {
		grep -v "lineage" $compatibility_matrix > $mntfolder/compatibility_matrix.device.xml
		[ "$SUSFS_DECIMAL_MAIN" -ge 2 ] && ${SUSFS_BIN} add_sus_kstat $compatibility_matrix && echo "[update_sus_kstat]: hybrid_susfs/service $compatibility_matrix" >> $logfile1
		[ "$SUSFS_DECIMAL_MAIN" = 2 ] && [ "$SUSFS_DECIMAL_SUB" = 0 ] || [ "$SUSFS_DECIMAL_MAIN" -lt 2 ] && susfs_clone_perm $mntfolder/compatibility_matrix.device.xml $compatibility_matrix
		mount --bind $mntfolder/compatibility_matrix.device.xml $compatibility_matrix && echo "[bind_mount]: hybrid_susfs/service $compatibility_matrix" >> $logfile1
		[ "$SUSFS_DECIMAL_MAIN" -ge 2 ] && ${SUSFS_BIN} update_sus_kstat $compatibility_matrix && echo "[update_sus_kstat]: hybrid_susfs/service $compatibility_matrix" >> $logfile1
		# add_sus_mount hanya ada di SUSFS v1; di v2 mount disembunyikan oleh kstat + hide_sus_mnts (engine v2 tidak punya command ini)
		[ "$SUSFS_DECIMAL_MAIN" -lt 2 ] && ${SUSFS_BIN} add_sus_mount $compatibility_matrix && echo "[sus_mount]: hybrid_susfs/service $compatibility_matrix" >> $logfile1
	}
}
	
# EOF
