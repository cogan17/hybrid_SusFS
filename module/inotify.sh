#!/system/bin/sh
# Dari Brene: hapus sisa '..5.u.S' yang dibuat SUSFS bila aplikasi bisa menulis ke storage
for d in /storage/emulated/0 /storage/emulated/0/Android/data /storage/emulated/0/Android/media /storage/emulated/0/Android/obb; do
	rm -rf "$d/..5.u.S"
done
