# Changelog

## v0.14

- 🇮🇩 **Membersihkan sisa penanda mode-tes v0.12.** Metode `device_config` di v0.12 memasang `set_sync_disabled_for_tests persistent` dan `max_phantom_processes` yang bertahan lintas reboot; v0.13 hanya berhenti memasang, tidak menghapus. v0.14 mengembalikannya ke default saat boot. (Naik ke v0.14 untuk membedakan dari dua build v0.13 yang sempat beredar.)
- 🇬🇧 **Cleans up the v0.12 test-mode marker.** The `device_config` method in v0.12 set `set_sync_disabled_for_tests persistent` and `max_phantom_processes`, which survive reboots; v0.13 only stopped setting them, without removing. v0.14 resets them to default at boot. (Bumped to v0.14 to distinguish from the two v0.13 builds that circulated.)

## v0.13

- 🇮🇩 **Perbaikan regresi v0.12.** Metode `device_config` untuk menonaktifkan phantom process dikembalikan ke cara lama (prop di memori) yang jejaknya lebih kecil. Menyembunyikan phantom tidak bisa sepenuhnya tak terlihat di semua detektor.
- 🇬🇧 **Fixes a v0.12 regression.** The `device_config` method for disabling phantom process monitoring was reverted to the old in-memory prop method, which leaves a smaller footprint. Hiding phantom cannot be fully invisible to every detector.

## v0.12

- 🇮🇩 Fitur **Nonaktifkan batasan proses anak** (phantom process) sekarang pakai cara yang tidak meninggalkan jejak terbaca detektor. Sebelumnya memasang prop `persist.sys.fflag.override...` yang ditandai App VD (phantom_monitor); sekarang lewat `device_config` yang tidak diperiksa. Fungsi tetap sama (proses latar belakang tidak dibunuh), hanya caranya lebih senyap.
- 🇬🇧 The **Disable child process restrictions** (phantom process) feature now uses a method that leaves no detector-readable trace. It previously set a `persist.sys.fflag.override...` prop that App VD flagged (phantom_monitor); it now goes through `device_config`, which is not probed. Same effect (background processes are not killed), just quieter.

## v0.11

- 🇮🇩 Toggle baru **Sembunyikan /data/adb** (default mati) untuk melewati detektor yang menandai folder root `/data/adb` yang masih terlihat aplikasi. **Wajib diuji dulu:** setelah dinyalakan, pastikan app manager (KernelSU/SukiSU dll.) masih bisa membuka daftar modul & WebUI. Kalau paket manager kamu diacak/di-rename, atau kernel tidak mendukungnya, penyembunyian otomatis dibatalkan supaya manager tidak ikut buta.
- 🇬🇧 New **Hide /data/adb** toggle (off by default) to pass detectors that flag the still-visible `/data/adb` root folder. **Test it first:** after turning it on, make sure your manager app (KernelSU/SukiSU, etc.) can still open the module list and WebUI. If your manager package is randomized/renamed, or the kernel lacks support, the hiding is cancelled automatically so the manager does not go blind.

## v0.10

- 🇮🇩 **Perbaiki kejanggalan /data/local/tmp** tidak lagi "lepas" setelah HP lama menyala. Sebelumnya penyamaran folder ini bisa hilang sendiri (misalnya saat RAM penuh) sehingga Duck Detector kembali memberi peringatan **Shell tmp inode**. Sekarang modul menjaganya sampai reboot, dan memasang ulang bila folder itu dihapus lalu dibuat lagi.
- 🇬🇧 **Fix /data/local/tmp inconsistencies** no longer "wears off" after the phone has been on for a while. Previously the disguise on this folder could drop by itself (e.g. under memory pressure), so Duck Detector showed the **Shell tmp inode** warning again. The module now keeps it in place until reboot, and reapplies it if the folder is deleted and recreated.

## v0.9

- 🇮🇩 Pemasangan lebih aman: kalau penyiapan pengaturan gagal (misalnya penyimpanan penuh), modul berhenti dan memberi tahu, tidak lagi pura-pura berhasil padahal belum. Filter UID dan tombol **Cek UID** juga lebih jujur melaporkan kalau ada yang gagal.
- 🇬🇧 Safer install: if preparing the settings fails (e.g. storage is full), the module stops and tells you instead of pretending it worked. The UID filter and the **Check UID** button now report failures honestly too.

## v0.8

- 🇮🇩 Menambah catatan di log untuk fitur **Perbaiki kejanggalan /data/local/tmp**, supaya lebih mudah menelusuri kalau ada masalah. Cara kerja penyembunyian tidak berubah.
- 🇬🇧 Added a log note for the **Fix /data/local/tmp** feature so problems are easier to trace. Hiding behaviour is unchanged.

## v0.7

- 🇮🇩 Perbaikan kestabilan filter UID dan penyembunyian SELinux (SEPolicy Vendor / Compat Matrix) pada kernel SUSFS v2. Rilis utama (**Latest**) sekarang wajib sudah diuji di HP dulu.
- 🇬🇧 Stability fixes for the UID filter and SELinux hiding (Vendor SEPolicy / Compat Matrix) on SUSFS v2 kernels. A main (**Latest**) release now requires a phone test first.
- 🇮🇩 Untuk pembuat build: ada pilihan memakai versi mesin simonpunk tertentu bila yang terbaru bermasalah.
- 🇬🇧 For builders: an option to use a specific simonpunk engine version if the latest one misbehaves.

## v0.6

- 🇮🇩 Menghilangkan tumpang tindih: **Sembunyikan SEPolicy Vendor** dan **Sembunyikan teks LineageOS** tidak lagi menangani berkas yang sama dua kali — lebih rapi dan aman.
- 🇬🇧 Removed an overlap: **Hide Vendor SEPolicy** and **Hide LineageOS strings** no longer handle the same files twice — cleaner and safer.

## v0.5

- 🇮🇩 ZIP sekarang **ditandatangani secara digital**, jadi keasliannya bisa dibuktikan (lihat [Keaslian & Kredit](docs/keaslian-dan-kredit.md)). Isinya sama dengan v0.4; v0.4 ditarik supaya semua memakai versi bertanda tangan.
- 🇬🇧 The ZIP is now **digitally signed**, so its authenticity can be proven (see [Authenticity & Credits](docs/keaslian-dan-kredit.en.md)). Contents are the same as v0.4; v0.4 was withdrawn so everyone uses the signed build.

## v0.4

- 🇮🇩 Filter UID (pendamping HMA-OSS) dirapikan jadi satu tombol, dan hasilnya tercatat di **Send Logs**. Visibilitas aplikasi tetap diatur di HMA-OSS.
- 🇬🇧 The UID filter (HMA-OSS companion) is simplified to a single toggle, and its result is saved in **Send Logs**. App visibility is still configured in HMA-OSS.
- 🇮🇩 Tombol baru **Perbarui filter UID** (untuk aplikasi yang baru dipasang) dan **Cek UID** (lihat UID milik aplikasi apa).
- 🇬🇧 New **Refresh UID filter** (for newly installed apps) and **Check UID** (see which app a UID belongs to) buttons.
- 🇮🇩 Install ulang tidak lagi menghapus cadangan pemulihan dari install yang gagal.
- 🇬🇧 Reinstalling no longer deletes the recovery backup from a failed install.

## v0.3

- 🇮🇩 Uninstall lebih aman: tidak menyentuh alat `ksu_susfs` yang sudah dipakai modul SUSFS lain.
- 🇬🇧 Safer uninstall: it won't touch the `ksu_susfs` tool once another SUSFS module uses it.
- 🇮🇩 Install yang gagal memulihkan keadaan sebelumnya dan melapor jujur kalau belum lengkap.
- 🇬🇧 A failed install restores the previous state and reports honestly if it's incomplete.
- 🇮🇩 Beberapa perbaikan kecil: angka statistik lebih akurat, dan deskripsi modul menampilkan "menunggu HP dibuka kunci" saat penyimpanan belum siap.
- 🇬🇧 Several small fixes: more accurate stats counts, and the module description shows "waiting for unlock" while storage isn't ready.

## v0.2

- 🇮🇩 Keamanan diperkuat: pengaturan dibaca sebagai data (bukan dijalankan sebagai skrip), dan impor backup diperiksa ketat sebelum diterapkan.
- 🇬🇧 Security hardened: settings are read as data (not run as a script), and backup import is strictly checked before it's applied.
- 🇮🇩 Backup dari **Export** kini bisa dipulihkan lewat **Import**, termasuk backup dari versi sebelumnya.
- 🇬🇧 Backups made with **Export** can now be restored with **Import**, including backups from an older version.
- 🇮🇩 Install/update lebih aman: kalau gagal, keadaan lama dikembalikan utuh; update di atas versi lama tidak lagi gagal. Keluar WebUI cukup sekali tekan kembali.
- 🇬🇧 Safer install/update: on failure the old state is fully restored; updating over an old version no longer fails. One back gesture exits the WebUI.
- 🇮🇩 Folder aplikasi root manager kini disembunyikan, bukan dihapus.
- 🇬🇧 Root manager app folders are now hidden, not deleted.

## v0.1

- 🇮🇩 Versi pertama: mesin SUSFS simonpunk, tampilan SideX, fitur tambahan dari Brene. Tidak dirilis.
- 🇬🇧 First version: simonpunk SUSFS engine, SideX UI, extra features from Brene. Not released.
