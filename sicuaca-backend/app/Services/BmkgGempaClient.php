<?php

namespace App\Services;

use App\Support\BmkgTidakMerespons;
use App\Support\DataGempa;
use App\Support\FormatBmkgTidakDikenal;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Mengambil data gempa dari BMKG, dengan percobaan ulang untuk gangguan
 * jaringan dan error server (5xx).
 */
class BmkgGempaClient
{
    /**
     * Gempa terbaru dari autogempa.json.
     *
     * @throws BmkgTidakMerespons
     * @throws FormatBmkgTidakDikenal
     */
    public function gempaTerbaru(): DataGempa
    {
        return DataGempa::dariAutogempa($this->ambilJson(config('sicuaca.autogempa_url')));
    }

    /**
     * 15 gempa terakhir M 5.0+ dari gempaterkini.json. Elemen yang tidak
     * valid dilewati dan dicatat di log.
     *
     * @return list<DataGempa>
     *
     * @throws BmkgTidakMerespons
     * @throws FormatBmkgTidakDikenal
     */
    public function gempaTerkini(): array
    {
        $url = config('sicuaca.gempaterkini_url');
        $dilewati = [];
        $daftar = DataGempa::daftarDariTerkini($this->ambilJson($url), $dilewati);
        if ($dilewati !== []) {
            Log::warning('BMKG gempaterkini: sebagian elemen dilewati', ['alasan' => $dilewati]);
        }

        return $daftar;
    }

    /**
     * @return array<string, mixed>
     */
    private function ambilJson(string $url): array
    {
        try {
            $respons = Http::acceptJson()
                ->timeout(config('sicuaca.bmkg_timeout'))
                ->retry(
                    max(1, config('sicuaca.bmkg_percobaan')),
                    config('sicuaca.bmkg_jeda_ms'),
                    fn (Throwable $e) => $e instanceof ConnectionException
                        || ($e instanceof RequestException && $e->response->serverError()),
                    throw: false,
                )
                ->get($url);
        } catch (ConnectionException $e) {
            throw new BmkgTidakMerespons("tidak bisa terhubung ke {$url}: {$e->getMessage()}", previous: $e);
        }

        if (! $respons->successful()) {
            throw new BmkgTidakMerespons("{$url} membalas HTTP {$respons->status()}");
        }

        $json = $respons->json();
        if (! is_array($json)) {
            throw new FormatBmkgTidakDikenal("{$url}: respons bukan objek JSON");
        }

        return $json;
    }
}
