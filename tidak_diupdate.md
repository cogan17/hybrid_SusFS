# Pembaruan hulu yang sengaja tidak diambil

Catatan commit SideX dan Brene yang **sudah ditinjau tapi sengaja tidak digabung** ke hybrid_susfs, beserta alasannya.
Dibaca otomatis oleh `tools/check_updates.sh` (workflow **Cek pembaruan**, dan step **Status hulu** di ringkasan **hybrid_susfs Builder**):

- Commit hulu yang tercatat di sini tampil sebagai `⏭️ dilewati: <alasan>`.
- Commit hulu yang belum tercatat (dan belum digabung) tampil sebagai `🆕 belum ditinjau`.

## Cara pakai

Saat **Cek pembaruan** menampilkan commit `🆕`, tinjau satu per satu:

1. **Diambil** → porting perubahannya ke kode hybrid_susfs (PR biasa).
2. **Tidak diambil** → tambah satu baris di tabel bawah: sumber (`SideX` atau `Brene`, persis), hash **penuh** 40 karakter, judul commit, alasan.

Setelah semua commit sampai ujung cabang diambil atau dicatat di sini, majukan `SIDEX_COMMIT` / `BRENE_COMMIT` di `upstream.env` ke ujung cabang itu. Baris yang sudah lewat acuan tetap disimpan sebagai riwayat keputusan.

Format baris wajib: `| Sumber | hash penuh | judul | alasan |` (dipotong per `|`, jangan pakai `|` di dalam isi).

## Daftar

| Sumber | Commit | Judul | Alasan |
|---|---|---|---|
| SideX | 44ed418e486bdad4a0edfc016dc72e69a6c1be91 | scripts/service: Uncomment check_missing_prop for vbmeta properties | Blok prop SideX sudah dipindah ke spoof_system_properties (brene.sh) yang mengatur semua prop vbmeta lebih lengkap; avb_version 1.3 cocok HP MTK, SideX hardcode 1.2 |
| Brene | 1ae9cef1572b5d2e5c442835778de724572c5779 | add: exceptions to /data/local/tmp hiding (#72) | Kustomisasi pengecualian, bukan anti-deteksi; ditunda sampai ada kebutuhan pengguna |
| Brene | 32aeb16e109dfc5d8f71c15f54224028f255f775 | webui: update PlayIntegrityFork module id | Khusus WebUI Brene (daftar kompatibilitas modul), WebUI hybrid_susfs berbeda |
| Brene | fcfcc82a6c048d35b0075c9d0dd2cdee8a985fb6 | webui: add zygisk-detach module to Incompatible/Untested modules | Khusus WebUI Brene (daftar kompatibilitas modul) |
| Brene | d96d370c3168ac502108e84c5f4d851751ed8135 | add: Remove suspicious directories in /sdcard/Android/[data, media, obb] | Brene menghapus folder; hybrid_susfs menyembunyikan (sus_path_loop) yang lebih aman, tanpa hapus data |
| Brene | f405fc955903d13eff4fdfe7851af93677dd288c | fix: add executable permission to remove_sus_dir.sh file | Skrip khusus Brene, tidak dipakai hybrid_susfs |
| Brene | 9b2a033bd46bb6bd5568ffdd6574ff90ac73d200 | add: Hide Gapps | Sudah ada di hybrid_susfs (hide_gapps dari SideX) |
| Brene | 5a33512a49b451159a3dd069bc8be3cc3120f880 | add: exceptions to Hide non-standard /sdcard paths | Kustomisasi pengecualian, bukan anti-deteksi |
| Brene | cd6b9e6f622108620a64739e401c1bba67958bc0 | improve: run Remove Custom ROM and PIF properties after storage is accessible | Fitur rom_props/pif_props default mati; tidak ada bukti masalah urutan di hybrid_susfs |
| Brene | 1876404a5691d2121c6ee7a295be15354899e0d0 | bump: version to v0.0.77 | Versi Brene |
| Brene | 3fcac6245252683e0cecb8b31632cd1a2efafe01 | webui: drop dead modules | Khusus WebUI Brene |
| Brene | cadabd9beb398f33bdd2373448b0aef95a29db53 | add: post-boot.sh stage and move some features to it | Restrukturisasi tahap boot internal Brene; fitur relevannya sudah ada di hybrid_susfs |

Diambil dari tinjauan yang sama (tidak dicatat di atas): Brene `0803d8b` (paket `com.sukisu.nova`) → v0.17.
