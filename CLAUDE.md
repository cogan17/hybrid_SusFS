# Aturan untuk asisten AI di repo ini

Disalin dari `CLAUDE.md` di [cogan17/Cogan-Kernel](https://github.com/cogan17/Cogan-Kernel) (owner, 16 Nov 2026). Bagian khusus isi repo Cogan-Kernel tidak ikut.

## Bahasa (WAJIB)

- **Semua komunikasi asisten ke owner wajib bahasa Indonesia** (owner, 31 Okt 2026: "saya hanya mengerti bahasa ibu saya"). Ini mencakup balasan chat, penjelasan, ringkasan, pertanyaan, deskripsi PR, dan pesan commit. Jangan membalas owner dalam bahasa Inggris.
- **Deliverable untuk pengguna akhir tetap dua bahasa (Indonesia lalu English)**: catatan rilis, teks Telegram, summary workflow, README, dan PANDUAN. Aturan dua bahasa di bawah tidak dibatalkan; bagian English tetap ada karena untuk pengunduh rilis, dan bagian Indonesia yang menjadi acuan owner.

## Gaya jawaban (owner, 4 Nov 2026)

- **Panggilan** (owner, 6 Nov 2026): panggil owner **bro** atau **bang**, jangan **Pak/Bapak**.
- Jawab langsung pada intinya di kalimat pertama. Dilarang menggunakan kalimat pembuka, sapaan, atau kesimpulan di akhir. Dilarang menggunakan kata atau frasa klise AI (seperti delve, tapestry, testament, seamless, crucial). Gunakan bahasa yang ringkas, kasual, dan konkret. Jangan merangkum jawaban.
- **Teliti, hati-hati, tanpa duplikasi** (owner, 7 Nov 2026: "kerjakan dengan teliti, hati-hati, tidak ada duplikasi pekerjaan"): periksa dulu apa yang sudah ada (kode, patch, config, dokumen, riwayat) sebelum menambah. Jangan membuat ulang atau menggandakan yang sudah ada, dan pastikan dengan bukti sebelum mengubah.

## Tanpa atribusi AI

- Author dan committer memakai identitas owner: `git config user.name Cogan` dan `git config user.email 79615344+cogan17@users.noreply.github.com`.
- Pesan commit **tanpa** `Co-Authored-By: Claude …`, `Claude-Session: …` atau atribusi AI lain.
- Deskripsi PR **tanpa** footer "Generated with Claude Code" atau tautan sesi.
- Branch kerja memakai nama biasa: `feat/…`, `fix/…`, `docs/…`, `chore/…`. Perubahan masuk ke `Utama` (branch default) lewat PR.

## PR, issue, dan syarat rilis (owner, 16 Nov 2026)

- Kutipan owner: "PR dan issue aku serahkan kepada dirimu. Sebelum rilis pastikan benar-benar tidak ada celah/bug/glitch/bootloop/bug visual/dan lain-lain!"
- **PR dan issue diurus asisten**: membuat PR ke `Utama`, membuat issue untuk hal yang perlu dicek atau diuji, memperbarui, dan menutupnya bila selesai.
- **Sebelum rilis, wajib bersih dari celah, bug, glitch, bootloop, bug visual, dan masalah lain.** Paling sedikit:
  - shellcheck tanpa error
  - simulasi install, **update di atas versi yang terpasang**, boot, toggle, reset, dan uninstall di busybox `ash` (16 Nov 2026: build uji 5 gagal dipasang di atas build 4 karena skenario update tidak diulang)
  - gate mesin lolos
  - cek visual semua halaman WebUI di layar sempit dan beberapa bahasa
  - uji HP sesuai checklist di issue
- Rilis hanya setelah semua lolos. Yang belum terbukti ditulis jelas, jangan dianggap aman.

## Penomoran versi (khusus repo hybrid_susfs, owner 18 Nov 2026)

- Tiap perbaikan menaikkan versi satu langkah: `v0.8` → `v0.9` → `v0.10` → … → `v0.99`.
- `versionCode` naik 1 tiap rilis, mengikuti angka minor (`v0.9` = 9, `v0.10` = 10, `v0.99` = 99).
- Setelah **`v0.99`** (versionCode 99), berikutnya **`v1.00`** (versionCode 100), lalu `v1.01` (101), dan seterusnya.
- `version` di `module/module.prop`, `update.json`, dan bagian `## vX.Y` di `CHANGELOG.md` wajib sama (dicek Builder dan Validate).

## Waktu

- Waktu untuk owner selalu ditulis dalam **WIB** (Jakarta, UTC+7), misalnya "17.29 WIB". Kalau sumbernya UTC (GitHub, log), ubah dulu ke WIB.

## Pelajaran yang tetap berlaku

- **Diagnosa dengan bukti, bukan keyakinan.** Bandingkan artefak yang berhasil dengan yang rusak sebelum mengubah kode. Tulis jelas mana yang terukur lokal, mana yang sudah dibuktikan CI, dan mana yang sudah dibuktikan di HP.
- **Gate gagal, bukan lolos diam-diam.** Gate KMI dan patch yang tidak bisa dipasang menghentikan build. Jangan pernah mengubahnya jadi peringatan.
- **Instruksi yang bisa dibaca dua arah: tanya dulu.**

## Hemat run workflow (owner, 23 Okt 2026)

- **Jangan boros Actions.** Jalankan workflow hanya bila sudah yakin hasilnya akan benar: kode sudah dicek lokal (tes, lint, uji dengan repo hulu sungguhan bila bisa).
- **Gagal = investigasi dulu, bukan coba-coba.** Baca log, temukan penyebabnya, perbaiki sekali dengan benar, baru jalankan ulang. Jangan berputar-putar dengan run berulang.
- **Investigasi secukupnya.** Jangan terlalu lama; cari bukti yang menentukan, lalu putuskan.
- **Cepat bukan berarti teledor.** Kerjakan dengan bijaksana.

## Checkpoint

- Bila owner menulis **checkpoint**: hentikan semua pekerjaan saat itu juga, tanpa mengecek apa pun satu per satu.
- Simpan keadaan terakhir ke [`CHECKPOINT.md`](CHECKPOINT.md): apa yang sedang berjalan, apa yang sudah selesai, apa yang tertunda, dan langkah pertama berikutnya. Commit dan push ke `Utama` lewat PR.
- Sesi berikutnya **mulai dari `CHECKPOINT.md`**, lalu lanjut hanya setelah owner meminta.
