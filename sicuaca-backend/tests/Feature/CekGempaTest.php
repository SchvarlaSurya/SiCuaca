<?php

namespace Tests\Feature;

use App\Models\GempaTerkirim;
use App\Services\PengirimNotifikasi;
use Closure;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Tests\TestCase;

class CekGempaTest extends TestCase
{
    use RefreshDatabase;

    private const AUTO = 'data.bmkg.go.id/DataMKG/TEWS/autogempa.json';

    private const TERKINI = 'data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json';

    /** @var list<array{topik: string, judul: string, isi: string, data: array<string, string>}> */
    public array $terkirim = [];

    public int $percobaan = 0;

    /** Bila diisi dan mengembalikan true, pengiriman ke topic itu gagal. */
    public ?Closure $gagalBila = null;

    protected function setUp(): void
    {
        parent::setUp();

        // Waktu tetap: 30 menit setelah gempa autogempa di fixture.
        Carbon::setTestNow('2026-11-13T08:00:00+00:00');

        $this->app->instance(PengirimNotifikasi::class, new class($this) implements PengirimNotifikasi
        {
            public function __construct(private CekGempaTest $tes) {}

            public function kirimKeTopik(string $topik, string $judul, string $isi, array $data = []): void
            {
                $this->tes->percobaan++;
                if ($this->tes->gagalBila && ($this->tes->gagalBila)($topik, $data)) {
                    throw new RuntimeException('FCM mati');
                }
                $this->tes->terkirim[] = compact('topik', 'judul', 'isi', 'data');
            }
        });
    }

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    /** @return array<string, mixed> */
    private function fixture(string $nama): array
    {
        return json_decode(file_get_contents(base_path("tests/Fixtures/{$nama}")), true);
    }

    /** @param array<string, string> $ubah */
    private function gempa(string $dateTime, string $magnitude, string $koordinat, array $ubah = []): array
    {
        return [
            'Tanggal' => '13 Nov 2026',
            'Jam' => '14:00:00 WIB',
            'DateTime' => $dateTime,
            'Coordinates' => $koordinat,
            'Lintang' => '1.00 LS',
            'Bujur' => '120.00 BT',
            'Magnitude' => $magnitude,
            'Kedalaman' => '10 km',
            'Wilayah' => "Gempa uji {$magnitude}",
            'Potensi' => 'Tidak berpotensi tsunami',
            ...$ubah,
        ];
    }

    /** Respons BMKG dari fixture asli (13 Nov 2026). */
    private function bmkgAsli(): void
    {
        Http::fake([
            self::AUTO => Http::response($this->fixture('autogempa.json')),
            self::TERKINI => Http::response($this->fixture('gempaterkini.json')),
        ]);
    }

    /** Tandai semua gempa di fixture sudah diproses, kecuali $kecuali. */
    private function semuaSudahDiproses(array $kecuali = []): void
    {
        $semua = [
            $this->fixture('autogempa.json')['Infogempa']['gempa'],
            ...$this->fixture('gempaterkini.json')['Infogempa']['gempa'],
        ];
        foreach ($semua as $g) {
            $kunci = "{$g['DateTime']}|{$g['Coordinates']}";
            if (! in_array($kunci, $kecuali, true)) {
                GempaTerkirim::firstOrCreate(['gempa_key' => $kunci], ['wilayah' => $g['Wilayah']]);
            }
        }
    }

    public function test_eksekusi_pertama_mencatat_semua_tanpa_mengirim(): void
    {
        $this->bmkgAsli();

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame([], $this->terkirim);
        // 1 dari autogempa + 15 dari gempaterkini, tidak ada yang tumpang tindih.
        $this->assertDatabaseCount('gempa_terkirim', 16);
        $this->assertSame(0, GempaTerkirim::whereNotNull('dikirim_at')->count());
    }

    public function test_gempa_baru_terkirim_dengan_payload_lengkap(): void
    {
        $kunci = '2026-11-13T07:31:39+00:00|-5.56,102.24';
        $this->semuaSudahDiproses(kecuali: [$kunci]);
        $this->bmkgAsli();

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        // M 4.1: hanya topic gempa_m4.
        $this->assertSame(['gempa_m4'], array_column($this->terkirim, 'topik'));
        $kiriman = $this->terkirim[0];
        $this->assertSame('Gempa M 4.1', $kiriman['judul']);
        $this->assertSame([
            'jenis' => 'gempa',
            'uji' => '0',
            'gempa_key' => $kunci,
            'magnitudo' => '4.1',
            'wilayah' => 'Pusat gempa berada di laut 24 km selatan Enggano',
            'kedalaman' => '24 km',
            'waktu' => '2026-11-13T07:31:39+00:00',
            'tanggal' => '13 Nov 2026',
            'jam' => '14:31:39 WIB',
            'koordinat' => '-5.56,102.24',
            'shakemap' => '20261113143139.mmi.jpg',
            'potensi' => 'Gempa ini dirasakan untuk diteruskan pada masyarakat',
            'dirasakan' => 'II - III Enggano',
        ], $kiriman['data']);
        foreach ($kiriman['data'] as $nilai) {
            $this->assertIsString($nilai);
        }
        $this->assertNotNull(GempaTerkirim::where('gempa_key', $kunci)->value('dikirim_at'));
    }

    public function test_gempa_lama_tidak_dikirim_ulang_saat_dijalankan_berulang(): void
    {
        $kunci = '2026-11-13T07:31:39+00:00|-5.56,102.24';
        $this->semuaSudahDiproses(kecuali: [$kunci]);
        $this->bmkgAsli();

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();
        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();
        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertCount(1, $this->terkirim);
        $this->assertSame(1, GempaTerkirim::where('gempa_key', $kunci)->count());
    }

    public function test_dua_gempa_dalam_satu_pengecekan_keduanya_terkirim_urut_terlama(): void
    {
        GempaTerkirim::create(['gempa_key' => 'titik-awal', 'wilayah' => 'x']);
        $a = $this->gempa('2026-11-13T07:50:00+00:00', '5.5', '-1.00,120.00');
        $b = $this->gempa('2026-11-13T07:40:00+00:00', '6.2', '-2.00,121.00');
        Http::fake([
            // autogempa hanya menunjukkan yang terbaru (A); B hanya ada di gempaterkini.
            self::AUTO => Http::response(['Infogempa' => ['gempa' => $a]]),
            self::TERKINI => Http::response(['Infogempa' => ['gempa' => [$a, $b]]]),
        ]);

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $urutan = array_map(fn ($k) => "{$k['data']['magnitudo']}>{$k['topik']}", $this->terkirim);
        $this->assertSame([
            '6.2>gempa_m4', '6.2>gempa_m5', '6.2>gempa_m6',
            '5.5>gempa_m4', '5.5>gempa_m5',
        ], $urutan);
        $this->assertSame(2, GempaTerkirim::whereNotNull('dikirim_at')->count());
    }

    public function test_gempa_lebih_tua_dari_batas_umur_hanya_dicatat(): void
    {
        GempaTerkirim::create(['gempa_key' => 'titik-awal', 'wilayah' => 'x']);
        $lama = $this->gempa('2026-11-12T20:00:00+00:00', '6.0', '-3.00,122.00');
        Http::fake([
            self::AUTO => Http::response(['Infogempa' => ['gempa' => $lama]]),
            self::TERKINI => Http::response(['Infogempa' => ['gempa' => [$lama]]]),
        ]);

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame([], $this->terkirim);
        $this->assertDatabaseCount('gempa_terkirim', 2);
    }

    public function test_bmkg_gagal_total_tidak_crash(): void
    {
        Http::fake(fn () => throw new ConnectionException('timeout'));

        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        $this->assertDatabaseCount('gempa_terkirim', 0);
        $this->assertSame([], $this->terkirim);
    }

    public function test_satu_sumber_gagal_sumber_lain_tetap_diproses(): void
    {
        GempaTerkirim::create(['gempa_key' => 'titik-awal', 'wilayah' => 'x']);
        $a = $this->gempa('2026-11-13T07:50:00+00:00', '5.1', '-1.00,120.00');
        Http::fake([
            self::AUTO => Http::response('down', 503),
            self::TERKINI => Http::response(['Infogempa' => ['gempa' => [$a, ['rusak' => true]]]]),
        ]);

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame(['gempa_m4', 'gempa_m5'], array_column($this->terkirim, 'topik'));
    }

    public function test_format_bmkg_berubah_tidak_crash(): void
    {
        Http::fake([
            self::AUTO => Http::response(['Infogempa' => ['gempa' => []]]),
            self::TERKINI => Http::response(['gempa' => 'lain']),
        ]);

        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        $this->assertDatabaseCount('gempa_terkirim', 0);
    }

    public function test_bmkg_dicoba_ulang_saat_error_server(): void
    {
        $this->semuaSudahDiproses();
        Http::fake([
            self::AUTO => Http::sequence()
                ->push('sibuk', 502)
                ->push($this->fixture('autogempa.json')),
            self::TERKINI => Http::response($this->fixture('gempaterkini.json')),
        ]);

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        Http::assertSentCount(3);
    }

    public function test_fcm_gagal_dicoba_ulang_dan_tidak_menghentikan_gempa_lain(): void
    {
        GempaTerkirim::create(['gempa_key' => 'titik-awal', 'wilayah' => 'x']);
        $a = $this->gempa('2026-11-13T07:50:00+00:00', '5.0', '-1.00,120.00');
        $b = $this->gempa('2026-11-13T07:40:00+00:00', '4.5', '-2.00,121.00');
        Http::fake([
            self::AUTO => Http::response(['Infogempa' => ['gempa' => $a]]),
            self::TERKINI => Http::response(['Infogempa' => ['gempa' => [$a, $b]]]),
        ]);
        // Gempa B (M 4.5) selalu gagal dikirim.
        $this->gagalBila = fn (string $topik, array $data) => $data['magnitudo'] === '4.5';

        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        // B: 3 percobaan gagal ke gempa_m4. A: 2 topic sukses.
        $this->assertSame(5, $this->percobaan);
        $this->assertSame(['gempa_m4', 'gempa_m5'], array_column($this->terkirim, 'topik'));
        $this->assertNull(GempaTerkirim::where('gempa_key', 'like', '2026-11-13T07:40%')->value('dikirim_at'));
        $this->assertNotNull(GempaTerkirim::where('gempa_key', 'like', '2026-11-13T07:50%')->value('dikirim_at'));
    }

    public function test_tes_notif_mengirim_payload_gempa_terbaru(): void
    {
        $this->bmkgAsli();

        $this->artisan('sicuaca:tes-notif', ['topic' => 'gempa_m5'])->assertSuccessful();

        $this->assertSame(['gempa_m5'], array_column($this->terkirim, 'topik'));
        $this->assertSame('Uji SiCuaca: Gempa M 4.1', $this->terkirim[0]['judul']);
        $this->assertSame('1', $this->terkirim[0]['data']['uji']);
        $this->assertSame('2026-11-13T07:31:39+00:00|-5.56,102.24', $this->terkirim[0]['data']['gempa_key']);
    }

    public function test_tes_notif_memakai_contoh_saat_bmkg_gagal_dan_menolak_topic_asing(): void
    {
        Http::fake(fn () => throw new ConnectionException('timeout'));

        $this->artisan('sicuaca:tes-notif', ['topic' => 'gempa_m6'])->assertSuccessful();
        $this->assertSame('-8.22,116.77', $this->terkirim[0]['data']['koordinat']);

        $this->artisan('sicuaca:tes-notif', ['topic' => 'semua'])->assertExitCode(2);
        $this->assertCount(1, $this->terkirim);
    }

    public function test_health_menunjukkan_pengecekan_terakhir(): void
    {
        $this->getJson('/health')
            ->assertStatus(503)
            ->assertJsonPath('pengecekan_terakhir', null);

        $this->bmkgAsli();
        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->getJson('/health')
            ->assertOk()
            ->assertJsonPath('status', 'ok')
            ->assertJsonPath('pengecekan_terakhir.berhasil', true)
            ->assertJsonPath('pengecekan_terakhir.dibaca', 16)
            ->assertJsonPath('gempa_tercatat', 16);

        // 10 menit tanpa pengecekan: dianggap terlambat.
        Carbon::setTestNow(now()->addMinutes(10));
        $this->getJson('/health')
            ->assertStatus(503)
            ->assertJsonPath('pengecekan_terlambat', true);
    }
}
