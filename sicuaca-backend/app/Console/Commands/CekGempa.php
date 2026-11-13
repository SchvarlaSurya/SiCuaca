<?php

namespace App\Console\Commands;

use App\Models\GempaTerkirim;
use App\Services\BmkgGempaClient;
use App\Services\PengirimGempa;
use App\Services\StatusPengecekan;
use App\Support\BmkgTidakMerespons;
use App\Support\DataGempa;
use App\Support\FormatBmkgTidakDikenal;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\Log;

#[Signature('sicuaca:cek-gempa')]
#[Description('Cek gempa baru BMKG (autogempa + gempaterkini) dan kirim notifikasi FCM')]
class CekGempa extends Command
{
    public function handle(BmkgGempaClient $bmkg, PengirimGempa $pengirim, StatusPengecekan $status): int
    {
        $gempa = $this->kumpulkan($bmkg);
        if ($gempa === null) {
            $status->catat(false, ['alasan' => 'semua sumber BMKG gagal dibaca']);

            return self::FAILURE;
        }

        // Tabel kosong = pertama kali dijalankan: semua gempa yang sedang
        // tampil hanya dicatat sebagai titik awal, tidak dikirim.
        $eksekusiPertama = GempaTerkirim::doesntExist();

        $sudahAda = GempaTerkirim::whereIn('gempa_key', array_keys($gempa))
            ->pluck('gempa_key')
            ->flip();
        $baru = array_values(array_filter(
            $gempa,
            fn (DataGempa $g) => ! $sudahAda->has($g->kunci()),
        ));

        $this->line(sprintf('%d gempa dibaca, %d baru.', count($gempa), count($baru)));

        $terkirim = 0;
        $gagalKirim = 0;
        $batasUmur = now()->subHours(config('sicuaca.maks_umur_jam'));

        // $gempa sudah urut dari yang terlama.
        foreach ($baru as $g) {
            $rekaman = $this->catatGempa($g);
            if ($rekaman === null) {
                continue;
            }
            $label = "M {$g->magnitudo} | {$g->dateTime} | {$g->wilayah}";

            if ($eksekusiPertama) {
                $this->line("Dicatat (eksekusi pertama, tidak dikirim): {$label}");

                continue;
            }
            if ($g->waktu()->lessThan($batasUmur)) {
                $this->line("Dicatat (lebih tua dari batas umur, tidak dikirim): {$label}");

                continue;
            }
            $topik = $g->topikTujuan(config('sicuaca.topik'));
            if ($topik === []) {
                $this->line("Dicatat (di bawah ambang terendah): {$label}");

                continue;
            }

            $hasil = $pengirim->kirim($g, $topik, $g->judulNotifikasi());
            if ($hasil['terkirim'] !== []) {
                $rekaman->update(['dikirim_at' => now()]);
                $terkirim++;
                $this->info('Terkirim ke '.implode(', ', $hasil['terkirim']).": {$label}");
            }
            if ($hasil['gagal'] !== []) {
                $gagalKirim++;
                $this->error('Gagal ke '.implode(', ', $hasil['gagal']).": {$label}");
            }
        }

        if ($eksekusiPertama && $baru !== []) {
            Log::info('sicuaca:cek-gempa eksekusi pertama, gempa dicatat tanpa notifikasi', ['jumlah' => count($baru)]);
            $this->info('Eksekusi pertama: semua gempa dicatat sebagai titik awal, notifikasi TIDAK dikirim.');
        }

        $status->catat($gagalKirim === 0, [
            'dibaca' => count($gempa),
            'baru' => count($baru),
            'terkirim' => $terkirim,
            'gagal_kirim' => $gagalKirim,
        ]);

        return $gagalKirim === 0 ? self::SUCCESS : self::FAILURE;
    }

    /**
     * Gabungan autogempa + gempaterkini tanpa duplikat, urut terlama dulu.
     * Null bila kedua sumber gagal dibaca.
     *
     * @return array<string, DataGempa>|null
     */
    private function kumpulkan(BmkgGempaClient $bmkg): ?array
    {
        $sumber = [
            'autogempa' => fn () => [$bmkg->gempaTerbaru()],
            'gempaterkini' => fn () => $bmkg->gempaTerkini(),
        ];

        $gempa = [];
        $berhasil = 0;
        foreach ($sumber as $nama => $ambil) {
            try {
                foreach ($ambil() as $g) {
                    $gempa[$g->kunci()] ??= $g;
                }
                $berhasil++;
            } catch (BmkgTidakMerespons|FormatBmkgTidakDikenal $e) {
                Log::warning("sicuaca:cek-gempa gagal membaca {$nama}", ['alasan' => $e->getMessage()]);
                $this->warn("{$nama} tidak bisa dibaca: {$e->getMessage()}");
            }
        }

        if ($berhasil === 0) {
            return null;
        }

        uasort($gempa, fn (DataGempa $a, DataGempa $b) => $a->waktu() <=> $b->waktu());

        return $gempa;
    }

    /** Null bila proses lain sudah mencatat gempa yang sama. */
    private function catatGempa(DataGempa $g): ?GempaTerkirim
    {
        try {
            return GempaTerkirim::create([
                'gempa_key' => $g->kunci(),
                'magnitudo' => $g->magnitudo,
                'wilayah' => $g->wilayah,
            ]);
        } catch (UniqueConstraintViolationException) {
            $this->line("Sudah dicatat proses lain: {$g->kunci()}");

            return null;
        }
    }
}
