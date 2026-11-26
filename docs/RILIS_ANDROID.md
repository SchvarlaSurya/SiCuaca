# Rilis Android SiCuaca

Dokumen ini menjelaskan cara membangun APK rilis yang ditandatangani, cara
menyimpan kunci penandatangannya, dan apa saja isi build rilis.

## 1. Penandatanganan (keystore)

APK rilis ditandatangani dengan kunci milik Anda. **Kunci ini tidak masuk git**
dan **tidak boleh hilang**: APK baru yang ditandatangani kunci lain tidak bisa
memperbarui APK lama yang sudah terpasang (pengguna harus uninstall dulu).

Dibuat sekali dengan:

```powershell
powershell -ExecutionPolicy Bypass -File tool\buat_keystore.ps1
```

Hasilnya, semua di komputer ini dan di luar git:

| Berkas | Isi | Catatan |
|---|---|---|
| `C:\Users\<nama>\.sicuaca-keystore\sicuaca-release.jks` | keystore PKCS12, kunci RSA 2048, alias `sicuaca`, berlaku sekitar 27 tahun | di luar folder proyek |
| `android\key.properties` | `storeFile`, `storePassword`, `keyAlias`, `keyPassword` | di-ignore git; **kata sandi acak ada di sini**, tidak pernah dicetak |

Skrip menolak menimpa keystore yang sudah ada.

### Cadangan (wajib)

1. Salin **kedua** berkas di atas ke tempat aman **di luar komputer ini**
   (flash disk atau penyimpanan pribadi yang terkunci).
2. Jangan kirim lewat chat, email, atau git. Siapa pun yang memegangnya bisa
   menerbitkan "pembaruan" atas nama aplikasi Anda.
3. Cek cadangan sesekali: `key.properties` harus menunjuk ke keystore yang
   memang ada, dan `keytool -list -keystore <jks>` meminta kata sandi yang sama.
4. Catat sidik jari sertifikat (publik, boleh disimpan di mana saja):
   `SHA-256 5524c14eaad93316542139bad62731364c5157a6f079f0db0883f633a0b4a99f`.
   Bila APK baru memperlihatkan sidik jari lain, berarti ditandatangani kunci lain.

Bila komputer ini rusak dan tidak ada cadangan, kunci tidak bisa dipulihkan.
Untuk demo sekolah dampaknya kecil (cukup instal ulang), tetapi untuk rilis
sungguhan itu masalah serius.

## 2. Membangun

Prasyarat: `android\key.properties` ada. Tanpa itu build rilis **sengaja gagal**
dengan pesan yang menunjuk ke skrip di atas (bukan diam-diam memakai kunci debug).

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File tool\bangun_rilis.ps1            # APK universal
powershell -ExecutionPolicy Bypass -File tool\bangun_rilis.ps1 -PerAbi    # + APK per arsitektur
```

Atau langsung: `flutter build apk --release` (dan `--split-per-abi`).

`bangun_rilis.ps1` hanya membungkus perintah itu dengan **percobaan ulang**:
di Windows, antivirus atau pengindeks kadang mengunci berkas build yang baru
dibuat sehingga Gradle gagal dengan "The process cannot access the file because
it is being used by another process". Itu acak dan hilang bila diulang.
Jika build menyisakan folder yang rusak (galat "Failed to create MD5 hash ...
does not exist"), hentikan Gradle dan hapus folder `build\`:

```powershell
cd android; .\gradlew.bat --stop; cd ..
Remove-Item build -Recurse -Force
```

Keluaran: `build\app\outputs\flutter-apk\`

| Berkas | Untuk |
|---|---|
| `app-arm64-v8a-release.apk` | hampir semua HP Android modern (termasuk Samsung A16) |
| `app-armeabi-v7a-release.apk` | HP 32-bit lama |
| `app-x86_64-release.apk` | emulator x86_64 |
| `app-release.apk` | universal, dipakai bila arsitektur tidak diketahui (terbesar) |

## 3. Memeriksa tanda tangan

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\<versi>\apksigner.bat" verify --print-certs build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

Harus mencetak `Verifies`, DN `CN=SiCuaca, OU=Proyek Sekolah, O=SiCuaca, C=ID`,
dan SHA-256 sama dengan yang dicatat di atas. DN `Android Debug` berarti APK
tidak ditandatangani kunci rilis.

## 4. Menginstal ke HP

```powershell
adb install -r build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

Atau salin berkas ke HP dan buka (izinkan "instal dari sumber ini"). Untuk
HP bersih: hapus dulu SiCuaca versi debug/profile yang pernah dipasang, karena
tanda tangannya berbeda dengan versi rilis.

## 5. Isi build rilis

- **applicationId** `com.sicuaca.app` (sama dengan yang terdaftar di Firebase).
  Nama paket internal kode (`namespace`) tetap `com.example.app`: itu tidak
  terlihat pengguna dan mengubahnya tidak ada gunanya.
- **Versi** dari `pubspec.yaml` (`version: 1.0.0+1`). Naikkan angka `+N` setiap
  APK baru yang akan menggantikan yang lama.
- **Nama aplikasi** SiCuaca; ikon peluncur adalah logo SiCuaca (bukan logo BMKG).
- **R8 aktif**: kode diperkecil dan diacak, sumber daya tak terpakai dibuang
  (`isMinifyEnabled` dan `isShrinkResources`). Aturan tambahan ada di
  `android\app\proguard-rules.pro`. **Build rilis belum pernah dijalankan di
  perangkat sungguhan**; asap-tes pertama (buka app, cuaca, gempa, notifikasi,
  widget) wajib sebelum dibagikan, karena kesalahan R8 baru muncul saat
  dijalankan.
- **Tidak ada alamat debug**: tidak ada `localhost`, `10.0.2.2`, atau `192.168.x`
  di dalam APK. Alamat yang tertanam hanya layanan yang memang dipakai:
  `api.bmkg.go.id`, `data.bmkg.go.id`, `maritim.bmkg.go.id`,
  `air-quality-api.open-meteo.com`, serta tautan halaman resmi (bmkg.go.id,
  bnpb.go.id, dokumentasi). **Tidak ada alamat backend**: aplikasi tidak
  memanggil backend sama sekali, hanya subscribe ke topic FCM.
- **Tidak dapat di-debug** (`debuggable` tidak diset).

### Izin (permission) di APK rilis

| Izin | Sumber | Dipakai untuk |
|---|---|---|
| `INTERNET` | aplikasi | data BMKG, Open-Meteo |
| `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` | aplikasi | wilayah terdekat dan jarak gempa |
| `POST_NOTIFICATIONS` | aplikasi | notifikasi gempa (Android 13+) |
| `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE` | WorkManager (pembaruan widget per jam) | menjalankan pekerjaan latar belakang dan menjadwalkannya ulang setelah HP restart |
| `VIBRATE` | notifikasi lokal | getar notifikasi gempa |
| `com.google.android.c2dm.permission.RECEIVE` | Firebase Messaging | menerima notifikasi push |
| `<paket>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX | pengaman penerima dinamis (otomatis) |

Izin selain empat yang pertama datang dari pustaka. Bisa dibuang lewat
`tools:node="remove"` di manifest, tetapi itu mematikan fiturnya (pembaruan
widget setelah restart, push, getar), jadi sengaja dibiarkan.
