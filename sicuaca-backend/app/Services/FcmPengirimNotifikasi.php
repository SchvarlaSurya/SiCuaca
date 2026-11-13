<?php

namespace App\Services;

use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

/**
 * Mengirim lewat Firebase Cloud Messaging (kreait/laravel-firebase).
 * Kredensial dibaca dari FIREBASE_CREDENTIALS di .env.
 */
class FcmPengirimNotifikasi implements PengirimNotifikasi
{
    public function kirimKeTopik(string $topik, string $judul, string $isi, array $data = []): void
    {
        // Diambil saat dipakai, supaya kredensial yang belum diisi hanya
        // menggagalkan pengiriman, bukan seluruh command.
        $messaging = app(Messaging::class);

        $pesan = CloudMessage::new()
            ->toTopic($topik)
            ->withNotification(Notification::create($judul, $isi))
            ->withData($data)
            ->withAndroidConfig(AndroidConfig::fromArray([
                'priority' => 'high',
                'notification' => [
                    'channel_id' => config('sicuaca.android_channel_id'),
                    'sound' => 'default',
                    'notification_priority' => 'PRIORITY_HIGH',
                ],
            ]));

        $messaging->send($pesan);
    }
}
