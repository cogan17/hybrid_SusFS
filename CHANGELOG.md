# Changelog

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
