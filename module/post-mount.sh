#!/bin/sh
MODDIR=/data/adb/modules/hybrid_susfs
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
. ${MODDIR}/utils.sh
PERSISTENT_DIR=/data/adb/hybrid_susfs
tmpfolder=/data/adb/ksu/hybrid_susfs
logfile="$tmpfolder/logs/susfs.log"
logfile1="$tmpfolder/logs/susfs1.log"

# Mount folder of susfs4ksu
[ -w /mnt ] && mntfolder=/mnt/hybrid_susfs
[ -w /mnt/vendor ] && mntfolder=/mnt/vendor/hybrid_susfs

post_fs_data=0
[ -f $tmpfolder/logs/boot_stage_time.sh ] && . $tmpfolder/logs/boot_stage_time.sh

# to add mounts
# echo "/system" >> /data/adb/hybrid_susfs/sus_mount.txt
# this'll make it easier for the webui to do stuff
# Check and process sus_mount paths
if grep -v "#" "$PERSISTENT_DIR/sus_mount.txt" > /dev/null; then
    grep -v "#" "$PERSISTENT_DIR/sus_mount.txt" | while read -r i; do
        [ -z "$i" ] || { ${SUSFS_BIN} add_sus_mount "$i" && echo "[sus_mount]: hybrid_susfs/post-mount $i" >> "$logfile1"; }
    done
fi

# Check and process try_umount paths
if grep -v "#" "$PERSISTENT_DIR/try_umount.txt" > /dev/null; then
    grep -v "#" "$PERSISTENT_DIR/try_umount.txt" | while read -r i; do
        [ -z "$i" ] || { ${SUSFS_BIN} add_try_umount "$i" 1 && echo "[try_umount]: hybrid_susfs/post-mount $i" >> "$logfile1"; }
    done
fi

# SUSFS Logging
dmesg_snapshot=$(dmesg)
echo "$dmesg_snapshot" | sed -n "/^\[ *$post_fs_data/,\$p" | grep -iE "susfs_auto_add|ksu_susfs|susfs:" >> $logfile
endmsg=$(echo "$dmesg_snapshot" | grep -E '^\[ *[0-9]' | cut -d']' -f1 | sed 's/^\[ *//' | cut -d' ' -f1 | tail -n 1)
echo "post_mount=$endmsg" >> $tmpfolder/logs/boot_stage_time.sh
# EOF
