#!/bin/sh
PATH=/data/adb/ksu/bin:$PATH
kernel_version='default'
kernel_build='default'
# config.sh TIDAK di-source: dibaca sebagai data. Hanya key yang ada di config default modul yang diterima,
# dan nilainya harus cocok skema per key (rule() di bawah: 0/1, mode terbatas, tanggal, hex, teks uname).
# Key internal (SUSFS_BIN, PATH, ...) dan nilai berisi ' " ; $ ` \ / & tidak pernah masuk.
HYBRID_DEFAULTS=/data/adb/modules/hybrid_susfs/config.default.sh

# hybrid_config_canonical <file>: cetak config lengkap (urutan & key dari default) dengan nilai sah dari <file>.
# Exit 3 bila <file> tidak menyumbang satu pun nilai sah.
hybrid_config_canonical() {
	awk -v q="'" '
		function unquote(s) { if (length(s) >= 2 && (s ~ /^".*"$/ || s ~ ("^" q ".*" q "$"))) s = substr(s, 2, length(s) - 2); return s }
		function key(s) { return match(s, /^[A-Za-z_][A-Za-z0-9_]*=/) ? substr(s, 1, RLENGTH - 1) : "" }
		# Skema per key: nilai di luar aturan kembali ke default
		function rule(k) {
			if (k == "sus_su" || k == "sus_su_active") return "^(-1|0|1|2)$"
			if (k == "hide_cusrom") return "^[0-5]$"
			if (k == "emulate_vold_app_data" || k == "hide_sus_mnts_for_all_or_non_su_procs" || k == "spoof_uname") return "^[012]$"
			if (k == "config_developer_options" || k == "config_usb_debugging" || k == "config_wireless_debugging") return "^(-1|0|1)$"
			if (k == "kernel_version" || k == "kernel_build") return "^[A-Za-z0-9 .:_+#()-]+$"
			if (k == "config_spoof_verified_boot_hash") return "^[0-9a-fA-F]*$"
			if (k == "CURRENT_YEAR") return "^([0-9][0-9][0-9][0-9])?$"
			if (k == "CURRENT_MONTH") return "^(0[1-9]|1[0-2])?$"
			if (k == "CURRENT_DAY") return "^(0[1-9]|[12][0-9]|3[01])?$"
			return "^[01]$"
		}
		FNR == NR { k = key($0); if (k != "") { order[++n] = k; v[k] = unquote(substr($0, length(k) + 2)) } next }
		{ k = key($0); x = unquote(substr($0, length(k) + 2)) }
		k != "" && (k in v) { if (x ~ rule(k)) { v[k] = x; got++ } else print "[config] nilai " k " tidak sah, pakai default" > "/dev/stderr" }
		END {
			for (i = 1; i <= n; i++) { k = order[i]; print k "=" (v[k] ~ /^-?[0-9]+$/ ? v[k] : q v[k] q) }
			if (!got) exit 3
		}
	' "$HYBRID_DEFAULTS" "$1"
}

hybrid_load_config() {
	local f=$PERSISTENT_DIR/config.sh tmp line key val
	[ -f "$HYBRID_DEFAULTS" ] || return 0 # tanpa daftar key resmi: jangan muat apa pun
	[ -L "$f" ] && rm -f "$f"
	[ -f "$f" ] || return 0
	tmp=$(mktemp "$f.XXXXXX") || return 0
	hybrid_config_canonical "$f" > "$tmp" 2>> /data/adb/ksu/hybrid_susfs/logs/susfs1.log
	case $? in 0|3) ;; *) rm -f "$tmp"; return 0 ;; esac # 3 = tidak ada nilai sah: tetap pakai default
	[ -s "$tmp" ] || { rm -f "$tmp"; return 0; }
	# File disamakan dengan bentuk kanonik supaya WebUI juga hanya melihat nilai sah
	if ! cmp -s "$tmp" "$f"; then
		cp "$tmp" "$f.new" && mv -f "$f.new" "$f" && \
			echo "[config] config.sh dirapikan: key/nilai tidak sah dibuang" >> /data/adb/ksu/hybrid_susfs/logs/susfs1.log 2>/dev/null
	fi
	while IFS= read -r line; do
		key=${line%%=*}; val=${line#*=}; val=${val#\'}; val=${val%\'}
		eval "$key=\$val" # key berasal dari config default (nama variabel sah); nilai tidak dievaluasi ulang
	done < "$tmp"
	rm -f "$tmp"
}

## susfs_clone_perm <file/or/dir/perm/to/be/changed> <file/or/dir/to/clone/from>
susfs_clone_perm() {
	TO=$1
	FROM=$2
	if [ -z "${TO}" -o -z "${FROM}" ]; then
		return
	fi
	CLONED_PERM_STRING=$(stat -c "%a %U %G" ${FROM})
	set ${CLONED_PERM_STRING}
	chmod $1 ${TO}
	chown $2:$3 ${TO}
	busybox chcon --reference=${FROM} ${TO}
}

## susfs_hexpatch_props <target_prop_name> <spoofed_prop_name> <spoofed_prop_value>
susfs_hexpatch_props() {
	TARGET_PROP_NAME=$1
	SPOOFED_PROP_NAME=$2
	SPOOFED_PROP_VALUE=$3
	if [ -z "${TARGET_PROP_NAME}" -o -z "${SPOOFED_PROP_NAME}" -o -z "${SPOOFED_PROP_VALUE}" ]; then
		return 1
	fi
	if [ "${#TARGET_PROP_NAME}" != "${#SPOOFED_PROP_NAME}" ]; then
		return 1
	fi
	resetprop -n ${TARGET_PROP_NAME} ${SPOOFED_PROP_VALUE}
	magiskboot hexpatch /dev/__properties__/$(resetprop -Z ${TARGET_PROP_NAME}) $(echo -n ${TARGET_PROP_NAME} | xxd -p | tr "[:lower:]" "[:upper:]") $(echo -n ${SPOOFED_PROP_NAME} | xxd -p | tr "[:lower:]" "[:upper:]")
}

check_missing_prop() {
  local NAME=$1
  local EXPECTED=$2
  local VALUE=$(resetprop $NAME)
  [ -z $VALUE ] && resetprop $NAME $EXPECTED # if the property is missing
}

check_reset_prop() {
  local NAME=$1
  local EXPECTED=$2
  local VALUE=$(resetprop $NAME)
  [ -z $VALUE ] || [ $VALUE = $EXPECTED ] || resetprop $NAME $EXPECTED # if the property is not what we expect
}

check_missing_match_prop() {
  local NAME=$1
  local EXPECTED=$2
  local VALUE=$(resetprop $NAME)
  [ -z $VALUE ] || [ $VALUE = $EXPECTED ] || resetprop $NAME $EXPECTED # if the property is not what we expect
  [ -z $VALUE ] && resetprop $NAME $EXPECTED # if the property is missing
}

contains_reset_prop() {
  local NAME=$1
  local CONTAINS=$2
  local NEWVAL=$3
  [[ "$(resetprop $NAME)" = *"$CONTAINS"* ]] && resetprop $NAME $NEWVAL
}

spoof_uname() {
	[ -z $kernel_version ] && kernel_version='default'
	[ -z $kernel_build ] && kernel_build='default'
	${SUSFS_BIN} set_uname "$kernel_version" "$kernel_build"
}
