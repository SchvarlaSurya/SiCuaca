<?php

namespace App\Console\Commands;

use App\Services\BmkgGempaClient;
use App\Services\PengirimGempa;
use App\Support\BmkgTidakMerespons;
use App\Support\DataGempa;
use App\Support\FormatBmkgTidakDikenal;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;

#[Signature('sicuaca:tes-notif {topic : gempa_m4, gempa_m5, atau gempa_m6}')]
#[Description('Kirim notifikasi uji (berisi data gempa terbaru BMKG) ke satu topic FCM')]
class TesNotif extends Command
{
    public function handle(BmkgGempaClient $bmkg, PengirimGempa $pengirim): int
    {
        $topik = (string) $this->argument('topic');
        $dikenal = array_keys(config('sicuaca.topik'));

        if (! in_array($topik, $dikenal, true)) {
            $this->error("Topic tidak dikenal: {$topik}. Pilih salah satu: ".implode(', ', $dikenal));

            return self::INVALID;
        }

        // Payload memakai gempa terbaru yang asli supaya ketukan notifikasi
        // membuka detail sungguhan; bila BMKG gagal, pakai contoh tetap.
        try {
            $gempa = $bmkg->gempaTerbaru();
        } catch (BmkgTidakMerespons|FormatBmkgTidakDikenal $e) {
            $this->warn("BMKG tidak bisa dibaca ({$e->getMessage()}), memakai contoh gempa.");
            $gempa = self::contoh();
        }

        $hasil = $pengirim->kirim($gempa, [$topik], "Uji SiCuaca: {$gempa->judulNotifikasi()}", uji: true);

        if ($hasil['terkirim'] === []) {
            $this->error("Gagal mengirim ke {$topik}. Lihat storage/logs/laravel.log.");

            return self::FAILURE;
        }

        $this->info("Notifikasi uji terkirim ke {$topik} (gempa {$gempa->kunci()}).");

        return self::SUCCESS;
    }

    public static function contoh(): DataGempa
    {
        return new DataGempa(
            dateTime: '2026-11-13T04:49:34+00:00',
            koordinat: '-8.22,116.77',
            magnitudo: 4.9,
            wilayah: 'Pusat gempa berada di laut 29 km Barat Laut PULAUPANJANG',
            kedalaman: '17 km',
            tanggal: '13 Nov 2026',
            jam: '11:49:34 WIB',
            potensi: 'Gempa ini dirasakan untuk diteruskan pada masyarakat',
        );
    }
}
