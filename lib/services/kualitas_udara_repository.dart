import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/kualitas_udara.dart';
import 'api_service.dart';
import 'bmkg_repository.dart';
import 'cache_service.dart';

/// Kualitas udara dari Open-Meteo (model CAMS) dengan cache ber-TTL.
///
/// Bukan data BMKG. Yang dikirim ke Open-Meteo hanya koordinat titik pusat
/// wilayah yang sedang dilihat, dibulatkan ke 0,1 derajat (sekitar 11 km,
/// lebih halus dari resolusi model 45 km), tanpa identitas apa pun. Data
/// diperbarui tiap jam, jadi hasil yang masih segar (TTL 1 jam) diambil dari
/// cache tanpa memanggil jaringan; bila jaringan gagal, data lama dipakai
/// ([DataBmkg.dariCache], dipakai juga sebagai pembungkus di sini).
class KualitasUdaraRepository {
  KualitasUdaraRepository(this._api, this._cache, {DateTime Function()? jam})
    : _jam = jam ?? DateTime.now;

  final ApiService _api;
  final CacheService _cache;
  final DateTime Function() _jam;

  static const ttl = Duration(hours: 1);
  static const _awalan = 'udara.';

  /// Koordinat dibulatkan ke 0,1 derajat.
  static double bulatkan(double derajat) => (derajat * 10).round() / 10;

  /// Kunci cache untuk titik yang sudah dibulatkan.
  static String kunci(double lat, double lon) =>
      '$_awalan${bulatkan(lat).toStringAsFixed(1)}.'
      '${bulatkan(lon).toStringAsFixed(1)}';

  Future<DataBmkg<KualitasUdara>> ambil(double lat, double lon) async {
    final la = bulatkan(lat);
    final lo = bulatkan(lon);
    final k = kunci(lat, lon);

    final lama = await _cache.baca(k);
    KualitasUdara? dariLama;
    if (lama != null) {
      try {
        dariLama = KualitasUdara.fromJson(lama.json);
      } on FormatException {
        dariLama = null; // Cache rusak: abaikan.
      }
    }
    if (dariLama != null && _jam().difference(lama!.diambil) < ttl) {
      return DataBmkg(dariLama, diperbarui: lama.diambil, dariCache: false);
    }
    try {
      final json = await _api.ambilJson(
        ApiConstants.openMeteoUdaraUrl,
        queryParameters: {
          'latitude': la,
          'longitude': lo,
          'current': ApiConstants.openMeteoUdaraParameter,
          'timezone': 'auto',
        },
      );
      final KualitasUdara data;
      try {
        data = KualitasUdara.fromJson(json);
      } on FormatException catch (e) {
        throw ApiException.badFormat(e.message);
      }
      final sekarang = _jam();
      await _cache.simpan(k, json, diambil: sekarang);
      // Hanya titik aktif yang disimpan.
      await _cache.pangkasAwalan(_awalan, {k.substring(_awalan.length)});
      return DataBmkg(data, diperbarui: sekarang, dariCache: false);
    } on ApiException {
      if (dariLama == null) rethrow;
      return DataBmkg(dariLama, diperbarui: lama!.diambil, dariCache: true);
    }
  }
}
