<?php

namespace Tests\Unit;

use App\Support\DataGempa;
use App\Support\FormatBmkgTidakDikenal;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

class DataGempaTest extends TestCase
{
    private const AMBANG = ['gempa_m4' => 4.0, 'gempa_m5' => 5.0, 'gempa_m6' => 6.0];

    private function gempa(string $magnitude): DataGempa
    {
        return DataGempa::dariAutogempa(['Infogempa' => ['gempa' => [
            'DateTime' => '2026-11-13T04:49:34+00:00',
            'Coordinates' => '-8.22,116.77',
            'Magnitude' => $magnitude,
        ]]]);
    }

    /** @return array<string, array{string, list<string>}> */
    public static function magnitudo(): array
    {
        return [
            'M 3.9' => ['3.9', []],
            'M 4.0' => ['4.0', ['gempa_m4']],
            'M 5.5' => ['5.5', ['gempa_m4', 'gempa_m5']],
            'M 6.2' => ['6.2', ['gempa_m4', 'gempa_m5', 'gempa_m6']],
            'koma' => ['5,0', ['gempa_m4', 'gempa_m5']],
        ];
    }

    #[DataProvider('magnitudo')]
    public function test_topik_kumulatif(string $magnitude, array $harapan): void
    {
        $this->assertSame($harapan, $this->gempa($magnitude)->topikTujuan(self::AMBANG));
    }

    public function test_kunci_gabungan_waktu_dan_koordinat(): void
    {
        $this->assertSame('2026-11-13T04:49:34+00:00|-8.22,116.77', $this->gempa('5.0')->kunci());
    }

    public function test_magnitudo_bukan_angka_ditolak(): void
    {
        $this->expectException(FormatBmkgTidakDikenal::class);
        $this->gempa('besar');
    }
}
