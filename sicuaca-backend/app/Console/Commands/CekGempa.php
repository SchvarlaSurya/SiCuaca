<?php

namespace App\Console\Commands;

use App\Models\GempaTerkirim;
use App\Services\BmkgGempaClient;
use App\Services\PengirimNotifikasi;
use App\Support\BmkgTidakMerespons;
use App\Support\FormatBmkgTidakDikenal;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\Log;
use Throwable;

#[Signature('sicuaca:cek-gempa')]
#[Description('Cek gempa terbaru BMKG dan kirim notifikasi FCM bila ada gempa baru')]
class CekGempa extends Command
{
    public function handle(BmkgGempaClient $bmkg, PengirimNotifikasi $pengirim): int
    {
        try {
            $gempa = $bmkg->gempaTerbaru();
        } catch (BmkgTidakMerespons|FormatBmkgTidakDikenal $e) {
            Log::warning('sicuaca:cek-gempa gagal membaca BMKG', ['alasan' => $e->getMessage()]);
            $this->warn("BMKG tidak bisa dibaca: {$e->getMessage()}");

            return self::FAILURE;
        }

        $kunci = $gempa->kunci();
        $this->line("Gempa terbaru: M {$gempa->magnitudo} | {$gempa->tanggal} {$gempa->jam} | {$kunci}");

        if (GempaTerkirim::where('gempa_key', $kunci)->exists()) {
            $this->info('Sudah pernah diproses. Tidak ada yang dikirim.');

            return self::SUCCESS;
        }

        // Tabel kosong = pertama kali dijalankan. Gempa yang sedang tampil
        // hanya dicatat sebagai titik awal, tidak dikirim.
        $eksekusiPertama = GempaTerkirim::doesntExist();

        try {
            $rekaman = GempaTerkirim::create([
                'gempa_key' => $kunci,
                'magnitudo' => $gempa->magnitudo,
                'wilayah' => $gempa->wilayah,
            ]);
        } catch (UniqueConstraintViolationException) {
            // Proses lain (mis. dua scheduler) sudah mencatatnya duluan.
            $this->info('Sudah dicatat oleh proses lain. Tidak ada yang dikirim.');

            return self::SUCCESS;
        }

        if ($eksekusiPertama) {
            Log::info('sicuaca:cek-gempa eksekusi pertama, gempa dicatat tanpa notifikasi', ['gempa_key' => $kunci]);
            $this->info('Eksekusi pertama: gempa dicatat sebagai titik awal, notifikasi TIDAK dikirim.');

            return self::SUCCESS;
        }

        $topik = $gempa->topikTujuan(config('sicuaca.topik'));
        if ($topik === []) {
            $this->info('Magnitudo di bawah ambang terendah. Dicatat tanpa notifikasi.');

            return self::SUCCESS;
        }

        $data = [
            'jenis' => 'gempa',
            'gempa_key' => $kunci,
            'magnitudo' => (string) $gempa->magnitudo,
            'wilayah' => $gempa->wilayah,
            'kedalaman' => $gempa->kedalaman,
        ];

        $berhasil = 0;
        foreach ($topik as $t) {
            try {
                $pengirim->kirimKeTopik($t, $gempa->judulNotifikasi(), $gempa->isiNotifikasi(), $data);
                $berhasil++;
                $this->info("Terkirim ke topic {$t}.");
            } catch (Throwable $e) {
                Log::error('sicuaca:cek-gempa gagal mengirim FCM', [
                    'topic' => $t,
                    'gempa_key' => $kunci,
                    'alasan' => $e->getMessage(),
                ]);
                $this->error("Gagal mengirim ke {$t}: {$e->getMessage()}");
            }
        }

        if ($berhasil > 0) {
            $rekaman->update(['dikirim_at' => now()]);
        }

        return $berhasil === count($topik) ? self::SUCCESS : self::FAILURE;
    }
}
