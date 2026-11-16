#!/bin/sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
MODDIR=/data/adb/modules/hybrid_susfs

echo "Hybrid SusFS $(grep '^version=' $MODDIR/module.prop | cut -d= -f2)"
echo "SUSFS kernel : $(${SUSFS_BIN} show version 2>/dev/null)"
echo "Varian      : $(${SUSFS_BIN} show variant 2>/dev/null)"
echo "Kernel      : $(uname -r)"
echo "Fitur SUSFS aktif:"
${SUSFS_BIN} show enabled_features 2>/dev/null | sed 's/^/  /'
