<h1 align="center">hybrid_susfs</h1>

<p align="center">
  Modul SUSFS untuk KernelSU &nbsp;·&nbsp; saudara dari <a href="https://github.com/cogan17/Cogan-Kernel">Cogan Kernel</a>
</p>

<p align="center">
  <b><img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> Bahasa Indonesia</b> &nbsp;·&nbsp; <a href="README.en.md"><img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> English</a>
</p>

<p align="center">
  <a href="https://github.com/cogan17/hybrid_SusFS/releases"><b>⬇️ Unduh</b></a>
  &nbsp;·&nbsp;
  <a href="docs/panduan.md"><b>📖 Panduan</b></a>
  &nbsp;·&nbsp;
  <a href="CHANGELOG.md"><b>📝 Catatan Rilis</b></a>
  &nbsp;·&nbsp;
  <a href="https://t.me/coganTWRP"><b>💬 Telegram</b></a>
</p>

> [!WARNING]
> Jika terjadi bootloop atau brick, bukan tanggung jawab maintainer/developer. Pemilik device bertanggung jawab atas devicenya sendiri! Harap cadangkan datamu.

## Apa itu hybrid_susfs?

Kalau HP-mu sudah di-root (KernelSU) atau pakai kernel custom, sebagian aplikasi bisa mendeteksinya lalu menolak jalan, membatasi fitur, atau memblokir akun — misalnya aplikasi bank, dompet digital, game, atau streaming.

**SUSFS** adalah fitur di dalam kernel yang menyembunyikan jejak-jejak itu dari aplikasi: file, folder, titik *mount*, dan info kernel yang biasa dipakai aplikasi untuk menebak HP sudah dimodifikasi. **hybrid_susfs adalah modul pengatur SUSFS** — dialah yang memberi tahu kernel apa saja yang harus disembunyikan, lewat WebUI yang mudah dipakai. Jadi kamu tidak perlu mengetik perintah; cukup nyalakan/matikan lewat tombol.

**Kenapa "hybrid"?** Ada dua modul SUSFS populer, **SideX** (sidex15) dan **BRENE**, masing-masing punya kelebihan tapi tidak bisa dipasang bersamaan — harus pilih salah satu. hybrid_susfs menggabungkan ketiga sumber jadi satu modul:
- 🔧 **Mesin** dari **simonpunk** — inti SUSFS, selalu diambil versi terbaru saat build.
- 🎨 **Tampilan** dari **SideX** — WebUI rapi dan lengkap untuk mengatur semuanya.
- ✨ **Fitur tambahan** dari **BRENE** — samarkan properti sistem, sembunyikan jejak custom ROM, recovery, Xposed, dan lainnya.

Dapat yang terbaik dari ketiganya dalam satu modul, tanpa harus memilih dan tanpa bentrok.

**Biar tidak salah harap:**
- hybrid_susfs bekerja di **tingkat file, mount, dan kernel**. Ia **tidak menyembunyikan daftar aplikasi terpasang** — itu tugas modul lain seperti **HMA-OSS**, dan keduanya biasa dipakai bersama. hybrid_susfs punya *filter UID* sebagai pendamping HMA-OSS, bukan pengganti.
- **Tidak ada modul yang menjamin lolos semua detektor.** Aplikasi pendeteksi root terus berkembang, jadi ini kucing-kucingan yang tidak pernah "selesai". hybrid_susfs menutup jalur umum berbasis file/mount/kernel dan terus diperbarui — itulah kenapa rilisnya selalu *pre-release*.
- Ini **bukan** alat untuk menipu layanan yang mengecek lewat chip keamanan HP (Play Integrity tingkat *hardware*/TEE); yang itu di luar jangkauan SUSFS.

Dibuat dan diuji di [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel) (Xiaomi 14T Pro), tapi harusnya jalan juga di kernel lain yang sudah ada SUSFS v2.

<p align="center">
  <img src="docs/preview/index.png" width="45%" alt="Halaman utama">
  &nbsp;
  <img src="docs/preview/brene.png" width="45%" alt="Halaman hybrid_susfs settings">
</p>

## Pasang

Butuh KernelSU dan kernel dengan SUSFS v2. Kalau belum ada, modul menolak dipasang.

1. Unduh ZIP dari [Rilis](https://github.com/cogan17/hybrid_SusFS/releases).
2. Pasang di manager KernelSU, reboot.
3. Atur lewat WebUI modul. Penjelasan tiap fitur ada di [Panduan lengkap](docs/panduan.md).

Update berikutnya muncul langsung di manager.

Pindah dari modul SUSFS lain? Tidak perlu uninstall dulu. SUSFS sidex15, BRENE dan susfs_manager otomatis dimatikan waktu hybrid_susfs dipasang.

Ada masalah? Tekan **Send Logs** di WebUI, kirim lognya ke grup Telegram.

<details>
<summary><b>Apa saja yang diambil dari mana</b></summary>

| | Dari |
|---|---|
| Mesin `ksu_susfs` | [simonpunk](https://gitlab.com/simonpunk/susfs4ksu), di-compile ulang setiap build |
| WebUI dan skrip dasar | [sidex15](https://github.com/sidex15/susfs4ksu-module) |
| Halaman *hybrid_susfs settings* | [BRENE](https://github.com/rrr333nnn333/BRENE) |

Fitur yang ada di sidex15 dan BRENE sekaligus (spoof uname, cmdline, AVC log, hide sus mounts, hide custom ROM) cukup jalan sekali, pakai versi sidex15. Spoof properti dari keduanya digabung jadi satu tombol.

Ada juga tambahan sendiri: filter UID untuk dipakai bareng HMA-OSS, plus tombol **Cek UID** untuk tahu UID itu milik aplikasi apa.

</details>

<details>
<summary><b>Update</b></summary>

Mesin simonpunk selalu ikut versi terbaru setiap build. Kalau simonpunk menghapus perintah yang dipakai modul, build berhenti sampai modul disesuaikan.

Perubahan dari sidex15 dan BRENE tidak ikut otomatis. Dicek dulu, yang berguna baru diambil.

</details>

<details>
<summary><b>Untuk yang mau build sendiri</b></summary>

```
NDK=/path/android-ndk ./build.sh
```

Hasilnya di `out/`. Versi di `module/module.prop`, `update.json` dan `CHANGELOG.md` harus sama, kalau tidak build berhenti.

Di tab Actions: **hybrid_susfs Builder** untuk build, **Rilis dari run** untuk menerbitkan build yang sudah diuji, **Cek pembaruan** untuk melihat ada yang baru di sidex15, BRENE dan simonpunk. **Validate** jalan sendiri di setiap PR. Builder punya isian opsional `engine_commit` untuk mundur ke commit engine simonpunk tertentu (kosong = terbaru).

</details>

<details>
<summary><b>Sudah diuji</b></summary>

| Versi | Hasil |
|---|---|
| v0.11 | ✅ 20 Nov 2026, diuji di HP. App VD: `/data/adb` tidak terlihat lagi (root_dirs_present & synth_paradox → MATCH), manager tetap jalan |
| v0.10 | ✅ 19 Nov 2026, diuji di HP. Duck Detector: `Shell tmp inode` tidak muncul lagi (spoof /data/local/tmp dijaga sampai reboot) |
| v0.9 | ✅ 18 Nov 2026, diuji di HP (install+update, tidak bootloop). Perbaikan audit v0.8 |
| v0.8 | ✅ 18 Nov 2026, diuji di HP. Diagnostik inode /data/local/tmp; Duck Native Root → INFO (inode 100) |
| v0.7 | ✅ 17 Nov 2026, diuji di HP. Perbaikan audit: add_sus_mount v2, filter UID literal, status gagal, gate rilis, opsi engine_commit |
| v0.6 | ✅ 17 Nov 2026, diuji di HP. Perbaikan overlap SELinux (SEPolicy Vendor vs teks LineageOS) |
| v0.5 | ✅ 17 Nov 2026, Cogan Kernel di 14T Pro, SUSFS v2.4.0. Duck Detector: Danger 0, Warning 0 |
| v0.4 (ditarik) | Diganti v0.5 (isi sama, kini bertanda tangan) |

</details>

---

<p align="center">
  <b>Cogan17</b> &nbsp;·&nbsp; terima kasih untuk <b>simonpunk</b>, <b>sidex15</b> dan <b>rrr333nnn333</b>
  <br>AGPL-3.0 &nbsp;·&nbsp; <code>ksu_susfs</code> GPL-3.0 (simonpunk)
  <br><a href="docs/keaslian-dan-kredit.md">🔏 Keaslian & kredit lengkap</a>
</p>

<sub>Repo saudara: [Cogan-Kernel](https://github.com/cogan17/Cogan-Kernel) · [CoganSU](https://github.com/cogan17/CoganSU) · [TWRP-14T-PRO](https://github.com/cogan17/TWRP-14T-PRO)</sub>
