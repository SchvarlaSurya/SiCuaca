/// Nilai tetap aplikasi. Semua URL BMKG, batas waktu jaringan, dan kunci
/// penyimpanan ada di sini, supaya tidak tersebar di dalam method.
class ApiConstants {
  const ApiConstants._();

  /// Gempa terbaru (M ≥ 5 atau dirasakan), satu kejadian.
  static const String autoGempaUrl =
      'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json';

  /// 15 gempa terakhir dengan magnitudo 5.0 ke atas.
  static const String gempaTerkiniUrl =
      'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json';

  /// 15 gempa terakhir yang dirasakan (semua magnitudo).
  static const String gempaDirasakanUrl =
      'https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json';

  /// Folder tempat file shakemap disimpan. Nama file diambil dari field
  /// `Shakemap` pada respons autogempa.
  static const String shakemapBaseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS/';

  /// Prakiraan cuaca per kelurahan/desa. Butuh query `adm4`.
  static const String prakiraanCuacaUrl =
      'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  /// API publik data maritim BMKG (dokumentasi: maritim.bmkg.go.id/apidoc).
  /// Semua GET, tanpa autentikasi, data diperbarui sekitar 00 UTC.
  static const String maritimBaseUrl =
      'https://maritim.bmkg.go.id/marine2026-data';

  /// Daftar wilayah perairan per provinsi (±51 KB).
  static const String maritimAreaUrl =
      '$maritimBaseUrl/meta/area_province.json';

  /// Poligon wilayah perairan, GeoJSON (±1,6 MB; diunduh jarang).
  static const String maritimWilayahUrl =
      '$maritimBaseUrl/meta/wilmetos.min.geojson';

  /// Prakiraan satu wilayah perairan (±10 KB).
  static String maritimPerairanUrl(String kode) =>
      '$maritimBaseUrl/perairan/$kode.json';

  /// Kualitas udara dari Open-Meteo (BUKAN BMKG): model CAMS, tanpa kunci API,
  /// lisensi data CC BY 4.0 (wajib kredit ke Open-Meteo dan CAMS), paket
  /// gratis hanya untuk penggunaan nonkomersial.
  static const String openMeteoUdaraUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  /// Variabel `current` yang diminta.
  static const String openMeteoUdaraParameter =
      'us_aqi,pm2_5,pm10,ozone,nitrogen_dioxide';

  /// Halaman sumber untuk tautan kredit.
  static const String openMeteoHalaman = 'https://open-meteo.com/';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

/// Halaman resmi BMKG untuk layanan tanpa API terbuka (dibuka di browser
/// dalam aplikasi; isinya tidak disalin).
class TautanResmi {
  const TautanResmi._();

  static const String radar = 'https://www.bmkg.go.id/cuaca/radar';
  static const String penerbangan = 'https://aviation.bmkg.go.id';
  static const String titikPanas =
      'https://www.bmkg.go.id/cuaca/satelit/polar-hotspot';
  static const String iklim = 'https://www.bmkg.go.id/iklim';
  static const String siaranPers = 'https://www.bmkg.go.id/siaran-pers';
  static const String maritim = 'https://maritim.bmkg.go.id';
}

class WilayahConstants {
  const WilayahConstants._();

  /// Daftar kode wilayah Kepmendagri + titik tengah desa. Dibangun oleh
  /// `tool/build_wilayah.py`.
  static const String assetPath = 'assets/data/wilayah.tsv';

  /// Jumlah maksimal hasil pencarian yang ditampilkan.
  static const int batasHasilCari = 50;

  /// Huruf minimal sebelum pencarian dijalankan.
  static const int minimalHurufCari = 3;

  /// Bila desa terdekat lebih jauh dari ini, posisi GPS dianggap di luar
  /// wilayah Indonesia dan pengguna diminta memilih manual.
  static const double radiusMaksimalKm = 50;
}

class LokasiConstants {
  const LokasiConstants._();

  static const Duration batasWaktuGps = Duration(seconds: 15);
}

class PrefsKeys {
  const PrefsKeys._();

  static const String wilayahTerakhir = 'wilayah_terakhir';
  static const String wilayahFavorit = 'wilayah_favorit';
  static const String ambangGempa = 'ambang_gempa';
  static const String bahasa = 'bahasa';
  static const String tema = 'tema';
  static const String sudahOnboarding = 'sudah_onboarding';
  static const String kacaCair = 'kaca_cair';
  static const String maritimPerairan = 'maritim_perairan';

  /// Awalan kunci cache (lihat CacheService).
  static const String cache = 'cache.';
  static const String riwayatGempa = 'riwayat_gempa';
  static const String riwayatNotifikasi = 'riwayat_notifikasi';
  static const String urutanBeranda = 'urutan_beranda';
}

class NotifikasiConstants {
  const NotifikasiConstants._();

  /// Harus sama dengan `android_channel_id` di backend (config/sicuaca.php)
  /// dan meta-data default channel di AndroidManifest.xml.
  static const String channelGempaId = 'gempa_bumi';
}
