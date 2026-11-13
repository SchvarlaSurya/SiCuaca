<?php

namespace App\Services;

use App\Support\BmkgTidakMerespons;
use App\Support\DataGempa;
use App\Support\FormatBmkgTidakDikenal;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

/**
 * Mengambil gempa terbaru dari BMKG.
 */
class BmkgGempaClient
{
    /**
     * @throws BmkgTidakMerespons bila jaringan/HTTP gagal
     * @throws FormatBmkgTidakDikenal bila struktur JSON berubah
     */
    public function gempaTerbaru(): DataGempa
    {
        $url = config('sicuaca.autogempa_url');

        try {
            $respons = Http::acceptJson()
                ->timeout(config('sicuaca.bmkg_timeout'))
                ->get($url);
        } catch (ConnectionException $e) {
            throw new BmkgTidakMerespons("tidak bisa terhubung ke {$url}: {$e->getMessage()}", previous: $e);
        }

        if (! $respons->successful()) {
            throw new BmkgTidakMerespons("{$url} membalas HTTP {$respons->status()}");
        }

        $json = $respons->json();
        if (! is_array($json)) {
            throw new FormatBmkgTidakDikenal('respons bukan objek JSON');
        }

        return DataGempa::dariAutogempa($json);
    }
}
