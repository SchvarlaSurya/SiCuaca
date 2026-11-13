<?php

namespace App\Services;

/**
 * Pengirim push notification ke topic. Dipisah sebagai interface agar
 * bisa diganti versi palsu saat pengujian.
 */
interface PengirimNotifikasi
{
    /**
     * @param  array<string, string>  $data  payload tambahan untuk aplikasi
     *
     * @throws \Throwable bila pengiriman gagal
     */
    public function kirimKeTopik(string $topik, string $judul, string $isi, array $data = []): void;
}
