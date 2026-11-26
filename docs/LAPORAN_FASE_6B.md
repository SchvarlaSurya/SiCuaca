# Laporan Fase 6B

Tanggal: 2026-11-26. Cakupan: tes MySQL sungguhan, penandatanganan dan build rilis,
panduan tes perangkat, audit rahasia. **Tidak ada deploy dan tidak ada rilis
publik**, sesuai instruksi ("deploy juga testingnya aja").

Dokumen terkait: `docs/HOSTING_BACKEND.md`, `docs/RILIS_ANDROID.md`,
`docs/PANDUAN_TES_PERANGKAT.md`.

## 1. Audit rahasia

Tidak ada isi rahasia yang dicetak di laporan ini.

| Pemeriksaan | Hasil |
|---|---|
| Berkas rahasia pernah di-commit (service account, `.jks`, `.keystore`, `key.properties`, `*adminsdk*`, `.env`) di seluruh riwayat git | Tidak ada |
| Penanda kunci privat (`BEGIN PRIVATE KEY`, `"private_key"`) di berkas terlacak | Tidak ada |
| Penanda kunci privat di seluruh riwayat git | 0 commit |
| Pola token umum (kunci API Google, AWS, token GitHub, token Slack) di berkas terlacak | Tidak ada |
| `.gitignore` menutup service account, keystore, `key.properties`, `.env` | Ya, diperiksa dengan `git check-ignore` |
| `.env.example` | Hanya placeholder (`ganti-dengan-kata-sandi-kuat`, jalur contoh di luar repo); tidak diabaikan git, memang untuk dibagikan |
| Alamat debug/lokal di APK rilis | Tidak ada (`localhost`, `10.0.2.2`, `192.168.*`) |
| Alamat backend di APK rilis | Tidak ada; app tidak memanggil backend |
| Tanda tangan APK | Kunci rilis `CN=SiCuaca`, bukan kunci debug |

### Tindak lanjut yang masih terbuka

1. **Kunci service account `3579a919...` pernah tampil di chat** dan masih menjadi
   kunci yang dipakai backend di mesin ini. Berkas itu tidak pernah masuk git,
   tetapi kunci yang pernah terlihat harus dianggap bocor. **Belum dikonfirmasi
   dicabut.** Lihat daftar tugas di bagian 6.
2. `sicuaca-backend/CLAUDE.md` dan `sicuaca-backend/AGENTS.md` masih terlacak git.
   Isinya catatan alat bantu, bukan rahasia, tetapi tidak perlu ada di repo
   tugas sekolah. Menunggu keputusan Anda.
3. `android/app/google-services.json` di-ignore git. Berkas ini konfigurasi klien
   Firebase (bukan kunci pribadi), tetapi karena tidak ada di repo, siapa pun yang
   meng-clone repo tidak bisa membangun app sampai berkas itu diberikan. Tidak
   dibuatkan ulang (aturan: jangan mengarang konfigurasi Firebase).
4. Alat pemindai khusus (gitleaks/trufflehog) tidak dipasang; audit di atas memakai
   `git grep` dan `git log -G`. Cukup untuk pola umum, bukan pengganti pemindai.

## 2. Tes MySQL sungguhan

Alat: `sicuaca-backend/scripts/uji-mysql.ps1` menyalakan mysqld sementara
(MySQL 8.4.11, port 3307, hanya 127.0.0.1, kata sandi acak hanya di variabel
lingkungan), menjalankan `migrate:fresh` dan `php artisan test`, lalu mematikan
dan menghapus data. Tidak menyentuh MySQL lain di komputer.

| Pemeriksaan | Hasil |
|---|---|
| `migrate:fresh` di MySQL | Berhasil |
| Seluruh tes backend di MySQL | **28 dari 28 lulus** (termasuk 6 tes khusus MySQL) |
| Seluruh tes backend di SQLite (bawaan) | 22 lulus, 6 dilewati (tes khusus MySQL) |

Yang diperbaiki karena tes ini:

| Temuan | Perbaikan |
|---|---|
| Zona waktu sesi MySQL mengikuti server, bisa menggeser kolom waktu | `config/database.php`: `timezone` = `DB_TIMEZONE` (bawaan `+00:00`) |
| `.env.example` berisi `DB_PASSWORD` kosong dan jalur kunci Firebase di dalam repo | Placeholder kata sandi; jalur kunci di luar repo, dengan komentar |
| Skrip uji: stderr mysqld dianggap galat; `--skip-name-resolve` menyebabkan ERROR 1130 | Skrip disesuaikan |

Tes MySQL yang ditambahkan (`tests/Feature/MySqlSungguhanTest.php`): koneksi dan
tabel utf8mb4, zona waktu sesi dan perjalanan nilai `timestamp`, kolom magnitudo
`decimal(3,1)`, indeks unik dengan kunci 255 karakter utf8mb4 menolak duplikat,
teks unicode/emoji, dan `/health` melaporkan database OK dan 503 saat mati.

## 3. Diverifikasi otomatis vs menunggu tes manual

| Hal | Status | Bukti |
|---|---|---|
| Kode Flutter bebas peringatan | **Diverifikasi otomatis** | `flutter analyze`: No issues found |
| Logika dan tata letak aplikasi | **Diverifikasi otomatis** | `flutter test`: 301 tes lulus (lebar 360 dp, font 1,3x, font asli) |
| Widget layar utama: logika data dan penguraian | **Diverifikasi otomatis** | `gradlew :app:testDebugUnitTest`: 11 tes lulus (fixture BMKG). Jangan jalankan `testDebugUnitTest` tanpa `:app:`, karena ikut menjalankan tes plugin dan di Windows gagal oleh kunci berkas |
| Backend di SQLite dan MySQL 8.4 | **Diverifikasi otomatis** | 22 lulus + 6 dilewati (SQLite); 28 dari 28 (MySQL) |
| APK rilis ditandatangani kunci rilis | **Diverifikasi otomatis** | `apksigner verify`: Verifies; DN `CN=SiCuaca`; sidik jari SHA-256 sama dengan yang tercatat |
| Izin dan alamat di APK rilis | **Diverifikasi otomatis** | Pemeriksaan manifest (`aapt2`) dan string; lihat `RILIS_ANDROID.md` |
| Tidak ada rahasia di git | **Diverifikasi otomatis** | Bagian 1 |
| Seluruh halaman tampil benar (360 dp) | **Diverifikasi otomatis (mesin uji)** | 29 tangkapan layar |
| Build rilis dengan R8 jalan di HP | **Menunggu tes manual** | Belum pernah dijalankan; kesalahan R8 baru muncul saat dijalankan |
| Instal bersih, izin lokasi, GPS mati | **Menunggu tes manual** | Panduan bagian 1 dan 2 |
| Cuaca/gempa sama dengan data resmi, mode pesawat, kembali online | **Menunggu tes manual** | Panduan bagian 3 |
| Keadaan loading/kosong/galat/offline di perangkat | **Menunggu tes manual** | Panduan bagian 4 |
| Notifikasi gempa (foreground, background, ditutup), ketuk membuka detail benar | **Menunggu tes manual** | Panduan bagian 5; perlu backend hidup dan kunci baru |
| Izin notifikasi Android 13+ | **Menunggu tes manual** | Panduan bagian 6 |
| Notifikasi di HP penghemat baterai (Xiaomi/Oppo/Vivo/Samsung) | **Menunggu tes manual** | Panduan bagian 7; tidak bisa dibuktikan tanpa perangkatnya |
| Widget layar utama tampil rapi dan menyegar per jam | **Menunggu tes manual** | Tata letak diperiksa dengan ukuran tiruan, bukan di launcher asli |
| Layar kecil/besar, gelap/terang, Inggris/Indonesia, font besar, rotasi | **Menunggu tes manual** | Panduan bagian 8 |
| Backend di server hosting | **Belum dikerjakan** | Tidak ada deploy (hanya pengujian) |
| Pengiriman FCM sungguhan ke perangkat | **Belum dibuktikan** | Perlu kunci service account baru dan HP |

## 4. APK rilis

Perintah build:

```powershell
powershell -ExecutionPolicy Bypass -File tool\bangun_rilis.ps1 -PerAbi
```

(setara `flutter build apk --release` dan `--split-per-abi`, dengan percobaan ulang
bila Windows mengunci berkas build).

Lokasi: `build\app\outputs\flutter-apk\` (di-ignore git).

| Berkas | Ukuran | SHA-256 |
|---|---|---|
| `app-arm64-v8a-release.apk` (dipakai HP modern) | 24,1 MB | `4c7f472ba6661fb901fa752b175328079f1667667a0dfe4879e6c655919803e2` |
| `app-armeabi-v7a-release.apk` | 22,0 MB | `8c4f6ce6149e239053a84c2d1edc95ddd75604432e5668f3ad39dda262b762f1` |
| `app-x86_64-release.apk` | 25,5 MB | `1736c94642251ce421fdf008d2c5c94a186a39967c8e7986f9d6501bab604eb6` |
| `app-release.apk` (universal) | 62,4 MB | `37e4a90be0408d4c4d2f5a77e4a6818704511ef9bd250886887403211cd37b2d` |

Versi 1.0.0+1, ID aplikasi `com.sicuaca.app`. Sidik jari sertifikat penandatangan
(SHA-256): `5524c14eaad93316542139bad62731364c5157a6f079f0db0883f633a0b4a99f`.

## 5. Apakah sudah bisa dirilis?

- **APK**: sudah bisa dibangun dan ditandatangani; hasilnya ada di atas.
- **Backend tidak menghalangi APK.** App tidak pernah memanggil backend dan tidak
  ada alamat backend di APK. Cuaca, gempa, UV, dan udara semuanya diambil langsung
  dari BMKG dan Open-Meteo. Backend hanya dibutuhkan untuk **notifikasi gempa
  (FCM)**: tanpa backend, app berfungsi penuh kecuali notifikasi push gempa.
- Untuk menguji notifikasi, backend boleh jalan di laptop
  (`php artisan schedule:work`); lihat `docs/HOSTING_BACKEND.md`.
- **Belum layak dibagikan luas** sebelum bagian "menunggu tes manual" dijalankan,
  terutama satu asap-tes build rilis (R8) dan kunci lama dicabut.

## 6. Yang harus dikerjakan sendiri (berurutan)

1. **Cabut kunci service account `3579a919...`** di Google Cloud Console
   (IAM & Admin → Service Accounts → akun Firebase Admin → Keys → hapus kunci itu).
2. **Buat kunci baru**, simpan **di luar folder proyek**, lalu isi
   `FIREBASE_CREDENTIALS` di `.env` backend dengan jalur lengkapnya. Jangan kirim
   isinya ke chat atau git.
3. **Cadangkan keystore dan `android\key.properties`** ke tempat di luar komputer:
   `C:\Users\schvarla\.sicuaca-keystore\sicuaca-release.jks` dan
   `android\key.properties`. Hilang berarti APK pembaruan tidak bisa menimpa APK lama.
4. **Asap-tes APK rilis di HP Anda** (Samsung A16): pasang
   `app-arm64-v8a-release.apk` (hapus versi lama dulu), buka semua layar utama.
   Ini yang paling mungkin mengungkap masalah R8.
5. **Jalankan backend di laptop** untuk tes notifikasi
   (`php artisan schedule:work`, lalu `php artisan sicuaca:tes-notif gempa_m4`),
   lalu kerjakan `docs/PANDUAN_TES_PERANGKAT.md` bagian 5 dan 6.
6. **Kerjakan sisa panduan tes perangkat** (bagian 1 sampai 4, 7, 8) dan isi tabel
   hasil; tulis bug dengan templat di panduan.
7. **Uji HP merek penghemat baterai** (Xiaomi/Oppo/Vivo) bila ada yang bisa
   dipinjam; tanpa itu, klaim "notifikasi andal" tidak bisa dibuktikan.
8. **Putuskan** apakah `sicuaca-backend/CLAUDE.md` dan `AGENTS.md` dihapus dari repo.
9. **Pilih hosting** hanya bila ingin rilis sungguhan (opsi ada di
   `docs/HOSTING_BACKEND.md`); belum perlu untuk demo atau tes.
10. Setelah semua di atas selesai dan bug diperbaiki, barulah putuskan rilis.
