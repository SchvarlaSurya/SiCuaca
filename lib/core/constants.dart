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

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
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
}

class NotifikasiConstants {
  const NotifikasiConstants._();

  /// Harus sama dengan `android_channel_id` di backend (config/sicuaca.php)
  /// dan meta-data default channel di AndroidManifest.xml.
  static const String channelGempaId = 'gempa_bumi';
}
