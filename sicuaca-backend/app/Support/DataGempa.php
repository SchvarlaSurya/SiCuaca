<?php

namespace App\Support;

/**
 * Satu gempa dari autogempa.json BMKG, sudah divalidasi.
 */
final readonly class DataGempa
{
    public function __construct(
        public string $dateTime,
        public string $koordinat,
        public float $magnitudo,
        public string $wilayah,
        public string $kedalaman,
        public string $tanggal,
        public string $jam,
    ) {}

    /**
     * Membaca isi `Infogempa.gempa`. Melempar FormatBmkgTidakDikenal bila
     * field penting tidak ada atau magnitudo bukan angka.
     *
     * @param  array<string, mixed>  $json  seluruh respons autogempa.json
     */
    public static function dariAutogempa(array $json): self
    {
        $gempa = $json['Infogempa']['gempa'] ?? null;
        if (! is_array($gempa)) {
            throw new FormatBmkgTidakDikenal('kunci Infogempa.gempa tidak ada');
        }

        $teks = fn (string $kunci): string => trim((string) ($gempa[$kunci] ?? ''));

        foreach (['DateTime', 'Coordinates', 'Magnitude'] as $wajib) {
            if ($teks($wajib) === '') {
                throw new FormatBmkgTidakDikenal("field {$wajib} kosong");
            }
        }

        $magnitudo = str_replace(',', '.', $teks('Magnitude'));
        if (! is_numeric($magnitudo)) {
            throw new FormatBmkgTidakDikenal("Magnitude bukan angka: {$teks('Magnitude')}");
        }

        return new self(
            dateTime: $teks('DateTime'),
            koordinat: $teks('Coordinates'),
            magnitudo: (float) $magnitudo,
            wilayah: $teks('Wilayah'),
            kedalaman: $teks('Kedalaman'),
            tanggal: $teks('Tanggal'),
            jam: $teks('Jam'),
        );
    }

    /** Kunci unik: waktu + koordinat pusat gempa. */
    public function kunci(): string
    {
        return "{$this->dateTime}|{$this->koordinat}";
    }

    /**
     * Topic tujuan, kumulatif: semua topic yang ambangnya <= magnitudo.
     *
     * @param  array<string, float>  $ambang  topic => magnitudo minimum
     * @return list<string>
     */
    public function topikTujuan(array $ambang): array
    {
        return array_keys(array_filter($ambang, fn (float $min) => $this->magnitudo >= $min));
    }

    public function judulNotifikasi(): string
    {
        return 'Gempa M '.number_format($this->magnitudo, 1);
    }

    public function isiNotifikasi(): string
    {
        $bagian = array_filter([
            $this->wilayah,
            $this->kedalaman !== '' ? "Kedalaman {$this->kedalaman}" : '',
        ]);

        return implode('. ', $bagian).'.';
    }
}
