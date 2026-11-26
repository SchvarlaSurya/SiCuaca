# Aturan R8/ProGuard untuk build rilis SiCuaca.
#
# Plugin Flutter (Firebase, WorkManager, sqflite, url_launcher, dll.) membawa
# aturan konsumen sendiri. Yang ditambahkan di sini hanya kode milik aplikasi
# yang dipanggil lewat nama (manifest, WorkManager, widget layar utama).

# Widget layar utama dan pekerja pembaruannya (dipanggil sistem lewat nama kelas).
-keep class com.example.app.WidgetCuacaProvider { *; }
-keep class com.example.app.PembaruWidgetWorker { <init>(...); }

# Logika murni widget memakai org.json bawaan Android.
-keep class com.example.app.DataWidgetKt { *; }
