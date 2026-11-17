# 📖 Panduan hybrid_susfs

[← Kembali ke README](../README.md) · <img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> [English](panduan.en.md)

Panduan lengkap: pasang, atur, cadangkan, dan pulihkan hybrid_susfs. Untuk kredit dan cara cek keaslian ZIP, lihat [Keaslian & Kredit](keaslian-dan-kredit.md).

---

## Sebelum mulai

- **Root KernelSU** (arm64) sudah terpasang dan jalan.
- **Kernel sudah di-patch SUSFS v2.** Kalau belum, modul menolak dipasang dengan pesan "Kernel Tidak Didukung". Cek cepat: buka WebUI modul SUSFS mana pun, atau lihat versi kernel memuat tanda SUSFS.
- Modul ini dibuat dan diuji di [Cogan Kernel](https://github.com/cogan17/Cogan-Kernel) (Xiaomi 14T Pro), tapi jalan di kernel SUSFS v2 lain.

Cuma punya satu modul SUSFS yang aktif. hybrid_susfs otomatis mematikan `susfs4ksu` (sidex15), `brene`, dan `susfs_manager` saat dipasang, jadi tidak perlu uninstall dulu.

## 1. Pasang

1. Unduh `hybrid_susfs_vX.Y.zip` dari [Rilis](https://github.com/cogan17/hybrid_SusFS/releases).
2. Manager KernelSU → **Modul** → **Pasang dari penyimpanan** → pilih ZIP.
3. **Reboot.**
4. Buka WebUI modul (tombol di kartu modul) untuk mengatur.

Update berikutnya muncul sebagai tombol di manager KernelSU (`updateJson`). Pasang seperti biasa, lalu reboot.

> ⚠️ Pasang satu modul dulu, reboot, cek HP normal, baru pasang modul lain. Kalau bootloop, abang langsung tahu penyebabnya. Pemulihan bootloop ada di [bawah](#pemulihan-bootloop).

## 2. Halaman utama WebUI

| Yang tampil | Arti |
|---|---|
| **Versi Kernel** + **Status Kernel** | Versi SUSFS kernel dan apakah mesin aktif |
| **SUS PATH / SUS MAPS / SUS MOUNT / TRY UMOUNT** | Jumlah jejak yang sedang disembunyikan (dari catatan kernel) |
| **Kernel Uname** | Samarkan `uname` kernel. Isi nilai kernel bawaan HP supaya aplikasi tidak melihat nama kernel custom |
| **auto try umount (userspace)** | Lepas-paksa mount mencurigakan dari userspace |
| **Kirim Log** | Kumpulkan log untuk dikirim saat ada masalah (lihat [Masalah](#masalah)) |
| **Kustom Setelan hybrid_susfs** | Buka halaman fitur tambahan (bagian 3) |

> Spoof `uname`: aplikasi biasa umumnya hanya bisa membaca `uname`. Isi persis seperti kernel bawaan HP. Di Cogan Kernel, nilainya ada di [panduan pasang kernel](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/pasang.md).

## 3. Halaman *hybrid_susfs settings*

Fitur tambahan, dikelompokkan. Nyalakan sesuai kebutuhan; makin banyak disembunyikan bukan berarti makin aman, kadang malah bikin pola yang mencolok. Uji setelah tiap perubahan.

**Sembunyikan jejak (Hide Paths)**
- Hide /data/local/tmp items, Hide non-standard Android/ & sdcard folders
- Hide custom recovery folders, Hide root manager app folders
- Hide /system/addon.d, Hide suspicious PTYs
- Hide framework-res.apk maps, Hide Vector (Xposed) injection
- Hide SELinux Modification, Kernel Umount

**App UID Filter** (pendamping HMA-OSS)
- **Main-user app UID filter (10000–19999)**: batasi syscall prioritas ke aplikasi pengguna utama.
- **Refresh UID filter**: jalankan lagi setelah pasang aplikasi baru, supaya UID-nya ikut.
- **Check UID**: masukkan UID, lihat paket mana pemiliknya.
- Paket tambahan bisa ditulis di `priority_extra_packages.txt`.
- Daftar **aplikasi mana yang disembunyikan** tetap diatur di **HMA-OSS**, bukan di sini. Filter ini hanya soal syscall prioritas.

**Spoofing**
- **Spoof system properties** (gabungan SideX + Brene jadi satu tombol)
- Spoof OS / vendor security patch, Spoof /system/etc/hosts
- Remove custom ROM props, Logcat buffer 64K

## 4. Cadangkan & pulihkan config

- **Ekspor Konfig**: simpan semua pengaturan ke satu file backup.
- **Impor Konfig**: pulihkan dari file backup (termasuk backup versi sebelumnya). File diperiksa ketat; kalau rusak, impor dibatalkan tanpa mengubah apa pun.
- **Reset Semua Konfig**: kembalikan ke bawaan.

Config tersimpan di `/data/adb/hybrid_susfs/config.sh`. Jangan diedit tangan kecuali paham isinya; WebUI membaca config sebagai data dengan skema, bukan skrip.

## 5. Uninstall

Manager KernelSU → **Modul** → hybrid_susfs → **Hapus** → **Reboot**.

Alat `ksu_susfs` yang lama hanya dikembalikan ke path yang kosong, jadi tidak menimpa milik modul SUSFS lain yang mungkin abang pasang setelahnya.

---

## Masalah

- **Tidak bisa klik tombol / WebUI kosong**: tutup dan buka lagi WebUI. Kalau tetap, kirim log.
- **Kirim Log**: tombol di halaman utama. Log memuat identitas build (`MANIFEST.txt`) supaya bisa dicocokkan dengan ZIP. **Samarkan dulu data pribadi sebelum membagikan log.**
- Kirim log ke [grup Telegram](https://t.me/coganTWRP).

### Pemulihan bootloop

hybrid_susfs tidak menyentuh data dan tidak mengubah partisi boot, jadi bootloop dari modul bisa dipulihkan tanpa wipe:

1. Masuk ke mode pemulihan root manager, atau sentuh tombol volume saat boot sesuai pelindung bootloop (mis. AshReXcue) bila terpasang.
2. Atau lewat ADB/recovery, buat penanda nonaktif: `/data/adb/modules/hybrid_susfs/disable`, lalu reboot. Modul tidak jalan di boot itu.
3. Masih bootloop? Berarti bukan dari modul ini. Lihat [kembali ke stok Cogan Kernel](https://github.com/cogan17/Cogan-Kernel/blob/main/docs/kembali-ke-stok.md) atau pulihkan `boot` stok.
