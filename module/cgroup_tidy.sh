#!/system/bin/sh
# cgroup_tidy.sh (hybrid_susfs) - Cogan-Kernel issue #194
#
# Di HP stok, cgroup akar /sys/fs/cgroup hanya berisi init dan thread kernel; layanan root ditaruh init
# di /sys/fs/cgroup/system/uid_0/pid_<pid>. ksud (KernelSU dan turunannya) memindahkan skrip modul ke
# cgroup akar, dan shell root manager tinggal di cgroup aplikasinya; keduanya pola yang tidak ada di stok
# dan dibaca Futile Test. Uji HP 20 Nov 2026: setelah proses root dipindah seperti ini, Futile Normal.
#
# Skrip ini memindahkan proses root userspace dari cgroup akar dan dari cgroup aplikasi ke tempat yang
# sama dengan layanan root bawaan, saat boot lalu setiap SWEEP_SECONDS. Thread kernel (cmdline kosong),
# init, zygote dan anak zygote yang belum berganti uid tidak disentuh. Hanya builtin shell di dalam loop.

SWEEP_SECONDS=${SWEEP_SECONDS:-10}
CG=/sys/fs/cgroup
BASE=$CG/system/uid_0
[ -d "$BASE" ] || BASE=$CG/uid_0
[ -d "$BASE" ] || exit 0
OURS=""   # pid_<pid> yang dibuat skrip ini; hanya ini yang boleh dihapus saat kosong

LOG=/data/adb/ksu/hybrid_susfs/logs/susfs1.log
echo "[hybrid_susfs] cgroup_tidy: mulai, base=$BASE sweep=${SWEEP_SECONDS}s" >> "$LOG" 2>/dev/null

is_root() {
	while read -r key val _; do
		[ "$key" = "Uid:" ] && { [ "$val" = 0 ]; return; }
	done < "/proc/$1/status" 2>/dev/null
	return 1
}

move() {
	[ "$1" -gt 1 ] 2>/dev/null || return
	cmd=""
	read -r cmd < "/proc/$1/cmdline" 2>/dev/null
	[ -n "$cmd" ] || return                       # thread kernel
	case "$cmd" in zygote*|usap*|"<pre-initialized>"*) return ;; esac
	read -r comm < "/proc/$1/comm" 2>/dev/null
	[ "$comm" = init ] && return
	is_root "$1" || return
	dir="$BASE/pid_$1"
	if [ -d "$dir" ] || { mkdir "$dir" 2>/dev/null && OURS="$OURS $1"; }; then
		echo "$1" > "$dir/cgroup.procs" 2>/dev/null
	fi
}

sweep() {
	while read -r p; do move "$p"; done < "$CG/cgroup.procs"
	for f in "$CG"/apps/uid_*/pid_*/cgroup.procs; do
		[ -f "$f" ] || continue
		while read -r p; do move "$p"; done < "$f"
	done
	keep=""
	for p in $OURS; do
		left=""
		read -r left < "$BASE/pid_$p/cgroup.procs" 2>/dev/null
		if [ -z "$left" ] && rmdir "$BASE/pid_$p" 2>/dev/null; then continue; fi
		keep="$keep $p"
	done
	OURS=$keep
}

while :; do
	sweep
	sleep "$SWEEP_SECONDS"
done
