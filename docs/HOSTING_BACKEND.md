# Hosting backend SiCuaca

Backend (folder `sicuaca-backend/`) hanya melakukan satu pekerjaan: **tiap menit
membaca gempa BMKG, mencatat yang baru, dan mengirim notifikasi FCM ke topic
sesuai magnitudo**. Aplikasi Android **tidak memanggil backend**: ia hanya
subscribe ke topic FCM. Jadi tidak ada alamat/URL backend yang perlu ditanam di
APK, dan backend tidak butuh menerima lalu lintas masuk dari aplikasi.

Status: **belum di-deploy.** Dokumen ini berisi kebutuhan, pilihan hosting, dan
checklist deploy yang akan dipakai setelah Anda memilih.

## 1. Kebutuhan

| Hal | Kebutuhan | Bukti / catatan |
|---|---|---|
| PHP | 8.3 atau lebih baru | `composer.json`: `php ^8.3`. Diuji di 8.4.16. |
| Ekstensi PHP | `ctype dom fileinfo filter hash iconv json libxml mbstring openssl pcre phar session sodium tokenizer xml xmlwriter`, plus **`pdo_mysql`** dan sebaiknya `curl` | Daftar dari `composer check-platform-reqs` (semua terpenuhi di PHP 8.4.16). |
| Database | MySQL 8.x (utf8mb4) | Diuji penuh di MySQL 8.4.11 (`scripts/uji-mysql.ps1`). MariaDB belum diuji. |
| Composer | 2.x | `composer install --no-dev --optimize-autoloader` |
| Cron | `* * * * * php /jalur/ke/artisan schedule:run >> /dev/null 2>&1` | Pengecekan gempa dijadwalkan tiap menit (`routes/console.php`). Tanpa cron, notifikasi tidak terkirim dan `/health` memberi 503. |
| Keluar (outbound) HTTPS | ke `data.bmkg.go.id` (data gempa) dan ke layanan Google/Firebase (FCM, OAuth) | Host harus mengizinkan koneksi keluar. |
| Masuk (inbound) | **Tidak wajib.** Hanya perlu bila ingin `/health` bisa dipantau dari luar | Jika dibuka, pakai HTTPS. |
| Kredensial Firebase | Berkas kunci service account **di luar repo**, jalurnya di `FIREBASE_CREDENTIALS` | Jangan pernah di-commit. Wajib kunci BARU (kunci lama sudah bocor, lihat `LAPORAN_FASE_6B.md`). |
| Folder tulis | `storage/` dan `bootstrap/cache/` harus bisa ditulis oleh pengguna PHP | Log pengecekan: `storage/logs/cek-gempa.log`. |
| Antrean (queue) | **Tidak butuh worker** saat ini | Tidak ada job yang di-dispatch di `app/` (0 hasil). |
| `.env` | Salin dari `.env.example`, isi `APP_KEY` (`php artisan key:generate`), `DB_*`, `FIREBASE_CREDENTIALS`; set `APP_ENV=production`, `APP_DEBUG=false` | `.env` tidak boleh masuk git. |

## 2. Pilihan hosting (Anda yang memutuskan)

Tidak ada harga atau kuota di tabel ini, sebab angkanya berubah dan harus dicek
langsung di situs penyedia.

| Pilihan | Kelebihan | Kekurangan | Risiko untuk demo sekolah |
|---|---|---|---|
| **Shared hosting dengan cron** | Murah/mudah; cron dan MySQL biasanya sudah tersedia; tanpa admin server | Harus PHP 8.3+ dan ekstensi di atas; kadang tanpa SSH sehingga `composer install` dan `artisan` harus dijalankan dari panel atau diunggah; sebagian membatasi koneksi keluar | Versi PHP lama atau koneksi keluar diblokir membuat backend tidak jalan sama sekali. Cek dulu sebelum membayar. |
| **VPS** | Kendali penuh (PHP, cron, firewall), selalu hidup | Anda yang merawat: pembaruan keamanan, firewall, cadangan | Terlalu besar untuk kebutuhan sekecil ini kecuali sudah punya pengalaman; salah konfigurasi membuka celah. |
| **PaaS / container** | Deploy dari git, otomatis HTTPS | Penjadwal (cron) sering berupa layanan terpisah; disk sementara sehingga berkas kunci harus lewat secret/variabel; paket gratis kadang tidur atau dibatasi | Penjadwal tiap menit mungkin tidak tersedia di paket gratis; backend yang "tidur" berarti notifikasi terlewat. Verifikasi di dokumentasi penyedia. |
| **Laptop sendiri (jalankan `schedule:work`)** | Tanpa biaya; cukup untuk demo; **tanpa tunnel karena tidak ada lalu lintas masuk yang dibutuhkan** | Laptop harus menyala, online, dan tidak tidur | Mati/tidur saat demo berarti tidak ada notifikasi. Cocok untuk uji, bukan untuk jalan terus. |

Rekomendasi netral: untuk **menguji notifikasi** pakai laptop (tidak perlu
deploy apa pun). Untuk **demo yang harus jalan sendiri**, pilih shared hosting
atau VPS yang sudah Anda pastikan memenuhi tabel kebutuhan.

## 3. Menguji notifikasi tanpa deploy (laptop)

```powershell
cd sicuaca-backend
php artisan schedule:work            # jalankan pengecekan tiap menit
php artisan sicuaca:tes-notif gempa_m4   # kirim satu notifikasi uji ke topic gempa_m4
```

Topic yang valid: `gempa_m4`, `gempa_m5`, `gempa_m6`. Pastikan di `.env`
`FIREBASE_CREDENTIALS` menunjuk ke kunci service account BARU.

## 4. Checklist deploy (dipakai setelah Anda memilih hosting)

1. Server memenuhi bagian 1 (`php -v`, `php -m`, MySQL, cron, koneksi keluar).
2. Unggah/clone kode **tanpa** `.env`, `vendor/`, dan berkas kunci.
3. `composer install --no-dev --optimize-autoloader`.
4. Buat database dan pengguna MySQL khusus (hak hanya pada database itu), isi
   kata sandi kuat.
5. Salin `.env.example` menjadi `.env`; isi `APP_KEY`, `DB_*`, `FIREBASE_CREDENTIALS`;
   `APP_ENV=production`, `APP_DEBUG=false`.
6. Taruh kunci service account BARU di luar folder web; izin baca hanya untuk
   pengguna PHP; isi jalurnya di `FIREBASE_CREDENTIALS`.
7. `php artisan migrate --force`.
8. `php artisan config:cache && php artisan route:cache`.
9. Pasang cron `schedule:run` tiap menit.
10. Pastikan `storage/` dan `bootstrap/cache/` dapat ditulis.

## 5. Verifikasi setelah deploy

| Cek | Cara | Hasil yang benar |
|---|---|---|
| Kesehatan | `GET /health` (atau `php artisan tinker` bila tanpa web) | JSON `status: ok`, `database: ok`; HTTP 200. 503 selama menit pertama itu wajar. |
| Penjadwal jalan | Lihat `storage/logs/cek-gempa.log` | Ada baris baru tiap menit. |
| Cek gempa manual | `php artisan sicuaca:cek-gempa` | Selesai tanpa galat. |
| Notifikasi sampai | `php artisan sicuaca:tes-notif gempa_m4` | Notifikasi muncul di HP yang berlangganan M ≥ 4,0. |
| Tidak ada rahasia di repo | `git status` bersih, `.env` dan kunci tidak terlacak | Lihat bagian audit di `LAPORAN_FASE_6B.md`. |

## 6. Menguji backend di MySQL (sudah bisa dilakukan sekarang)

```powershell
cd sicuaca-backend
powershell -ExecutionPolicy Bypass -File scripts\uji-mysql.ps1
```

Skrip membuat server MySQL **sementara** yang terpisah (port 3307, folder data di
TEMP, akun root berkata sandi acak yang tidak dicetak), menjalankan migrasi dari
nol dan seluruh tes, lalu mematikan dan menghapusnya. Database `sicuaca` di MySQL
biasa Anda tidak disentuh.
