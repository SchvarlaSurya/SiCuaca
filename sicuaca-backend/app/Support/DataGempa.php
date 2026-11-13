<?php

namespace App\Support;

use Carbon\CarbonImmutable;
use Throwable;

/**
 * Satu gempa dari BMKG (autogempa.json atau elemen gempaterkini.json),
 * sudah divalidasi.
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
        public string $potensi = '',
        public string $dirasakan = '',
        public string $shakemap = '',
    ) {}

    /**
     * Membaca respons autogempa.json: `{"Infogempa": {"gempa": {...}}}`.
     *
     * @param  array<string, mixed>  $json
     */
    public static function dariAutogempa(array $json): self
    {
        $gempa = $json['Infogempa']['gempa'] ?? null;
        if (! is_array($gempa) || array_is_list($gempa)) {
            throw new FormatBmkgTidakDikenal('kunci Infogempa.gempa bukan objek');
        }

        return self::dariObjek($gempa);
    }

    /**
     * Membaca respons gempaterkini.json: `{"Infogempa": {"gempa": [...]}}`.
     * Elemen yang tidak valid dilewati dan dilaporkan lewat $dilewati.
     *
     * @param  array<string, mixed>  $json
     * @param  list<string>  $dilewati  alasan elemen yang dilewati (keluaran)
     * @return list<self>
     */
    public static function daftarDariTerkini(array $json, array &$dilewati = []): array
    {
        $daftar = $json['Infogempa']['gempa'] ?? null;
        if (! is_array($daftar) || ! array_is_list($daftar)) {
            throw new FormatBmkgTidakDikenal('kunci Infogempa.gempa bukan daftar');
        }

        $hasil = [];
        foreach ($daftar as $i => $gempa) {
            try {
                if (! is_array($gempa)) {
                    throw new FormatBmkgTidakDikenal('elemen bukan objek');
                }
                $hasil[] = self::dariObjek($gempa);
            } catch (FormatBmkgTidakDikenal $e) {
                $dilewati[] = "elemen {$i}: {$e->getMessage()}";
            }
        }

        return $hasil;
    }

    /**
     * Membaca satu objek gempa. Melempar FormatBmkgTidakDikenal bila field
     * penting tidak ada atau tidak bisa dibaca.
     *
     * @param  array<string, mixed>  $gempa
     */
    public static function dariObjek(array $gempa): self
    {
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

        try {
            CarbonImmutable::parse($teks('DateTime'));
        } catch (Throwable) {
            throw new FormatBmkgTidakDikenal("DateTime tidak terbaca: {$teks('DateTime')}");
        }

        return new self(
            dateTime: $teks('DateTime'),
            koordinat: $teks('Coordinates'),
            magnitudo: (float) $magnitudo,
            wilayah: $teks('Wilayah'),
            kedalaman: $teks('Kedalaman'),
            tanggal: $teks('Tanggal'),
            jam: $teks('Jam'),
            potensi: $teks('Potensi'),
            dirasakan: $teks('Dirasakan'),
            shakemap: $teks('Shakemap'),
        );
    }

    /** Kunci unik: waktu + koordinat pusat gempa. */
    public function kunci(): string
    {
        return "{$this->dateTime}|{$this->koordinat}";
    }

    public function waktu(): CarbonImmutable
    {
        return CarbonImmutable::parse($this->dateTime);
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

    /**
     * Data FCM untuk aplikasi (semua nilai string). Lihat README untuk
     * format lengkapnya. Teks panjang dipotong agar payload tetap jauh di
     * bawah batas 4 KB FCM.
     *
     * @return array<string, string>
     */
    public function payload(bool $uji = false): array
    {
        $potong = fn (string $s, int $maks): string => mb_strimwidth($s, 0, $maks, '…');

        return [
            'jenis' => 'gempa',
            'uji' => $uji ? '1' : '0',
            'gempa_key' => $this->kunci(),
            'magnitudo' => number_format($this->magnitudo, 1, '.', ''),
            'wilayah' => $potong($this->wilayah, 200),
            'kedalaman' => $this->kedalaman,
            'waktu' => $this->dateTime,
            'tanggal' => $this->tanggal,
            'jam' => $this->jam,
            'koordinat' => $this->koordinat,
            'shakemap' => $this->shakemap,
            'potensi' => $potong($this->potensi, 200),
            'dirasakan' => $potong($this->dirasakan, 400),
        ];
    }
}
