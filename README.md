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

SUSFS sidex15 dan BRENE dua-duanya bagus, tapi tidak bisa dipasang bareng, harus pilih salah satu. hybrid_susfs menggabungkan keduanya: mesin dari simonpunk, tampilan dari sidex15, fitur tambahan dari BRENE. Satu modul, tidak perlu pilih.

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

Di tab Actions: **hybrid_susfs Builder** untuk build, **Rilis dari run** untuk menerbitkan build yang sudah diuji, **Cek pembaruan** untuk melihat ada yang baru di sidex15, BRENE dan simonpunk. **Validate** jalan sendiri di setiap PR.

</details>

<details>
<summary><b>Sudah diuji</b></summary>

| Versi | Hasil |
|---|---|
| v0.7 | ⏳ Menunggu uji HP. Perbaikan audit: add_sus_mount v2, filter UID literal, status gagal, gate rilis |
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
