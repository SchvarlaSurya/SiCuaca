# SiCuaca

Aplikasi Android (Flutter) untuk prakiraan cuaca dan info gempa bumi
Indonesia, final project RPL. Data dari API terbuka BMKG.

**Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika).
SiCuaca bukan aplikasi resmi BMKG.**

## Isi repositori

| Folder | Isi |
|---|---|
| `lib/` | Aplikasi Flutter (Provider, dio, geolocator, Firebase Messaging) |
| `assets/data/` | Dataset kode wilayah Kepmendagri + titik tengah desa (lihat `LICENSE-wilayah.txt`) |
| `tool/build_wilayah.py` | Skrip pembangun dataset wilayah |
| `sicuaca-backend/` | Backend Laravel pengirim notifikasi gempa ([README](sicuaca-backend/README.md)) |

## Menjalankan aplikasi

```bash
flutter pub get
flutter run
```

Notifikasi gempa butuh `android/app/google-services.json` dari proyek Firebase
(package name `com.sicuaca.app`). Berkas ini tidak ikut Git; tanpa berkas itu
aplikasi tetap jalan dengan notifikasi nonaktif.

## Notifikasi gempa

- Pengguna memilih ambang di tab Peringatan (M 4+, M 5+, M 6+, atau mati);
  aplikasi subscribe ke satu topic FCM (`gempa_m4`/`gempa_m5`/`gempa_m6`).
- Mengetuk notifikasi membuka halaman detail gempa, baik saat aplikasi
  terbuka, di latar belakang, maupun tertutup. Detail dibangun dari data
  payload, jadi tetap tampil walau internet mati.
- Format payload FCM: lihat
  [sicuaca-backend/README.md](sicuaca-backend/README.md#format-payload-fcm).
