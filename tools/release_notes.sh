#!/bin/bash
# Catatan rilis dua bahasa dari CHANGELOG.md + identitas build. Dipakai Builder dan Rilis dari run.
# Pakai: tools/release_notes.sh <build.env> <url run> [diuji_di_hp true|false] [catatan ID] [catatan EN]
# Catatan memakai \n untuk baris baru (input workflow hanya satu baris).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ENV_FILE=$1 RUN_URL=$2 TESTED=${3:-false} NOTE=${4:-} NOTE_EN=${5:-}
# build.env ditulis build.sh dengan nilai dikutip; dibaca per key, tidak di-source (artifact dari run lain)
get() { sed -n "s/^$1='\(.*\)'\$/\1/p" "$ENV_FILE"; }
VERSION=$(get VERSION) SUSFS=$(get SUSFS) SHA256=$(get SHA256)
[[ "$VERSION" =~ ^v[0-9]+\.[0-9]+$ ]] || { echo "GAGAL: VERSION tidak sah: '$VERSION'" >&2; exit 1; }
[[ "$SHA256" =~ ^[0-9a-f]{64}$ ]] || { echo "GAGAL: SHA256 tidak sah" >&2; exit 1; }

changes=$(awk -v v="$VERSION" '$0 ~ "^## "v"( |$)" {f=1; next} /^## / {f=0} f' "$ROOT/CHANGELOG.md" | sed '/^$/d')
[ -n "$changes" ] || { echo "GAGAL: CHANGELOG.md tidak punya isi untuk $VERSION" >&2; exit 1; }

if [ "$TESTED" = true ]; then
	echo "- 🇮🇩 ✅ Sudah diuji owner di HP."
	echo "- 🇬🇧 ✅ Tested by the owner on the phone."
else
	echo "- 🇮🇩 ⚠️ Belum diuji di HP."
	echo "- 🇬🇧 ⚠️ Not tested on the phone yet."
fi
[ -z "$NOTE" ] || printf '\n🇮🇩 %b\n' "$NOTE"
[ -z "$NOTE_EN" ] || printf '\n🇬🇧 %b\n' "$NOTE_EN"
echo
echo "### Perubahan / Changes"
echo
echo "$changes"
echo
echo "---"
echo "- SUSFS: $SUSFS"
echo "- SHA256: \`$SHA256\`"
echo "- Build: $RUN_URL"
