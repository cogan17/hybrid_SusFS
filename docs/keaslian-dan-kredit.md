# 🔏 Keaslian & Kredit

[← Kembali ke README](../README.md) · <img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> [English](keaslian-dan-kredit.en.md)

hybrid_susfs dibangun otomatis oleh GitHub Actions di **[cogan17/hybrid_SusFS](https://github.com/cogan17/hybrid_SusFS)**, repo saudara [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel). Mulai build sesudah v0.4, ZIP modul **ditandatangani secara digital** (artifact attestation) oleh workflow Builder repo ini, jadi siapa pun bisa membuktikan asal-usulnya.

> Yang dibuktikan adalah **ZIP hybrid_susfs ini** dibuat oleh Cogan17. Mesin SUSFS, WebUI dan fitur-fitur di dalamnya adalah karya para kontributor di [Kredit](#-kredit).

---

## Cara cek keaslian

1. **Halaman bukti:** [github.com/cogan17/hybrid_SusFS/attestations](https://github.com/cogan17/hybrid_SusFS/attestations).
2. **Lewat GitHub CLI:**
   ```
   gh attestation verify hybrid_susfs_vX.Y.zip --repo cogan17/hybrid_SusFS
   ```
   Hanya ZIP asli yang lolos.
3. **SHA256 di catatan rilis:** setiap rilis menulis SHA256 ZIP-nya dan tautan run build. Cocokkan dengan `sha256sum hybrid_susfs_vX.Y.zip`. Ini satu-satunya cara cek untuk **v0.4**, yang terbit sebelum tanda tangan dipasang.
4. **Halaman run di [Actions](https://github.com/cogan17/hybrid_SusFS/actions):** tiap build menampilkan versi SUSFS simonpunk yang dipakai dan SHA256 ZIP-nya.
5. **Di HP:** tombol action modul menampilkan baris **Build** (commit repo saat dibangun). Isi lengkapnya ada di `/data/adb/modules/hybrid_susfs/MANIFEST.txt`: versi, commit repo, commit SUSFS, dan SHA256 setiap file di modul. File ini juga ikut di **Send Logs**.

## Apa yang dibuktikan, dan tidak

| Kalau ada yang… | Hasilnya |
|---|---|
| menyebar ulang ZIP lalu mengaku buatannya | ✅ terbantah: sidik jarinya cocok dengan tanda tangan repo Cogan17 |
| mengubah ZIP sedikit (mis. ganti nama di `module.prop`) | ✅ ketahuan: jadi file lain, tidak lolos verifikasi; SHA256 di `MANIFEST.txt` juga tidak cocok |
| fork repo lalu build sendiri | ✅ tanda tangan mereka menyebut **repo mereka**; riwayat commit bertanggal di repo ini membuktikan siapa yang lebih dulu |
| menyalin kodenya | tidak dicegah (AGPL-3.0, proyek terbuka), tapi asal-usulnya tetap bisa dibuktikan |

---

## 🙏 Kredit

| Siapa | Kontribusi |
|---|---|
| **[Cogan17](https://github.com/cogan17)** | Maintainer: penggabungan, halaman *hybrid_susfs settings*, filter UID, install/uninstall yang aman, build, CI dan rilis |
| **[SUSFS](https://gitlab.com/simonpunk/susfs4ksu)** ([simonpunk](https://gitlab.com/simonpunk)) | Mesin: patch kernel SUSFS dan alat `ksu_susfs`, di-compile dari source setiap build (GPL-3.0) |
| **[susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module)** ([sidex15](https://github.com/sidex15)) | WebUI dan skrip dasar modul (AGPL-3.0) |
| Kontributor dan penerjemah susfs4ksu-module | Ikut di WebUI (halaman *Credits*): backslashxx, chisewaguri, 0x11DFE, cvnertnc, rifsxd, mehu3dhokia, dan para penerjemah |
| **[BRENE](https://github.com/rrr333nnn333/BRENE)** ([rrr333nnn333](https://github.com/rrr333nnn333)) | Fitur tambahan di halaman *hybrid_susfs settings* (AGPL-3.0) |
| **[KernelSU](https://github.com/tiann/KernelSU)** ([tiann](https://github.com/tiann)) | Sistem modul dan WebUI tempat hybrid_susfs berjalan |
| **[HMA-OSS](https://github.com/frknkrc44/HMA-OSS)** ([frknkrc44](https://github.com/frknkrc44)) | Pasangan filter UID; daftar aplikasi tetap diatur di HMA-OSS |
| **[Android NDK](https://developer.android.com/ndk)** (Google) | Compiler `ksu_susfs` |
| **[Cogan Kernel](https://github.com/cogan17/Cogan-Kernel)** | Kernel tempat modul diuji; gaya workflow (Builder, Rilis dari run, Validate) dan README |

Proyek saudara: **[Cogan Kernel](https://github.com/cogan17/Cogan-Kernel)** · **[CoganSU](https://github.com/cogan17/CoganSU)** · **[TWRP Xiaomi 14T Pro](https://github.com/cogan17/TWRP-14T-PRO)**.
