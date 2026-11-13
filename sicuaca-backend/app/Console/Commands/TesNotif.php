<?php

namespace App\Console\Commands;

use App\Services\PengirimNotifikasi;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;
use Throwable;

#[Signature('sicuaca:tes-notif {topic : gempa_m4, gempa_m5, atau gempa_m6}')]
#[Description('Kirim notifikasi uji ke satu topic FCM tanpa menunggu gempa asli')]
class TesNotif extends Command
{
    public function handle(PengirimNotifikasi $pengirim): int
    {
        $topik = (string) $this->argument('topic');
        $dikenal = array_keys(config('sicuaca.topik'));

        if (! in_array($topik, $dikenal, true)) {
            $this->error("Topic tidak dikenal: {$topik}. Pilih salah satu: ".implode(', ', $dikenal));

            return self::INVALID;
        }

        $jam = now()->format('H:i:s');

        try {
            $pengirim->kirimKeTopik(
                $topik,
                'Uji notifikasi SiCuaca',
                "Ini pesan uji untuk topic {$topik} ({$jam}). Bukan gempa sungguhan.",
                ['jenis' => 'uji', 'topic' => $topik],
            );
        } catch (Throwable $e) {
            Log::error('sicuaca:tes-notif gagal', ['topic' => $topik, 'alasan' => $e->getMessage()]);
            $this->error("Gagal mengirim: {$e->getMessage()}");

            return self::FAILURE;
        }

        $this->info("Notifikasi uji terkirim ke topic {$topik}.");

        return self::SUCCESS;
    }
}
