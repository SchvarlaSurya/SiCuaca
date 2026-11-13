<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

/**
 * Menyimpan ringkasan pengecekan gempa terakhir (untuk endpoint /health).
 */
class StatusPengecekan
{
    private const KUNCI = 'sicuaca.cek_terakhir';

    /**
     * @param  array<string, mixed>  $ringkasan
     */
    public function catat(bool $berhasil, array $ringkasan = []): void
    {
        Cache::forever(self::KUNCI, [
            'waktu' => now()->toIso8601String(),
            'berhasil' => $berhasil,
            ...$ringkasan,
        ]);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function terakhir(): ?array
    {
        $data = Cache::get(self::KUNCI);

        return is_array($data) ? $data : null;
    }
}
