import '../core/parsing.dart';

/// Kategori US AQI (skala EPA AS), dipakai apa adanya dan diberi label "US AQI"
/// agar tidak tertukar dengan ISPU Indonesia yang batasnya berbeda.
enum KategoriAqi {
  baik,
  sedang,
  sensitif,
  tidakSehat,
  sangatTidakSehat,
  berbahaya;

  /// Kategori dari nilai US AQI; null bila nilai tidak ada.
  static KategoriAqi? dari(int? aqi) {
    if (aqi == null || aqi < 0) return null;
    if (aqi <= 50) return baik;
    if (aqi <= 100) return sedang;
    if (aqi <= 150) return sensitif;
    if (aqi <= 200) return tidakSehat;
    if (aqi <= 300) return sangatTidakSehat;
    return berbahaya;
  }
}

/// Kualitas udara saat ini dari Open-Meteo Air Quality API (model CAMS,
/// Copernicus). Hasil model berresolusi kasar, bukan sensor stasiun.
class KualitasUdara {
  const KualitasUdara({
    required this.waktu,
    required this.usAqi,
    required this.pm25,
    required this.pm10,
    required this.ozon,
    required this.nitrogenDioksida,
  });

  /// Membaca respons Open-Meteo: `{"current": {"time": ..., "us_aqi": ...}}`.
  /// Melempar [FormatException] bila blok `current` tidak ada.
  factory KualitasUdara.fromJson(Map<String, dynamic> json) {
    final saat = Baca.peta(json['current']);
    if (saat == null) {
      throw const FormatException(
        'Respons kualitas udara tanpa data saat ini.',
      );
    }
    return KualitasUdara(
      waktu: Baca.waktuSetempat(saat['time']),
      usAqi: Baca.bulat(saat['us_aqi']),
      pm25: Baca.angka(saat['pm2_5']),
      pm10: Baca.angka(saat['pm10']),
      ozon: Baca.angka(saat['ozone']),
      nitrogenDioksida: Baca.angka(saat['nitrogen_dioxide']),
    );
  }

  /// Waktu pengukuran model, jam dinding setempat (disimpan sebagai UTC).
  final DateTime? waktu;
  final int? usAqi;

  /// Partikel halus PM2,5 dan PM10, µg/m³.
  final double? pm25;
  final double? pm10;

  /// Ozon dan nitrogen dioksida permukaan, µg/m³.
  final double? ozon;
  final double? nitrogenDioksida;

  KategoriAqi? get kategori => KategoriAqi.dari(usAqi);
}
