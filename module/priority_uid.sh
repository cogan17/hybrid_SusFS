#!/system/bin/sh
# Filter UID prioritas SUSFS (pendamping HMA-OSS): satu pintu untuk boot, tombol WebUI dan tombol action.
# Hanya menyaring syscall getpriority/setpriority/ioprio dari aplikasi lain (uid >= 10000);
# visibilitas aplikasi lewat PackageManager tetap diatur HMA-OSS.
# Kontrak kernel (SUSFS v2.4): satu CSV nama paket < 65535 byte, UID 10000-19999, setiap panggilan
# MENGGANTI seluruh filter, nama yang tidak bisa dipetakan dilewati kernel, string kosong ditolak.
# Pakai: priority_uid.sh apply | diagnose <uid>
MODDIR=${0%/*}
PERSISTENT_DIR=/data/adb/hybrid_susfs
. $MODDIR/utils.sh
hybrid_load_config
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
STATUS=/data/adb/ksu/hybrid_susfs/priority_uid_status.txt
EXTRA=$PERSISTENT_DIR/priority_extra_packages.txt
LIST=/data/system/packages.list
HMA=org.frknkrc44.hma_oss

mode() {
	if [ "$config_hide_all_apps_with_uid_10000_and_above" = 1 ]; then echo all
	elif [ "$config_hide_third_party_apps" = 1 ]; then echo third
	else echo off; fi
}
uid_of() { awk -v p="$1" '$1 == p {print $2; exit}' $LIST; }
in_range() { [ -n "$1" ] && [ "$1" -ge 10000 ] && [ "$1" -le 19999 ]; }

# candidates <mode>: daftar nama paket (satu per baris); exit 1 + pesan di stderr bila tidak sah
candidates() {
	local pkgs line u
	case $1 in
		third)
			pkgs=$(cmd package list packages -3 --user 0 2>/dev/null) || { echo "query PackageManager gagal" >&2; return 1; }
			pkgs=$(echo "$pkgs" | sed -n 's/^package://p')
			u=$(uid_of $HMA); in_range "$u" && pkgs="$pkgs
$HMA" ;;
		all)
			[ -r $LIST ] || { echo "$LIST tidak terbaca" >&2; return 1; }
			pkgs=$(awk '$2 >= 10000 && $2 <= 19999 {print $1}' $LIST) ;;
	esac
	[ -L $EXTRA ] && { echo "daftar paket tambahan tidak boleh berupa symlink" >&2; return 1; }
	if [ -f $EXTRA ]; then
		while IFS= read -r line || [ -n "$line" ]; do
			case "$line" in ""|\#*) continue ;; esac
			echo "$line" | grep -qE '^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$' || { echo "nama paket tambahan tidak sah: $line" >&2; return 1; }
			u=$(uid_of "$line")
			[ -n "$u" ] || { echo "paket tambahan tidak terpasang: $line" >&2; return 1; }
			in_range "$u" || { echo "paket tambahan di luar UID 10000-19999: $line ($u)" >&2; return 1; }
			pkgs="$pkgs
$line"
		done < $EXTRA
	fi
	pkgs=$(echo "$pkgs" | grep -v '^$' | sort -u)
	[ -n "$pkgs" ] || { echo "daftar paket kosong" >&2; return 1; }
	echo "$pkgs"
}

# Status ditulis ke file sementara lalu di-rename (pembaca seperti WebUI tidak melihat file setengah jadi)
status() {
	mkdir -p ${STATUS%/*}
	# Tmp unik per proses (hindari bentrok bila dua apply jalan). Bila simpan gagal, tampilkan status BARU
	# (bukan file lama) dan kembalikan nonzero, supaya pembaca tidak mengira status lama sebagai hasil baru.
	out=$(echo "waktu: $(date '+%F %T %Z')"; printf '%s\n' "$@")
	t=$STATUS.$$.tmp
	if printf '%s\n' "$out" > "$t" && mv -f "$t" $STATUS; then
		cat $STATUS
	else
		rm -f "$t"
		printf '%s\n' "$out"
		return 1
	fi
}

case "$1" in
apply)
	m=$(mode)
	if [ $m = off ]; then
		status "mode: off" "hasil: tidak ada perintah dikirim" \
			"catatan: filter yang sudah diterapkan sejak boot tetap berlaku sampai reboot (kernel tidak punya perintah kosongkan)"
		exit 0
	fi
	list=$(candidates $m 2> $STATUS.err) || { status "mode: $m" "hasil: GAGAL, tidak ada perintah dikirim" "alasan: $(cat $STATUS.err)"; rm -f $STATUS.err; exit 1; }
	rm -f $STATUS.err
	csv=$(echo "$list" | tr '\n' ',' | sed 's/,$//')
	bytes=$(printf '%s' "$csv" | wc -c)
	[ $bytes -lt 65535 ] || { status "mode: $m" "hasil: GAGAL, daftar ${bytes} byte melebihi batas 65534 byte" "catatan: tidak dipotong atau dipecah (setiap panggilan mengganti seluruh filter)"; exit 1; }
	if $SUSFS_BIN set_priority_uid_filter "$csv" > /dev/null 2>&1; then
		status "mode: $m" "paket diminta: $(echo "$list" | wc -l) (${bytes} byte)" "hma_oss disertakan: $(echo "$list" | grep -Fxq -- "$HMA" && echo ya || echo tidak)" \
			"hasil: diterima kernel (bukan bukti aplikasi tak terlihat; nama yang tidak terpetakan dilewati kernel)"
	else
		status "mode: $m" "paket diminta: $(echo "$list" | wc -l) (${bytes} byte)" "hasil: GAGAL, ksu_susfs menolak permintaan"; exit 1
	fi ;;
diagnose)
	case "$2" in ''|*[!0-9]*) echo "Pakai: priority_uid.sh diagnose <uid angka>" >&2; exit 2 ;; esac
	m=$(mode)
	echo "UID: $2"
	names=$(awk -v u="$2" '$2 == u {print $1}' $LIST 2>/dev/null)
	echo "paket (packages.list): ${names:-tidak ada pemetaan}"
	in_range "$2" && echo "dalam rentang filter 10000-19999: ya" || echo "dalam rentang filter 10000-19999: TIDAK (tidak bisa difilter)"
	echo "UID hma_oss: $(uid_of $HMA || true)"
	echo "mode filter sekarang: $m"
	if [ $m != off ] && list=$(candidates $m 2>&1); then
		hit=tidak; for n in $names; do echo "$list" | grep -Fxq -- "$n" && hit=ya; done
		echo "termasuk daftar filter: $hit (jumlah kandidat $(echo "$list" | wc -l))"
	fi
	echo "catatan: tidak ada perintah dikirim ke kernel" ;;
*) echo "Pakai: priority_uid.sh apply | diagnose <uid>" >&2; exit 2 ;;
esac
