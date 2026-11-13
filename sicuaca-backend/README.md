# SiCuaca Backend

Backend notifikasi gempa untuk aplikasi SiCuaca (Laravel 13, PHP 8.3+, MySQL).
Setiap menit server membaca data gempa BMKG, mencatat gempa baru, lalu
mengirim push notification lewat Firebase Cloud Messaging (FCM) ke topic
sesuai magnitudo.

Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika).
SiCuaca bukan aplikasi resmi BMKG.

## Cara kerja

1. `php artisan sicuaca:cek-gempa` (dijadwalkan tiap menit) membaca:
   - `https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json`: 1 gempa terbaru.
   - `https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json`: 15 gempa terakhir M 5.0+.

   Membaca keduanya mencegah gempa terlewat bila ada lebih dari satu gempa
   dalam selang satu menit (autogempa hanya menunjukkan yang terakhir).
2. Setiap gempa diberi kunci `DateTime|Coordinates`. Gempa yang belum ada di
   tabel `gempa_terkirim` diproses dari yang **terlama**.
3. **Eksekusi pertama** (tabel kosong): semua gempa hanya dicatat sebagai
   titik awal, tidak ada notifikasi.
4. Gempa lebih tua dari `SICUACA_MAKS_UMUR_JAM` (bawaan 6 jam) hanya dicatat,
   supaya server yang baru hidup lagi tidak mengirim notifikasi lama.
5. Topic tujuan bersifat **kumulatif**: gempa M 5.5 dikirim ke `gempa_m4` dan
   `gempa_m5`; M 6.2 ke `gempa_m4`, `gempa_m5`, `gempa_m6`. Aplikasi hanya
   subscribe ke satu topic sesuai ambang pilihan pengguna, jadi tidak ada
   notifikasi ganda.
6. Panggilan BMKG dan FCM dicoba ulang (bawaan 3 kali). Bila tetap gagal,
   dicatat di `storage/logs/laravel.log`; kegagalan satu gempa/topic tidak
   menghentikan yang lain.
7. Kunci `gempa_key` unik di database dan jadwal memakai
   `withoutOverlapping()`, jadi dua proses tidak bisa mengirim gempa yang sama.

## Format payload FCM

Setiap pesan berisi bagian **notification** (ditampilkan sistem Android saat
aplikasi di latar belakang/tertutup) dan **data** (dibaca aplikasi untuk
membuka halaman detail). Semua nilai data berupa **string**.

```json
{
  "notification": {
    "title": "Gempa M 4.1",
    "body": "Pusat gempa berada di laut 24 km selatan Enggano. Kedalaman 24 km."
  },
  "android": {
    "priority": "high",
    "notification": { "channel_id": "gempa_bumi", "sound": "default" }
  },
  "data": {
    "jenis": "gempa",
    "uji": "0",
    "gempa_key": "2026-11-13T07:31:39+00:00|-5.56,102.24",
    "magnitudo": "4.1",
    "wilayah": "Pusat gempa berada di laut 24 km selatan Enggano",
    "kedalaman": "24 km",
    "waktu": "2026-11-13T07:31:39+00:00",
    "tanggal": "13 Nov 2026",
    "jam": "14:31:39 WIB",
    "koordinat": "-5.56,102.24",
    "shakemap": "20261113143139.mmi.jpg",
    "potensi": "Gempa ini dirasakan untuk diteruskan pada masyarakat",
    "dirasakan": "II - III Enggano"
  }
}
```

| Kunci data | Isi |
|---|---|
| `jenis` | selalu `gempa` (aplikasi mengabaikan pesan dengan jenis lain) |
| `uji` | `1` untuk `sicuaca:tes-notif`, selain itu `0` |
| `gempa_key` | kunci unik `DateTime\|Coordinates` |
| `magnitudo` | angka dengan titik desimal, mis. `4.1` |
| `waktu` | ISO 8601 UTC dari field `DateTime` BMKG |
| `tanggal`, `jam` | teks asli BMKG (dipakai aplikasi untuk menurunkan nama shakemap bila `shakemap` kosong) |
| `koordinat` | `lintang,bujur` bertanda; negatif = LS / BB |
| `shakemap` | nama berkas shakemap; kosong untuk gempa dari gempaterkini |
| `potensi`, `dirasakan` | boleh kosong; dipotong maks. 200 / 400 karakter |

## Menjalankan secara lokal

```bash
composer install
cp .env.example .env
php artisan key:generate
# isi DB_* dan FIREBASE_CREDENTIALS di .env
php artisan migrate
php artisan schedule:work            # cek gempa tiap menit (biarkan terbuka)
php artisan sicuaca:tes-notif gempa_m5   # kirim notifikasi uji
php artisan sicuaca:cek-gempa        # cek sekali
php artisan test
```

## Deploy ke server

1. Salin kode, jalankan `composer install --no-dev --optimize-autoloader`.
2. Buat `.env` dari `.env.example`: `APP_ENV=production`, `APP_DEBUG=false`,
   `APP_URL`, kredensial MySQL, lalu `php artisan key:generate` dan
   `php artisan migrate --force`.
3. **Kunci service account Firebase**:
   - Unduh dari Firebase console → Project settings → Service accounts →
     Generate new private key.
   - Simpan **di luar folder web**, mis. `/etc/sicuaca/service-account.json`,
     pemilik user PHP, izin `600` (`chmod 600`).
   - Isi `FIREBASE_CREDENTIALS=/etc/sicuaca/service-account.json`.
   - Jangan pernah commit, kirim lewat chat, atau menaruhnya di `public/`.
     Bila kunci bocor, hapus di Google Cloud (IAM → Service accounts → Keys)
     dan buat yang baru.
4. Cron (satu baris, sebagai user PHP):

   ```cron
   * * * * * cd /path/ke/sicuaca-backend && php artisan schedule:run >> /dev/null 2>&1
   ```

   Hasil tiap menit tercatat di `storage/logs/cek-gempa.log`.
5. Pantau `GET /health`:

   ```json
   {
     "status": "ok",
     "pengecekan_terakhir": {"waktu": "2026-11-13T08:00:00+00:00", "berhasil": true, "dibaca": 16, "baru": 0, "terkirim": 0, "gagal_kirim": 0},
     "pengecekan_terlambat": false,
     "database": "ok",
     "gempa_tercatat": 16,
     "notifikasi_terakhir_dikirim": "2026-11-13 07:32:05",
     "waktu_server": "2026-11-13T08:00:30+00:00"
   }
   ```

   HTTP 200 bila normal; 503 bila belum pernah mengecek, pengecekan terakhir
   lebih lama dari `SICUACA_HEALTH_BATAS_MENIT` (cron mati), atau database
   tidak bisa diakses.

## Struktur kode

| Berkas | Fungsi |
|---|---|
| `app/Console/Commands/CekGempa.php` | `sicuaca:cek-gempa` |
| `app/Console/Commands/TesNotif.php` | `sicuaca:tes-notif {topic}` (payload gempa terbaru, `uji=1`) |
| `app/Services/BmkgGempaClient.php` | Baca autogempa + gempaterkini dengan retry |
| `app/Services/PengirimGempa.php` | Kirim ke beberapa topic dengan retry per topic |
| `app/Services/FcmPengirimNotifikasi.php` | Pengiriman FCM (kreait/laravel-firebase) |
| `app/Services/StatusPengecekan.php` | Ringkasan pengecekan terakhir untuk `/health` |
| `app/Support/DataGempa.php` | Validasi data BMKG, kunci, topic, payload |
| `app/Http/Controllers/HealthController.php` | `GET /health` |
| `config/sicuaca.php` | URL, retry, batas umur, peta topic |
| `routes/console.php` | Jadwal tiap menit |
