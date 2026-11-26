<?php

namespace Tests\Feature;

use App\Models\GempaTerkirim;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Pemeriksaan khusus MySQL. Dilewati di SQLite (tes harian), dijalankan oleh
 * `scripts/uji-mysql.ps1` pada server MySQL sementara. Membuktikan bahwa tes
 * benar-benar memakai MySQL dan mencakup hal yang berbeda dari SQLite:
 * charset, panjang indeks unik, desimal, dan zona waktu.
 */
class MySqlSungguhanTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        if (DB::connection()->getDriverName() !== 'mysql') {
            $this->markTestSkipped('Hanya dijalankan di MySQL (scripts/uji-mysql.ps1).');
        }
    }

    public function test_memakai_mysql_dengan_utf8mb4(): void
    {
        $this->assertSame('mysql', DB::connection()->getDriverName());

        $koneksi = DB::selectOne('SELECT @@character_set_connection AS cs, @@collation_connection AS co');
        $this->assertSame('utf8mb4', $koneksi->cs);
        $this->assertStringStartsWith('utf8mb4_', $koneksi->co);

        $tabel = DB::selectOne(
            'SELECT TABLE_COLLATION AS co FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?',
            [DB::connection()->getDatabaseName(), 'gempa_terkirim'],
        );
        $this->assertStringStartsWith('utf8mb4_', $tabel->co);
    }

    public function test_zona_waktu_sesi_utc_dan_waktu_bolak_balik_sama(): void
    {
        $this->assertSame('+00:00', DB::selectOne('SELECT @@session.time_zone AS z')->z);

        GempaTerkirim::create([
            'gempa_key' => 'zona-waktu',
            'magnitudo' => 5.7,
            'wilayah' => 'Uji',
            'dikirim_at' => '2026-11-26 05:00:00',
        ]);

        // Terbaca persis sama lewat model, dan sama di kolom mentah.
        $this->assertSame(
            '2026-11-26 05:00:00',
            GempaTerkirim::where('gempa_key', 'zona-waktu')->first()->dikirim_at->utc()->format('Y-m-d H:i:s'),
        );
        $this->assertSame(
            '2026-11-26 05:00:00',
            DB::selectOne('SELECT CAST(dikirim_at AS CHAR) AS t FROM gempa_terkirim WHERE gempa_key = ?', ['zona-waktu'])->t,
        );
    }

    public function test_magnitudo_desimal_satu_angka_tidak_bergeser(): void
    {
        foreach ([4.0, 5.5, 6.3, 7.9] as $i => $m) {
            GempaTerkirim::create([
                'gempa_key' => "mag-$i",
                'magnitudo' => $m,
                'wilayah' => 'Uji',
            ]);
        }

        $this->assertSame(
            [4.0, 5.5, 6.3, 7.9],
            GempaTerkirim::orderBy('magnitudo')->pluck('magnitudo')->all(),
        );
    }

    public function test_indeks_unik_menolak_kunci_ganda_dan_menerima_kunci_panjang(): void
    {
        // Kunci panjang (255 karakter utf8mb4 = 1020 byte) muat di indeks unik.
        $panjang = str_repeat('é', 255);
        GempaTerkirim::create(['gempa_key' => $panjang, 'magnitudo' => 5.0, 'wilayah' => 'Uji']);
        $this->assertTrue(GempaTerkirim::where('gempa_key', $panjang)->exists());

        $this->expectException(QueryException::class);
        GempaTerkirim::create(['gempa_key' => $panjang, 'magnitudo' => 5.0, 'wilayah' => 'Uji']);
    }

    public function test_teks_wilayah_unicode_dan_emoji_utuh(): void
    {
        $wilayah = 'Lepas pantai Maluku Utara – 𝗨𝗷𝗶 🌏';
        GempaTerkirim::create(['gempa_key' => 'unicode', 'magnitudo' => 5.1, 'wilayah' => $wilayah]);

        $this->assertSame($wilayah, GempaTerkirim::where('gempa_key', 'unicode')->value('wilayah'));
    }

    public function test_health_memeriksa_koneksi_database(): void
    {
        $respons = $this->getJson('/health');

        // Pengecekan gempa belum pernah jalan di database kosong: 503, tetapi
        // koneksi database harus terbaca "ok".
        $respons->assertStatus(503)->assertJsonPath('database', 'ok');
    }
}
