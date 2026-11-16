# Changelog

## v0.4

- 🇮🇩 Filter UID (pendamping HMA-OSS) kini satu pintu: satu mode, satu perintah, daftar divalidasi sebelum dikirim, HMA-OSS ikut disertakan, status tersimpan di Send Logs. Label menjelaskan cakupannya: hanya syscall prioritas; visibilitas aplikasi tetap diatur di HMA-OSS.
- 🇬🇧 The UID filter (HMA-OSS companion) now has one entry point: one mode, one command, the list is validated before sending, HMA-OSS is included, and the status is saved in Send Logs. Labels state its scope: priority syscalls only; app visibility is still configured in HMA-OSS.
- 🇮🇩 Tombol "Perbarui filter UID" (untuk aplikasi yang baru dipasang) dan "Cek UID" (memetakan UID ke nama paket) di halaman hybrid_susfs settings dan tombol action; paket tambahan bisa ditulis di `priority_extra_packages.txt`.
- 🇬🇧 "Refresh UID filter" (for newly installed apps) and "Check UID" (maps a UID to its package) buttons on the hybrid_susfs settings page and the action button; extra packages can be listed in `priority_extra_packages.txt`.
- 🇮🇩 Install ulang tidak lagi menghapus snapshot pemulihan dari install yang gagal.
- 🇬🇧 Reinstalling no longer deletes the recovery snapshot left by a failed install.

## v0.3

- 🇮🇩 Uninstall tidak lagi menyentuh `ksu_susfs`/`susfs` yang sudah menjadi milik modul lain; cadangan hanya dipulihkan ke path yang kosong.
- 🇬🇧 Uninstall no longer touches `ksu_susfs`/`susfs` once another module owns them; backups are only restored to empty paths.
- 🇮🇩 Data kstat dibaca sama persis oleh boot dan WebUI: key ganda dan angka seperti `01` ditolak.
- 🇬🇧 kstat data is read identically by boot and WebUI: duplicate keys and numbers like `01` are rejected.
- 🇮🇩 Install yang gagal memverifikasi pemulihannya dan melapor jujur bila tidak lengkap (snapshot di `/data/adb/hybrid_susfs.txn`); pratinjau WebUI sebelum reboot tidak lagi bisa tersarang.
- 🇬🇧 A failed install verifies its restore and reports honestly if incomplete (snapshot in `/data/adb/hybrid_susfs.txn`); the pre-reboot WebUI preview can no longer end up nested.
- 🇮🇩 Peringatan config tidak sah tetap tercatat di log; deskripsi modul menampilkan "menunggu HP dibuka kunci" selama storage belum siap; keterangan sumber angka statistik di WebUI.
- 🇬🇧 Invalid-config warnings stay in the log; the module description shows "waiting for unlock" while storage is not ready; the WebUI explains where the stats come from.

## v0.2

- 🇮🇩 Keamanan: config dibaca sebagai data dengan skema per pengaturan (tidak lagi dijalankan sebagai skrip); impor backup diperiksa ketat dan bisa dibatalkan; semua nilai yang masuk ke perintah WebUI di-escape, termasuk pemilih folder.
- 🇬🇧 Security: config is read as data with a per-setting schema (no longer run as a script); backup import is strictly checked and rolls back on failure; every value passed to WebUI commands is escaped, including the folder picker.
- 🇮🇩 Backup dari Export WebUI kini bisa dipulihkan lewat Import, termasuk backup buatan versi sebelumnya.
- 🇬🇧 Backups made with WebUI Export can now be restored with Import, including backups from the previous version.
- 🇮🇩 Install/update aman: bila gagal, keadaan sebelumnya dikembalikan persis; update di atas versi lama tidak lagi gagal.
- 🇬🇧 Safe install/update: on failure the previous state is restored exactly; updating over the previous version no longer fails.
- 🇮🇩 Folder aplikasi root manager kini disembunyikan, tidak dihapus. Opsi libstagefright dihapus.
- 🇬🇧 Root manager app folders are now hidden, not deleted. The libstagefright option was removed.
- 🇮🇩 Statistik SUS PATH/SUS MAPS dihitung dari catatan kernel; WebUI tidak macet bila satu perintah gagal; keluar WebUI cukup sekali kembali.
- 🇬🇧 SUS PATH/SUS MAPS counts come from kernel logs; WebUI no longer stalls when one command fails; one back gesture exits the WebUI.
- 🇮🇩 Log Send Logs memuat identitas build (MANIFEST.txt).
- 🇬🇧 Send Logs includes the build identity (MANIFEST.txt).

## v0.1

- 🇮🇩 Versi pertama: mesin SUSFS simonpunk, tampilan SideX, fitur tambahan di halaman *hybrid_susfs settings*. Tidak dirilis.
- 🇬🇧 First version: simonpunk SUSFS engine, SideX UI, extra features on the *hybrid_susfs settings* page. Not released.
