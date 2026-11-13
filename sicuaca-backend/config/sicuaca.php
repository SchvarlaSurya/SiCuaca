<?php

return [

    /*
    | Sumber data BMKG. Keduanya dibaca tiap pengecekan: autogempa berisi
    | satu gempa terbaru, gempaterkini berisi 15 gempa terakhir M 5.0+.
    | Membaca keduanya mencegah gempa terlewat bila ada lebih dari satu
    | gempa dalam selang satu menit.
    */
    'autogempa_url' => env('SICUACA_AUTOGEMPA_URL', 'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json'),
    'gempaterkini_url' => env('SICUACA_GEMPATERKINI_URL', 'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json'),

    /*
    | Batas waktu dan percobaan ulang permintaan ke BMKG.
    */
    'bmkg_timeout' => (int) env('SICUACA_BMKG_TIMEOUT', 15),
    'bmkg_percobaan' => (int) env('SICUACA_BMKG_PERCOBAAN', 3),
    'bmkg_jeda_ms' => (int) env('SICUACA_BMKG_JEDA_MS', 1000),

    /*
    | Percobaan ulang pengiriman FCM per topic.
    */
    'fcm_percobaan' => (int) env('SICUACA_FCM_PERCOBAAN', 3),
    'fcm_jeda_ms' => (int) env('SICUACA_FCM_JEDA_MS', 1000),

    /*
    | Gempa yang lebih tua dari ini (jam) hanya dicatat, tidak dikirim.
    | Mencegah banjir notifikasi lama setelah server mati beberapa waktu.
    */
    'maks_umur_jam' => (int) env('SICUACA_MAKS_UMUR_JAM', 6),

    /*
    | Endpoint /health menganggap pengecekan terlambat bila pengecekan
    | terakhir lebih lama dari ini (menit).
    */
    'health_batas_menit' => (int) env('SICUACA_HEALTH_BATAS_MENIT', 5),

    /*
    | Ambang magnitudo => topic FCM. Pengiriman bersifat kumulatif:
    | gempa M 5.5 dikirim ke semua topic yang ambangnya <= 5.5
    | (gempa_m4 dan gempa_m5). Aplikasi hanya subscribe ke SATU topic.
    | Nama topic harus sama dengan yang dipakai aplikasi Flutter.
    */
    'topik' => [
        'gempa_m4' => 4.0,
        'gempa_m5' => 5.0,
        'gempa_m6' => 6.0,
    ],

    /*
    | ID channel notifikasi Android. Harus sama dengan channel yang dibuat
    | aplikasi Flutter.
    */
    'android_channel_id' => 'gempa_bumi',

];
