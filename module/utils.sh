#!/bin/sh
PATH=/data/adb/ksu/bin:$PATH
kernel_version='default'
kernel_build='default'
# config.sh di-source sebagai root, jadi hanya baris KEY=nilai-data yang boleh: angka, 'teks', "teks" atau kata,
# tanpa $ ` \ (cegah perintah dari impor backup atau isian WebUI ikut dijalankan)
HYBRID_CFG_RE='^[A-Za-z_][A-Za-z0-9_]*=(-?[0-9]+|'"'"'[^'"'"'$`\\]*'"'"'|"[^"$`\\]*"|[A-Za-z0-9_.:+-]*)$'
hybrid_load_config() {
	local f=$PERSISTENT_DIR/config.sh
	[ -L "$f" ] && rm -f "$f"
	[ -f "$f" ] || return 0
	if grep -qvE -e "$HYBRID_CFG_RE" -e '^#' -e '^$' "$f"; then
		grep -E "$HYBRID_CFG_RE" "$f" > "$f.tmp" && mv -f "$f.tmp" "$f"
		echo "[config] baris tidak sah dibuang dari config.sh" >> /data/adb/ksu/hybrid_susfs/logs/susfs1.log 2>/dev/null
	fi
	. "$f"
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
