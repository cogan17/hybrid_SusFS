#!/system/bin/sh
# Dari Brene: hapus folder eksternal aplikasi root manager di Android/[data|media|obb]
sleep 1
for pkg in me.weishu.kernelsu com.rifsxd.ksunext com.resukisu.resukisu com.sukisu.ultra org.frknkrc44.hma_oss com.termux; do
	rm -rf "/storage/emulated/0/Android/data/$pkg" "/storage/emulated/0/Android/media/$pkg" "/storage/emulated/0/Android/obb/$pkg"
done
