#!/bin/sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
MODDIR=/data/adb/modules/hybrid_susfs

echo "hybrid_susfs $(grep '^version=' $MODDIR/module.prop | cut -d= -f2)"
echo "Build       : $(sed -n 2p $MODDIR/MANIFEST.txt 2>/dev/null)"
echo "SUSFS kernel : $(${SUSFS_BIN} show version 2>/dev/null)"
echo "Varian      : $(${SUSFS_BIN} show variant 2>/dev/null)"
echo "Kernel      : $(uname -r)"
echo "Filter UID (diperbarui sekarang, termasuk aplikasi yang baru dipasang):"
sh $MODDIR/priority_uid.sh apply | sed 's/^/  /'
echo "Fitur SUSFS aktif:"
${SUSFS_BIN} show enabled_features 2>/dev/null | sed 's/^/  /'
