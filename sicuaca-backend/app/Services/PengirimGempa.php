<?php

namespace App\Services;

use App\Support\DataGempa;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Mengirim satu gempa ke semua topic tujuannya, dengan percobaan ulang
 * per topic. Kegagalan satu topic tidak menghentikan topic lain.
 */
class PengirimGempa
{
    public function __construct(private PengirimNotifikasi $pengirim) {}

    /**
     * @param  list<string>  $topik
     * @return array{terkirim: list<string>, gagal: list<string>}
     */
    public function kirim(DataGempa $gempa, array $topik, string $judul, bool $uji = false): array
    {
        $hasil = ['terkirim' => [], 'gagal' => []];

        foreach ($topik as $t) {
            try {
                retry(
                    max(1, config('sicuaca.fcm_percobaan')),
                    fn () => $this->pengirim->kirimKeTopik($t, $judul, $gempa->isiNotifikasi(), $gempa->payload($uji)),
                    config('sicuaca.fcm_jeda_ms'),
                );
                $hasil['terkirim'][] = $t;
            } catch (Throwable $e) {
                // Hanya pesan error yang dicatat; kredensial tidak pernah
                // ada di pesan exception kreait.
                Log::error('Gagal mengirim FCM setelah beberapa percobaan', [
                    'topic' => $t,
                    'gempa_key' => $gempa->kunci(),
                    'alasan' => $e->getMessage(),
                ]);
                $hasil['gagal'][] = $t;
            }
        }

        return $hasil;
    }
}
