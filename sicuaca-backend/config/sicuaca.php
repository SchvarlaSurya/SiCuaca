<?php

return [

    /*
    | Sumber data gempa terbaru BMKG (satu kejadian).
    */
    'autogempa_url' => env('SICUACA_AUTOGEMPA_URL', 'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json'),

    /*
    | Batas waktu permintaan ke BMKG, dalam detik.
    */
    'bmkg_timeout' => (int) env('SICUACA_BMKG_TIMEOUT', 15),

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
