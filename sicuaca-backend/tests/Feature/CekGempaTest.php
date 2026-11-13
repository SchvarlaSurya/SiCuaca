<?php

namespace Tests\Feature;

use App\Models\GempaTerkirim;
use App\Services\PengirimNotifikasi;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Tests\TestCase;

class CekGempaTest extends TestCase
{
    use RefreshDatabase;

    /** @var list<array{topik: string, judul: string, isi: string}> */
    private array $terkirim = [];

    private bool $fcmGagal = false;

    protected function setUp(): void
    {
        parent::setUp();

        $this->app->instance(PengirimNotifikasi::class, new class($this) implements PengirimNotifikasi
        {
            public function __construct(private CekGempaTest $tes) {}

            public function kirimKeTopik(string $topik, string $judul, string $isi, array $data = []): void
            {
                $this->tes->catatKiriman($topik, $judul, $isi);
            }
        });
    }

    public function catatKiriman(string $topik, string $judul, string $isi): void
    {
        if ($this->fcmGagal) {
            throw new RuntimeException('FCM mati');
        }
        $this->terkirim[] = compact('topik', 'judul', 'isi');
    }

    /** Respons dengan struktur asli autogempa.json (13 Nov 2026). */
    private function bmkg(string $dateTime = '2026-11-13T04:49:34+00:00', string $magnitude = '4.9'): void
    {
        Http::fake([
            'data.bmkg.go.id/*' => Http::response(['Infogempa' => ['gempa' => [
                'Tanggal' => '13 Nov 2026',
                'Jam' => '11:49:34 WIB',
                'DateTime' => $dateTime,
                'Coordinates' => '-8.22,116.77',
                'Lintang' => '8.22 LS',
                'Bujur' => '116.77 BT',
                'Magnitude' => $magnitude,
                'Kedalaman' => '17 km',
                'Wilayah' => 'Pusat gempa berada di laut 29 km Barat Laut PULAUPANJANG',
                'Potensi' => 'Gempa ini dirasakan untuk diteruskan pada masyarakat',
                'Dirasakan' => 'IV Kab. Lombok Timur',
                'Shakemap' => '20261113114934.mmi.jpg',
            ]]]),
        ]);
    }

    public function test_eksekusi_pertama_mencatat_tanpa_mengirim(): void
    {
        $this->bmkg(magnitude: '6.1');

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame([], $this->terkirim);
        $this->assertDatabaseCount('gempa_terkirim', 1);
        $this->assertNull(GempaTerkirim::first()->dikirim_at);
    }

    public function test_dua_kali_berturut_turut_tidak_mengirim_ganda(): void
    {
        GempaTerkirim::create(['gempa_key' => 'lama', 'wilayah' => 'x']);
        $this->bmkg(magnitude: '5.5');

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();
        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame(['gempa_m4', 'gempa_m5'], array_column($this->terkirim, 'topik'));
        $this->assertDatabaseCount('gempa_terkirim', 2);
    }

    public function test_topic_kumulatif_sesuai_magnitudo(): void
    {
        GempaTerkirim::create(['gempa_key' => 'lama', 'wilayah' => 'x']);
        $this->bmkg(magnitude: '6.2');

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame(['gempa_m4', 'gempa_m5', 'gempa_m6'], array_column($this->terkirim, 'topik'));
        $this->assertSame('Gempa M 6.2', $this->terkirim[0]['judul']);
        $this->assertSame(
            'Pusat gempa berada di laut 29 km Barat Laut PULAUPANJANG. Kedalaman 17 km.',
            $this->terkirim[0]['isi'],
        );
        $this->assertNotNull(GempaTerkirim::where('gempa_key', 'like', '2026-%')->first()->dikirim_at);
    }

    public function test_di_bawah_m4_hanya_dicatat(): void
    {
        GempaTerkirim::create(['gempa_key' => 'lama', 'wilayah' => 'x']);
        $this->bmkg(magnitude: '3.9');

        $this->artisan('sicuaca:cek-gempa')->assertSuccessful();

        $this->assertSame([], $this->terkirim);
        $this->assertDatabaseCount('gempa_terkirim', 2);
    }

    public function test_bmkg_tidak_merespons_dicatat_di_log_tanpa_crash(): void
    {
        Http::fake(fn () => throw new ConnectionException('timeout'));

        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        $this->assertDatabaseCount('gempa_terkirim', 0);
    }

    public function test_bmkg_http_error_dan_format_berubah_tidak_crash(): void
    {
        Http::fake(['data.bmkg.go.id/*' => Http::response('down', 503)]);
        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        Http::fake(['data.bmkg.go.id/*' => Http::response(['Infogempa' => ['gempa' => []]])]);
        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        Http::fake(['data.bmkg.go.id/*' => Http::response(['gempa' => ['Magnitude' => 'lima']])]);
        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        $this->assertDatabaseCount('gempa_terkirim', 0);
    }

    public function test_fcm_gagal_dicatat_dan_tidak_dikirim_ulang(): void
    {
        GempaTerkirim::create(['gempa_key' => 'lama', 'wilayah' => 'x']);
        $this->bmkg(magnitude: '5.0');
        $this->fcmGagal = true;

        $this->artisan('sicuaca:cek-gempa')->assertFailed();

        $rekaman = GempaTerkirim::where('gempa_key', 'like', '2026-%')->first();
        $this->assertNotNull($rekaman);
        $this->assertNull($rekaman->dikirim_at);
    }

    public function test_tes_notif_mengirim_ke_topic_dan_menolak_topic_asing(): void
    {
        $this->artisan('sicuaca:tes-notif', ['topic' => 'gempa_m5'])->assertSuccessful();
        $this->assertSame(['gempa_m5'], array_column($this->terkirim, 'topik'));

        $this->artisan('sicuaca:tes-notif', ['topic' => 'semua'])->assertExitCode(2);
        $this->assertCount(1, $this->terkirim);
    }
}
