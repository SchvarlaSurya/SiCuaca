/// Nilai tetap aplikasi. Semua URL BMKG dan batas waktu jaringan ada di sini,
/// supaya tidak tersebar di dalam method.
class AppConstants {
  const AppConstants._();

  static const String appName = 'SiCuaca';
}

class ApiConstants {
  const ApiConstants._();

  /// Gempa terbaru (M ≥ 5 atau dirasakan), satu kejadian.
  static const String autoGempaUrl =
      'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json';

  /// Folder tempat file shakemap disimpan. Nama file diambil dari field
  /// `Shakemap` pada respons autogempa.
  static const String shakemapBaseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS/';

  /// Prakiraan cuaca per kelurahan/desa. Butuh query `adm4`.
  static const String prakiraanCuacaUrl =
      'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
