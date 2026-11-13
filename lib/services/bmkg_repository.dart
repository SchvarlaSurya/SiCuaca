import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/gempa.dart';
import '../models/prakiraan.dart';
import 'api_service.dart';
import 'cache_service.dart';

/// Data beserta asal dan waktu pengambilannya.
class DataBmkg<T> {
  const DataBmkg(
    this.data, {
    required this.diperbarui,
    required this.dariCache,
  });

  final T data;

  /// Waktu data diambil dari BMKG (untuk label "Diperbarui").
  final DateTime diperbarui;

  /// True bila jaringan gagal dan data berasal dari cache.
  final bool dariCache;
}

/// Sumber data BMKG dengan cache offline: coba jaringan dulu; bila gagal,
/// pakai data terakhir yang tersimpan. Bila cache juga kosong, error
/// jaringan diteruskan apa adanya.
class BmkgRepository {
  BmkgRepository(this._api, this._cache);

  final ApiService _api;
  final CacheService _cache;

  /// Prakiraan untuk [adm4]. Cache prakiraan lain selain [dipertahankan]
  /// (biasanya wilayah aktif + favorit) dihapus agar ukurannya terbatas.
  Future<DataBmkg<Prakiraan>> prakiraan(
    String adm4, {
    Set<String> dipertahankan = const {},
  }) async {
    final hasil = await _ambil(
      CacheService.kunciPrakiraan(adm4),
      () => _api.ambilJson(
        ApiConstants.prakiraanCuacaUrl,
        queryParameters: {'adm4': adm4},
      ),
      Prakiraan.fromJson,
    );
    if (!hasil.dariCache) {
      await _cache.pangkasPrakiraan({...dipertahankan, adm4});
    }
    return hasil;
  }

  Future<DataBmkg<Gempa>> gempaTerbaru() => _ambil(
    CacheService.kunciGempaTerbaru,
    () => _api.ambilJson(ApiConstants.autoGempaUrl),
    Gempa.fromAutoGempaJson,
  );

  Future<DataBmkg<List<Gempa>>> gempaTerkini() => _ambil(
    CacheService.kunciGempaTerkini,
    () => _api.ambilJson(ApiConstants.gempaTerkiniUrl),
    Gempa.daftarDariJson,
  );

  Future<DataBmkg<List<Gempa>>> gempaDirasakan() => _ambil(
    CacheService.kunciGempaDirasakan,
    () => _api.ambilJson(ApiConstants.gempaDirasakanUrl),
    Gempa.daftarDariJson,
  );

  Future<DataBmkg<T>> _ambil<T>(
    String kunci,
    Future<Map<String, dynamic>> Function() jaringan,
    T Function(Map<String, dynamic>) urai,
  ) async {
    try {
      final json = await jaringan();
      final T data;
      try {
        data = urai(json);
      } on FormatException catch (e) {
        throw ApiException.badFormat(e.message);
      }
      final sekarang = DateTime.now();
      await _cache.simpan(kunci, json, diambil: sekarang);
      return DataBmkg(data, diperbarui: sekarang, dariCache: false);
    } on ApiException catch (galat) {
      final entri = await _cache.baca(kunci);
      if (entri == null) rethrow;
      try {
        return DataBmkg(
          urai(entri.json),
          diperbarui: entri.diambil,
          dariCache: true,
        );
      } on FormatException {
        // Cache rusak: perlakukan seperti tidak ada cache.
        throw galat;
      }
    }
  }
}
