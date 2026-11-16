# Hybrid SusFS

## Indonesia

Modul KernelSU untuk kernel yang sudah di-patch SUSFS v2. Perpaduan tiga sumber:

| Bagian | Sumber |
|---|---|
| Mesin (`ksu_susfs`) | [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu), di-compile dari source saat build |
| Tampilan (WebUI) dan skrip dasar | [sidex15/susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) |
| Fitur tambahan (halaman *brene settings*) | [rrr333nnn333/BRENE](https://github.com/rrr333nnn333/BRENE) |

- Fitur yang ada di SideX dan Brene sekaligus memakai versi SideX, supaya tidak ada aturan ganda. Yang dipakai versi SideX: spoof uname, AVC log spoofing, hide sus mounts, spoof cmdline, log SUSFS, hide custom ROM, dan daftar custom.
- Spoof system properties SideX dan Brene digabung jadi satu toggle di halaman Brene.
- Binary tidak diunduh dari cloud. Yang dipakai adalah binary yang dibawa ZIP.
- Modul SUSFS lain (`susfs4ksu`, `brene`, `susfs_manager`) otomatis dimatikan saat pemasangan.
- Config disimpan di `/data/adb/hybrid_susfs/config.sh`.

**Versi:** 0.1, lalu 0.2, 0.3, dan seterusnya (`versionCode` 1, 2, 3, ...).

**Build:** `NDK=/path/android-ndk ./build.sh [cabang-susfs]` (default `gki-android14-6.1`). Hasilnya ada di `out/`.

## English

KernelSU module for kernels patched with SUSFS v2. It combines three sources:

| Part | Source |
|---|---|
| Engine (`ksu_susfs`) | [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu), compiled from source at build time |
| UI (WebUI) and base scripts | [sidex15/susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) |
| Extra features (*brene settings* page) | [rrr333nnn333/BRENE](https://github.com/rrr333nnn333/BRENE) |

- Features found in both SideX and Brene use the SideX version, so no rule is applied twice. That covers uname spoof, AVC log spoofing, hide sus mounts, cmdline spoof, SUSFS log, custom ROM hiding and the custom lists.
- The SideX and Brene system property spoofing is merged into one toggle on the Brene page.
- The binary is not downloaded from the cloud. The module uses the binary shipped in the ZIP.
- Other SUSFS modules (`susfs4ksu`, `brene`, `susfs_manager`) are disabled on install.
- Config is stored in `/data/adb/hybrid_susfs/config.sh`.

**Versions:** 0.1, then 0.2, 0.3 and so on (`versionCode` 1, 2, 3, ...).

**Build:** `NDK=/path/android-ndk ./build.sh [susfs-branch]` (default `gki-android14-6.1`). Output goes to `out/`.

## Lisensi / License

AGPL-3.0, following SideX and Brene. `ksu_susfs` is from simonpunk (GPL-3.0).
