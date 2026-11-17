# 📖 Panduan hybrid_susfs

[← Kembali ke README](../README.md) · <img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> [English](panduan.en.md)

Panduan lengkap: pasang, dan penjelasan **tiap tombol dan toggle** di WebUI beserta fungsinya. Untuk kredit dan cara cek keaslian ZIP, lihat [Keaslian & Kredit](keaslian-dan-kredit.md).

**Daftar isi**
1. [Sebelum mulai](#1-sebelum-mulai)
2. [Pasang & update](#2-pasang--update)
3. [Halaman utama](#3-halaman-utama)
4. [Status Fitur Kernel](#4-status-fitur-kernel-hanya-baca)
5. [Kustom Setelan hybrid_susfs](#5-kustom-setelan-hybrid_susfs)
6. [Kustom daftar & sembunyi lanjutan](#6-kustom-daftar--sembunyi-lanjutan)
7. [Halaman *hybrid_susfs settings*](#7-halaman-hybrid_susfs-settings)
8. [Cadang, impor, reset config](#8-cadang-impor-reset-config)
9. [Uninstall](#9-uninstall)
10. [Masalah & bootloop](#10-masalah--bootloop)

> Aturan umum: makin banyak disembunyikan **bukan** makin aman; kadang malah bikin pola mencolok. Nyalakan sesuai kebutuhan, lalu **uji setelah tiap perubahan**. Banyak toggle baru aktif **setelah reboot**.

---

## 1. Sebelum mulai

- **Root KernelSU** (arm64) terpasang dan jalan.
- **Kernel sudah di-patch SUSFS v2.** Kalau belum, modul menolak dipasang ("Kernel Tidak Didukung").
- Dibuat dan diuji di [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel), tapi jalan di kernel SUSFS v2 lain.

Cuma satu modul SUSFS yang aktif. hybrid_susfs otomatis mematikan `susfs4ksu` (sidex15), `brene`, dan `susfs_manager` saat dipasang.

## 2. Pasang & update

1. Unduh `hybrid_susfs_vX.Y.zip` dari [Rilis](https://github.com/cogan17/hybrid_SusFS/releases).
2. Manager KernelSU → **Modul** → **Pasang dari penyimpanan** → pilih ZIP.
3. **Reboot.**
4. Buka WebUI modul untuk mengatur.

Update berikutnya muncul sebagai tombol di manager KernelSU (`updateJson`). Pasang seperti biasa, reboot.

> ⚠️ Pasang satu modul dulu, reboot, cek HP normal, baru lanjut. Kalau bootloop, abang langsung tahu penyebabnya.

---

## 3. Halaman utama

| Tombol / tampilan | Fungsi |
|---|---|
| **Versi Kernel** | Versi SUSFS yang ada di kernel. Hanya info. |
| **Status Kernel hybrid_susfs** | Apakah mesin SUSFS aktif dan terbaca modul. |
| **SUS PATH / SUS MAPS / SUS MOUNT / TRY UMOUNT** | Penghitung berapa jejak yang sedang disembunyikan, dibaca dari catatan kernel. Angka, bukan daftar aturan aktif. |
| **Kirim Log** | Kumpulkan log modul + identitas build (`MANIFEST.txt`) untuk dibagikan saat ada masalah. Samarkan data pribadi dulu. |
| **Ekspor Konfig** | Simpan semua pengaturan ke satu file backup. |
| **Reset Semua Konfig** | Kembalikan semua pengaturan ke bawaan (minta konfirmasi). |
| **Kustom Setelan hybrid_susfs** | Buka halaman pengaturan inti SUSFS (bagian 5). |

---

## 4. Status Fitur Kernel (hanya baca)

Halaman status menampilkan fitur mana yang **didukung kernel** abang. Ini indikator, bukan toggle; tidak bisa diubah dari sini.

| Fitur | Artinya bila aktif |
|---|---|
| **SUS Path** | Kernel bisa menyembunyikan file/berkas tertentu dari aplikasi. |
| **SUS Maps** | Kernel bisa menyembunyikan entri memory maps (`/proc/*/maps`). |
| **SUS Mount** | Kernel bisa menyembunyikan mount mencurigakan dari daftar mount. |
| **SUS Kstat** | Kernel bisa memalsukan stat file (waktu/ukuran/inode) agar tampak asli. |
| **Try Umount** | Kernel bisa melepas-paksa mount dari pandangan aplikasi. |
| **Spoof Uname** | Kernel bisa memalsukan `uname`. |
| **Spoof Cmdline/Bootconfig** | Kernel bisa memalsukan cmdline/bootconfig boot. |
| **Open Redirect** | Kernel bisa mengalihkan pembacaan path ke file pengganti. |
| **Logging** | Kernel bisa mencatat aktivitas SUSFS. |
| **Auto Default Mount / Auto Bind Mount / Auto Try Umount Bind** | Kernel menangani mount default/bind otomatis. |
| **Hide KSU SUSFS Symbols** | Kernel menyembunyikan simbol KSU/SUSFS dari deteksi. |
| **Magic Mount** | Dukungan magic mount (cara pasang modul). |
| **OverlayFS Auto Kstat** | Stat OverlayFS otomatis dipalsukan. |

---

## 5. Kustom Setelan hybrid_susfs

Pengaturan inti SUSFS (asal SideX). **Perubahan aktif setelah reboot** kecuali disebut lain.

| Toggle / tombol | Fungsi |
|---|---|
| **Log hybrid_susfs** | Nyalakan pencatatan SUSFS. Berguna untuk diagnosa; matikan bila tidak perlu. |
| **SUS SU** | Mode penyembunyian `su`. |
| **SUS SU ada di Mode 1** | Info: SUS SU memakai Mode 1. |
| **SUS SU saat boot** | Terapkan SUS SU otomatis saat boot. |
| **setelan otomatis penyembunyian** | Buka grup toggle auto-hide di bawah. |
| **otomatis sembunyikan mounts default** | Sembunyikan mount default otomatis. |
| **otomatis sembunyikan bind mounts** | Sembunyikan bind mount otomatis. |
| **otomatis try umount bind mounts** | Lepas-paksa bind mount otomatis. |
| **otomatis try umount (userspace)** | Lepas-paksa mount mencurigakan dari userspace. |
| **Lewati Mount Valid** | Jangan sentuh mount yang sah, supaya sistem tidak rusak. |
| **Sembunyikan sus_mounts untuk semua/non-su proses** | Pilih cakupan penyembunyian mount: semua proses, atau hanya non-su. |
| **Matikan setelah boot selesai** | Hentikan sebagian pekerjaan setelah boot kelar, hemat sumber daya. |
| **try umount proses zygote sistem** | Lepas-paksa mount dari proses zygote sistem. |
| **try umount layanan isolasi zygote** | Sama, untuk layanan isolasi zygote. |

### Uname Kernel

Samarkan identitas kernel supaya aplikasi tidak melihat kernel custom.

| Toggle / isian | Fungsi |
|---|---|
| **Spoof Versi Kernel** | Nyalakan pemalsuan versi kernel (`uname -r`). |
| **Spoofed Versi Kernel** | Isi nilai versi kernel yang ditampilkan. Isi persis kernel bawaan HP. |
| **Spoof Kernel Build** | Nyalakan pemalsuan string build kernel. |
| **Spoofed Kernel Build** | Isi nilai string build yang ditampilkan. |
| **Tetapkan Tanggal Bawaan Build Kernel** | Pakai tanggal build kernel bawaan, bukan tanggal kernel custom. |
| **Spoof saat boot** | Terapkan spoof uname saat boot. |
| **Dieksekusi pada post-fs-data (lebih baik dalam spoofing)** | Jalankan spoof lebih awal (post-fs-data) agar lebih kuat. ⚠️ Bisa bootloop bila nilai salah; ada konfirmasi. |

> Nilai spoof harus sama persis dengan kernel bawaan HP. Di Cogan Kernel nilainya ada di [panduan pasang kernel](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/pasang.md).

---

## 6. Kustom daftar & sembunyi lanjutan

Dari halaman *Kustom Setelan*. Untuk pengguna lanjutan; salah isi bisa bikin aplikasi atau boot bermasalah.

| Toggle / tombol | Fungsi |
|---|---|
| **Sembunyikan Custom Rom Path** | Sembunyikan jejak file custom ROM dari aplikasi. |
| **Level Penyembunyian** | Seberapa agresif penyembunyian custom ROM: dari mengecualikan beberapa jenis berkas (.apk/.jar/.odex/.vdex/.so, `/vendor/bin/hw/`) sampai **sembunyikan semua path** (⚠️ berisiko, bisa bikin masalah). |
| **Sembunyikan SEPolicy Vendor** | Sembunyikan perubahan SELinux policy vendor. |
| **Sembunyikan Compat Matrix** | Sembunyikan modifikasi compatibility matrix. |
| **Spoof Daftar Layanan** | Palsukan daftar service sistem. |
| **Sembunyikan GApps** | Sembunyikan jejak modifikasi Google Apps. |
| **Sembunyikan Revanced (YT/YTM)** | Sembunyikan jejak ReVanced YouTube/Music. |
| **Spoof Cmdline** | Palsukan kernel cmdline. |
| **Sembunyikan KSU Loop** | Sembunyikan perangkat loop KernelSU. |
| **Paksa Sembunyikan Mount Dex2oat** | Paksa sembunyikan mount dex2oat. |
| **Spoof AVC Log** | Palsukan AVC/SELinux denial di log agar tidak terbaca mencurigakan. |
| **Emulasikan Isolasi Data Apl Vold** | Tiru isolasi data aplikasi ala vold. |
| **Gunakan sus path loop** | Pakai sus path loop untuk emulasi di atas. |
| **Setelan SUS Path / Loop** | Daftar path yang disembunyikan secara manual. |
| **Kustom SUS Maps / Mount / TRY Umount / Open Redirect** | Daftar manual untuk tiap jenis penyembunyian. |
| **Kustom SUS_KSTAT** (Tambah/Edit entri, Path) | Daftar manual file yang stat-nya dipalsukan. |
| **Impor Konfigurasi** | Pulihkan pengaturan dari file backup (lihat bagian 8). |
| **Cadangkan Konfigurasi Saat Ini** | Buat cadangan sebelum impor, supaya bisa dikembalikan. |

---

## 7. Halaman *hybrid_susfs settings*

Fitur tambahan dari Brene. **Perubahan aktif setelah reboot.**

### Dasar
| Toggle | Fungsi |
|---|---|
| **KernelSU** | Tandai root KernelSU (penyesuaian perilaku). |
| **SU Compat** | Mode kompatibilitas `su`. |
| **Kernel Umount** | Lepas mount di tingkat kernel. |
| **Sembunyikan Modifikasi SELinux** | Sembunyikan jejak perubahan SELinux. |

### Sembunyikan Path
| Toggle | Fungsi |
|---|---|
| **Sembunyikan isi /data/local/tmp** | Sembunyikan file di `/data/local/tmp` (sering dipakai alat root). |
| **Perbaiki kejanggalan /data/local/tmp** | Rapikan ketidakcocokan di folder itu. |
| **Sembunyikan folder Android/ tidak standar** | Sembunyikan folder `Android/` tak lazim di sdcard. |
| **Sembunyikan folder sdcard tidak standar** | Sembunyikan folder sdcard tak lazim. |
| **Sembunyikan folder custom recovery** | Sembunyikan jejak TWRP/recovery custom. |
| **Sembunyikan folder aplikasi root manager** | Sembunyikan folder data manager root. |
| **Sembunyikan /system/addon.d** | Sembunyikan skrip survival `addon.d`. |
| **Sembunyikan PTY mencurigakan** | Sembunyikan terminal PTY yang mencurigakan. |
| **Sembunyikan maps framework-res.apk** | Sembunyikan entri maps `framework-res.apk` yang dimodifikasi. |
| **Sembunyikan injeksi Vector (Xposed)** | Sembunyikan jejak injeksi Vector/Xposed. |

### Filter UID Aplikasi (pendamping HMA-OSS)
| Toggle / tombol | Fungsi |
|---|---|
| **Filter UID aplikasi pihak ketiga** | Batasi syscall prioritas ke aplikasi pihak ketiga. |
| **Filter UID aplikasi user utama (10000–19999)** | Batasi ke aplikasi pengguna utama. Bila dua toggle menyala, mode user utama yang dipakai. |
| **Perbarui filter UID** | Jalankan ulang setelah pasang aplikasi baru, supaya UID-nya ikut. |
| **Cek UID** | Masukkan UID, lihat paket pemiliknya. |

> Filter ini **hanya** menyaring syscall prioritas. **Daftar aplikasi mana yang disembunyikan tetap diatur di HMA-OSS.** Setelah toggle dimatikan, reboot untuk menghapus filter yang sudah diterapkan. Paket tambahan bisa ditulis di `priority_extra_packages.txt`.

### Spoofing
| Toggle | Fungsi |
|---|---|
| **Spoof system properties** | Palsukan properti sistem (gabungan SideX + Brene jadi satu). |
| **Spoof security patch OS** | Palsukan tanggal patch keamanan OS. |
| **Spoof security patch vendor** | Palsukan tanggal patch keamanan vendor. |
| **Sembunyikan tombol OEM unlocking** | Sembunyikan status OEM unlocking. |
| **Hapus prop custom ROM** | Buang properti yang membocorkan custom ROM. |
| **Hapus prop Play Integrity Fix (permanen)** | Buang properti PIF secara permanen. |
| **Sembunyikan teks LineageOS** | Sembunyikan string khas LineageOS. |
| **Spoof /system/etc/hosts** | Palsukan file hosts. |

### Android
| Toggle | Fungsi |
|---|---|
| **Matikan Opsi developer saat boot** | Matikan Opsi pengembang tiap boot. |
| **Matikan USB debugging saat boot** | Matikan USB debugging tiap boot. |
| **Matikan Wireless debugging saat boot** | Matikan wireless debugging tiap boot. |
| **Matikan batasan child process** | Lepas batasan child process (untuk sebagian alat). |
| **Buffer logcat 64K** | Perbesar buffer logcat ke 64K. |
| **Saturasi maksimal** | Setel saturasi layar maksimal (tampilan). |
| **Tampilkan refresh rate** | Tampilkan refresh rate di layar. |

---

## 8. Cadang, impor, reset config

- **Ekspor Konfig**: simpan semua pengaturan ke satu file backup.
- **Impor Konfigurasi**: pulihkan dari backup (termasuk backup versi sebelumnya). **Menimpa setelan saat ini** (ada konfirmasi). File diperiksa ketat; kalau rusak, impor dibatalkan tanpa mengubah apa pun. Pakai **Cadangkan Konfigurasi Saat Ini** sebelum impor untuk jaga-jaga.
- **Reset Semua Konfig**: kembalikan ke bawaan.

Config tersimpan di `/data/adb/hybrid_susfs/config.sh`. Jangan diedit tangan kecuali paham isinya; WebUI membaca config sebagai data dengan skema, bukan skrip.

## 9. Uninstall

Manager KernelSU → **Modul** → hybrid_susfs → **Hapus** → **Reboot**.

Alat `ksu_susfs` lama hanya dikembalikan ke path yang kosong, jadi tidak menimpa milik modul SUSFS lain.

---

## 10. Masalah & bootloop

- **Tidak bisa klik tombol / WebUI kosong**: tutup dan buka lagi WebUI. Tetap bermasalah → kirim log.
- **Kirim Log**: tombol di halaman utama. Log memuat `MANIFEST.txt` supaya bisa dicocokkan dengan ZIP. **Samarkan data pribadi sebelum membagikan.** Kirim ke [grup Telegram](https://t.me/coganTWRP).

### Pemulihan bootloop

hybrid_susfs tidak menyentuh data dan tidak mengubah partisi boot, jadi bootloop dari modul bisa dipulihkan tanpa wipe:

1. Pakai pelindung bootloop (mis. AshReXcue) bila terpasang, atau mode pemulihan root manager.
2. Atau lewat ADB/recovery, buat penanda nonaktif `/data/adb/modules/hybrid_susfs/disable`, lalu reboot. Modul tidak jalan di boot itu.
3. Masih bootloop? Berarti bukan dari modul ini. Lihat [kembali ke stok Cogan Kernel](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/kembali-ke-stok.md) atau pulihkan `boot` stok.

> Penyebab bootloop paling sering di sini: **Dieksekusi pada post-fs-data** dengan nilai spoof uname yang salah. Kalau ragu, matikan dulu toggle itu.
