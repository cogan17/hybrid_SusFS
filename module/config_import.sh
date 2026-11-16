#!/system/bin/sh
# Impor backup config dari WebUI. Pakai: config_import.sh <arsip.tar.gz>
# 1. Daftar isi diperiksa sebelum ekstrak: hanya file biasa yang dikenal, maks 20 anggota, total 1 MiB.
# 2. Ekstrak ke folder sementara, periksa ulang. 3. Siapkan hasil di folder terpisah (bukan pohon ekstraksi).
# 4. Ganti config lama dengan cadangan; bila ada yang gagal semua dikembalikan dan keluar dengan status gagal.
MODDIR=${0%/*}
PERSISTENT_DIR=/data/adb/hybrid_susfs
. $MODDIR/utils.sh
ALLOW="config.sh sus_path.txt sus_path_loop.txt sus_maps.txt sus_mount.txt try_umount.txt sus_open_redirect.txt legit_mounts.txt sus_kstat_statically.json priority_extra_packages.txt"

fail() { echo "$*" >&2; exit 1; }
[ -f "$HYBRID_DEFAULTS" ] || fail "config default modul tidak ada"
WORK=$(mktemp -d /data/adb/ksu/hybrid_susfs/import.XXXXXX) || fail "folder sementara tidak bisa dibuat"
trap 'rm -rf "$WORK"' EXIT
mkdir "$WORK/x" "$WORK/out" "$WORK/old" || fail "folder sementara tidak bisa dibuat"

# 1. Periksa daftar isi (tipe di kolom 1, ukuran kolom 3, nama kolom terakhir; link punya kolom tambahan)
tar -tvzf "$1" > "$WORK/list" 2>/dev/null || fail "arsip tidak bisa dibaca"
# fake_files/ dan .phantom_procs_set ada di backup buatan versi lama: dilewati, tidak disalin
awk -v allow=" $ALLOW " '
	function no(m) { if (msg == "") msg = m }
	{ n++; t = substr($1, 1, 1); name = $NF; sub(/^\.\//, "", name) }
	NF != 6 { no((t == "l" || t == "h") ? "arsip berisi link" : "nama file di arsip tidak didukung"); next }
	t == "d" && (name == "" || name == "." || name == "./" || name == "fake_files" || name == "fake_files/") { next }
	t != "-" { no("arsip berisi link atau file khusus"); next }
	name ~ /^fake_files\/[^\/]+$/ || name == ".phantom_procs_set" { total += $3; next }
	index(allow, " " name " ") == 0 { no("file asing di arsip: " name); next }
	{ total += $3 }
	END {
		if (n > 40) no("arsip berisi terlalu banyak file")
		if (total > 1048576) no("arsip terlalu besar")
		if (msg != "") { print msg; exit 1 }
	}
' "$WORK/list" > "$WORK/why" || fail "$(cat "$WORK/why")"

# 2. Ekstrak lalu periksa ulang hasilnya
tar -xzf "$1" -C "$WORK/x" 2>/dev/null || fail "arsip gagal diekstrak"
[ -z "$(find "$WORK/x" -mindepth 1 ! -type f ! -type d)" ] || fail "arsip berisi link"
[ -f "$WORK/x/config.sh" ] || fail "config.sh tidak ada di arsip"

# 3. Siapkan hasil
hybrid_config_canonical "$WORK/x/config.sh" > "$WORK/out/config.sh"
case $? in 0) ;; 3) fail "backup tidak berisi pengaturan yang sah" ;; *) fail "config.sh tidak bisa dibaca" ;; esac
for f in $ALLOW; do
	[ "$f" = config.sh ] && continue
	src=$WORK/x/$f
	[ -f "$src" ] || continue
	[ "$(stat -c %h "$src")" = 1 ] || fail "$f berupa hardlink"
	if [ "$f" = sus_kstat_statically.json ]; then
		awk -f $MODDIR/kstat_json.awk "$src" > /dev/null 2> "$WORK/kstat.err" || fail "$(cat "$WORK/kstat.err")"
	fi
	cp "$src" "$WORK/out/$f" || fail "gagal menyiapkan $f"
done

# 4. Terapkan dengan cadangan
for p in "$WORK/out"/*; do
	f=${p##*/}
	[ -f "$PERSISTENT_DIR/$f" ] && { cp -p "$PERSISTENT_DIR/$f" "$WORK/old/$f" || fail "gagal mencadangkan $f"; }
done
for p in "$WORK/out"/*; do
	f=${p##*/}
	if ! { cp "$WORK/out/$f" "$PERSISTENT_DIR/$f.new" && mv -f "$PERSISTENT_DIR/$f.new" "$PERSISTENT_DIR/$f"; }; then
		rm -f "$PERSISTENT_DIR/$f.new"
		restored=1
		for q in "$WORK/out"/*; do # kembali ke versi lama, atau hapus bila dulu memang tidak ada
			o=$WORK/old/${q##*/}
			if [ -f "$o" ]; then
				cp -p "$o" "$PERSISTENT_DIR/${q##*/}" && cmp -s "$o" "$PERSISTENT_DIR/${q##*/}" || restored=0
			else
				rm -f "$PERSISTENT_DIR/${q##*/}" || restored=0
			fi
		done
		[ $restored = 1 ] && fail "gagal menulis $f, config lama dikembalikan"
		fail "gagal menulis $f dan config lama TIDAK bisa dikembalikan utuh; cek /data/adb/hybrid_susfs"
	fi
done
echo ok
