<?php

namespace App\Http\Controllers;

use App\Models\GempaTerkirim;
use App\Services\StatusPengecekan;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Throwable;

/**
 * GET /health: kapan gempa terakhir dicek. 200 bila pengecekan masih
 * berjalan, 503 bila belum pernah atau sudah terlalu lama (cron mati).
 */
class HealthController extends Controller
{
    public function __invoke(StatusPengecekan $status): JsonResponse
    {
        $terakhir = $status->terakhir();
        $batas = now()->subMinutes(config('sicuaca.health_batas_menit'));

        $segar = false;
        if ($terakhir !== null) {
            try {
                $segar = CarbonImmutable::parse($terakhir['waktu'])->greaterThanOrEqualTo($batas);
            } catch (Throwable) {
                $segar = false;
            }
        }

        try {
            $tercatat = GempaTerkirim::count();
            $kirimTerakhir = GempaTerkirim::whereNotNull('dikirim_at')->max('dikirim_at');
            $database = 'ok';
        } catch (Throwable) {
            $tercatat = null;
            $kirimTerakhir = null;
            $database = 'gagal';
        }

        $ok = $segar && $database === 'ok';

        return response()->json([
            'status' => $ok ? 'ok' : 'bermasalah',
            'pengecekan_terakhir' => $terakhir,
            'pengecekan_terlambat' => ! $segar,
            'database' => $database,
            'gempa_tercatat' => $tercatat,
            'notifikasi_terakhir_dikirim' => $kirimTerakhir,
            'waktu_server' => now()->toIso8601String(),
        ], $ok ? 200 : 503);
    }
}
