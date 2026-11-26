# Panduan Tes di Perangkat Nyata

Panduan ini untuk menguji **APK rilis** SiCuaca di HP sungguhan. Semua hal di sini
**belum terbukti** oleh tes otomatis: tes otomatis hanya memeriksa logika dan tata
letak di mesin uji Flutter, bukan HP, jaringan, GPS, baterai, atau Firebase.

Cara pakai: kerjakan berurutan, beri tanda pada kolom **Hasil** (`OK` / `GAGAL` /
`SKIP`), isi **Catatan** bila ada yang aneh. Setiap `GAGAL` ditulis ke templat
laporan bug di bagian akhir.

## 0. Persiapan

| # | Langkah | Hasil | Catatan |
|---|---|---|---|
| 0.1 | Bangun APK rilis (lihat `docs/RILIS_ANDROID.md`), pakai `app-arm64-v8a-release.apk` | | |
| 0.2 | Hapus SiCuaca lama dari HP (versi debug/profile punya tanda tangan berbeda) | | |
| 0.3 | Aktifkan "instal dari sumber ini" lalu pasang APK, atau `adb install -r <apk>` | | |
| 0.4 | Catat HP penguji di tabel perangkat (bagian 9) | | |
| 0.5 | Untuk tes notifikasi: backend jalan (lihat `docs/HOSTING_BACKEND.md`, boleh di laptop dengan `php artisan schedule:work`) dan kunci service account **baru** terpasang | | |

## 1. Instal pertama di HP bersih

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 1.1 | Buka app pertama kali | Splash SiCuaca tampil mulus, tanpa layar biru muda atau kedip sebelum animasi | | |
| 1.2 | Pengantar (onboarding) | Tampil sekali, bisa dilewati, tidak muncul lagi setelah selesai | | |
| 1.3 | Ikon dan nama di launcher | Ikon SiCuaca, nama "SiCuaca", bukan logo BMKG | | |
| 1.4 | Atribusi | "Sumber: BMKG" dan "SiCuaca bukan aplikasi resmi BMKG" terlihat di layar cuaca/gempa dan Pengaturan | | |
| 1.5 | Tutup paksa lalu buka lagi | Masuk langsung ke beranda, tanpa pengantar ulang | | |

## 2. Izin lokasi

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 2.1 | Izinkan lokasi (saat dipakai) | Wilayah terdekat terdeteksi, cuaca muncul | | |
| 2.2 | Tolak lokasi | Tidak crash; pesan jelas; masih bisa cari wilayah manual | | |
| 2.3 | Tolak permanen ("Jangan tanya lagi") | Ada jalan ke pengaturan HP, bukan loop minta izin | | |
| 2.4 | GPS dimatikan, izin diberikan | Pesan GPS mati; tidak menggantung di loading | | |
| 2.5 | Cari wilayah (ketik nama kota/kecamatan) | Hasil muncul, pilih satu, cuaca berganti | | |
| 2.6 | Pencarian tanpa hasil (ketik acak) | Tampil keadaan kosong, bukan layar kosong | | |
| 2.7 | Pemilih wilayah (provinsi → kota → kecamatan → desa) | Bisa sampai desa, cuaca tampil | | |
| 2.8 | Tambah favorit, lihat daftar, hapus favorit | Tersimpan setelah app ditutup paksa dan dibuka lagi | | |

## 3. Cuaca dan gempa

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 3.1 | Cuaca sekarang, per jam, per hari | Angka masuk akal dan cocok dengan situs/aplikasi BMKG untuk wilayah yang sama | | |
| 3.2 | Matahari/bulan, titik embun, UV, kualitas udara | Tampil; UV diberi label "perkiraan"; AQI memuat atribusi Open-Meteo | | |
| 3.3 | Daftar gempa terbaru dan terasa | Cocok dengan data resmi BMKG (waktu, magnitudo, lokasi) | | |
| 3.4 | Detail gempa | Peta/jarak dan keterangan tampil; tautan sumber berfungsi | | |
| 3.5 | Siaga Gempa (3 dropdown) | Tidak terlalu mepet; filter bekerja | | |
| 3.6 | **Mode pesawat** setelah data pernah dimuat | Data cache tampil + banner offline; tidak crash | | |
| 3.7 | Mode pesawat dari awal (app baru, belum ada cache) | Keadaan "offline/tidak ada data" yang jelas, ada tombol coba lagi | | |
| 3.8 | Matikan mode pesawat | Banner hilang, data menyegarkan sendiri atau lewat tarik-segarkan | | |
| 3.9 | Sinyal lemah (jauh dari WiFi, data seluler pelan) | Loading terlihat, ada batas waktu lalu pesan galat, bukan menggantung | | |

## 4. Keadaan tiap layar (loading / kosong / galat / offline)

Untuk setiap layar, paksa tiap keadaan (mode pesawat untuk offline/galat; wilayah
tanpa data atau pencarian acak untuk kosong).

| Layar | Loading | Kosong | Galat | Offline | Catatan |
|---|---|---|---|---|---|
| Beranda / cuaca | | | | | |
| Per jam | | | | | |
| Per hari | | | | | |
| Udara & UV | | | | | |
| Daftar gempa | | | | | |
| Detail gempa | | | | | |
| Siaga Gempa | | | | | |
| Pencarian wilayah | | | | | |
| Pemilih wilayah | | | | | |
| Favorit | | | | | |
| Pengaturan | | | | | |

## 5. Notifikasi gempa (FCM dari backend)

Prasyarat: backend hidup dan berhasil mengirim; HP punya internet.
Memicu uji kirim dari mesin backend (ganti `gempa_m4` dengan `gempa_m5` atau `gempa_m6`):

```powershell
cd sicuaca-backend
php artisan sicuaca:tes-notif gempa_m4
```

Pastikan di app: Pengaturan → notifikasi gempa aktif dan ambang magnitudo yang
sesuai terpilih (subscribe ke topic yang sama).

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 5.1 | App di **depan** (foreground), picu `gempa_m4` | Notifikasi tampil (banner dalam app atau sistem), tidak ganda | | |
| 5.2 | App di **latar belakang** (tekan Home), picu | Notifikasi muncul di bilah status | | |
| 5.3 | App **ditutup paksa** (geser dari Recent / "Paksa berhenti"), picu | Notifikasi tetap datang. *Catatan: "Paksa berhenti" dari Info Aplikasi sengaja menghentikan penerimaan FCM di Android sampai app dibuka lagi; itu perilaku Android, bukan bug. Uji dengan geser dari Recent.* | | |
| 5.4 | Ketuk notifikasi dari kondisi 5.1, 5.2, 5.3 | Membuka **detail gempa yang benar** (bukan beranda) | | |
| 5.5 | Ambang magnitudo: pilih M≥5, picu `gempa_m4` | Tidak ada notifikasi | | |
| 5.6 | Ambang M≥5, picu `gempa_m5` dan `gempa_m6` | Keduanya muncul | | |
| 5.7 | Gempa nyata baru (saat ada) | Notifikasi datang dalam hitungan menit setelah BMKG menerbitkan | | |
| 5.8 | Matikan notifikasi gempa di Pengaturan, picu | Tidak ada notifikasi | | |
| 5.9 | Notifikasi tidak ganda untuk satu gempa | Satu gempa = satu notifikasi | | |

## 6. Izin notifikasi Android 13+

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 6.1 | Instal bersih di Android 13+, buka app | Dialog izin notifikasi muncul pada saat yang masuk akal (bukan sebelum konteks) | | |
| 6.2 | **Tolak** | App tidak crash; ada penjelasan dan jalan ke pengaturan notifikasi | | |
| 6.3 | Tolak, lalu nyalakan lewat Pengaturan HP | Notifikasi mulai tampil tanpa instal ulang | | |
| 6.4 | Izin dicabut saat app jalan | Tidak crash | | |

## 7. HP dengan penghemat baterai agresif

Xiaomi (MIUI/HyperOS), Oppo (ColorOS), Vivo (Funtouch/OriginOS), Samsung (One UI)
sering membunuh app latar belakang. Uji minimal satu HP merek ini, makin banyak
makin baik.

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 7.1 | Catat **merek, model, versi Android** di tabel perangkat | | | |
| 7.2 | Picu notifikasi, layar mati, tunggu 1 jam | Notifikasi masih datang | | |
| 7.3 | Picu notifikasi setelah layar mati **beberapa jam** (semalam) | Notifikasi masih datang saat pagi atau tertunda dalam batas wajar | | |
| 7.4 | Aktifkan **Autostart / Mulai otomatis** (Xiaomi/Oppo/Vivo) | Catat apakah ini mengubah hasil 7.3 | | |
| 7.5 | Baterai app → "Tanpa batasan" (Samsung: "Tidak dibatasi", jangan masukkan ke "Aplikasi tidur") | Catat apakah ini mengubah hasil 7.3 | | |
| 7.6 | Kunci app di Recent (ikon gembok) | Catat apakah ini mengubah hasil 7.3 | | |
| 7.7 | Widget: tunggu minimal 2 jam, lihat apakah jam "diperbarui" bergerak | Data widget menyegar sendiri | | |

Hasil bagian ini menentukan apakah app perlu **panduan pengaturan baterai di dalam
aplikasi** untuk merek tertentu. Catat pengaturan mana yang benar-benar membantu.

## 8. Tampilan, bahasa, rotasi

| # | Skenario | Yang diharapkan | Hasil | Catatan |
|---|---|---|---|---|
| 8.1 | HP layar kecil (≤ 5,5") | Tidak ada teks terpotong atau tumpang tindih | | |
| 8.2 | HP/tablet layar besar | Tata letak tetap rapi, tidak melar aneh | | |
| 8.3 | Mode terang | Kontras terbaca di semua layar | | |
| 8.4 | Mode gelap | Kontras terbaca di semua layar | | |
| 8.5 | Bahasa Indonesia | Semua teks Indonesia, tidak ada kunci/placeholder mentah | | |
| 8.6 | Bahasa Inggris | Semua teks Inggris; format tanggal/angka mengikuti | | |
| 8.7 | **Ukuran font besar** (Pengaturan HP → Tampilan → Ukuran font maksimum) | Tidak ada teks terpotong atau overflow garis kuning/hitam | | |
| 8.8 | Rotasi ke lanskap di setiap layar utama | Tidak crash; tata letak masih wajar | | |
| 8.9 | Rotasi saat loading data | Tidak crash, data tetap tampil setelahnya | | |
| 8.10 | Home, buka app lain 5 menit, kembali | Kembali ke layar yang sama, tidak crash | | |
| 8.11 | Kembali dari latar belakang setelah lama (≥ 30 menit) | Data menyegarkan atau menampilkan cache, tidak crash | | |
| 8.12 | Pasang widget layar utama (kecil dan besar), ubah wilayah di app | Widget mengikuti wilayah; tidak ada teks terpotong | | |

## 9. Tabel perangkat dan ringkasan hasil

### Perangkat uji

| Perangkat (merek + model) | Android | Ukuran layar | Penghemat baterai khusus | Catatan |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |

### Ringkasan hasil

| Bagian | Jumlah uji | OK | GAGAL | SKIP | Bug (nomor) |
|---|---|---|---|---|---|
| 1. Instal bersih | 5 | | | | |
| 2. Izin lokasi | 8 | | | | |
| 3. Cuaca dan gempa | 9 | | | | |
| 4. Keadaan layar | 11 layar × 4 | | | | |
| 5. Notifikasi gempa | 9 | | | | |
| 6. Izin notifikasi | 4 | | | | |
| 7. Baterai agresif | 7 | | | | |
| 8. Tampilan, bahasa, rotasi | 12 | | | | |

Tanggal tes: ____________  Penguji: ____________  Versi/build: 1.0.0+1

## 10. Templat laporan bug

Salin satu blok per bug. Jangan menyertakan kata sandi, kunci, atau isi
`key.properties` / service account di laporan atau tangkapan layar.

```
Judul        : (satu kalimat: apa yang salah)
Nomor uji    : (mis. 5.3)
Tingkat      : Crash / Fitur tidak jalan / Tampilan salah / Kosmetik
Perangkat    : (merek, model, Android, ukuran layar)
Versi app    : 1.0.0+1 (rilis / debug)
Kondisi      : (terang/gelap, bahasa, ukuran font, online/offline,
               izin lokasi/notifikasi, penghemat baterai)

Langkah menghasilkan:
1.
2.
3.

Hasil yang diharapkan:

Hasil yang terjadi:

Sering terjadi? : Selalu / Kadang (kira-kira __ dari __ kali) / Sekali
Bukti           : (tangkapan layar / rekam layar; log jika ada)
Log (opsional)  : adb logcat -d | findstr /i "sicuaca flutter AndroidRuntime"
Catatan         :
```

Mengambil log setelah crash (HP tersambung USB, debugging USB aktif):

```powershell
adb logcat -d -t 500 > log_crash.txt
```
