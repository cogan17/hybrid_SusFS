# Changelog

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
