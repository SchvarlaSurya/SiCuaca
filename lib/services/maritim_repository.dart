import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../core/geo.dart';
import '../core/perairan_terdekat.dart';
import '../models/maritim.dart';
import 'api_service.dart';
import 'bmkg_repository.dart';
import 'cache_service.dart';

/// Data maritim BMKG dengan cache ber-TTL.
///
/// BMKG memperbarui data maritim sekitar 00 UTC dan menganggap akses
/// berulang otomatis dalam jumlah besar sebagai anomali, jadi data yang
/// masih segar diambil dari cache tanpa memanggil jaringan:
///
/// * prakiraan perairan: 3 jam;
/// * daftar perairan: 7 hari;
/// * perairan terdekat dari lokasi: 30 hari dan selama lokasi bergeser
///   kurang dari [_geserUlangKm] (GeoJSON 1,6 MB hanya diunduh saat perlu).
///
/// Bila jaringan gagal, data lama dipakai apa adanya ([DataBmkg.dariCache]).
class MaritimRepository {
  MaritimRepository(this._api, this._cache, {DateTime Function()? jam})
    : _jam = jam ?? DateTime.now;

  final ApiService _api;
  final CacheService _cache;
  final DateTime Function() _jam;

  static const ttlPrakiraan = Duration(hours: 3);
  static const ttlDaftar = Duration(days: 7);
  static const ttlTerdekat = Duration(days: 30);
  static const _geserUlangKm = 10.0;

  static const _awalanPerairan = 'maritim.perairan.';
  static const _kunciDaftar = 'maritim.daftar';
  static const _kunciTerdekat = 'maritim.terdekat';

  Future<DataBmkg<PrakiraanMaritim>> prakiraan(String kode) async {
    final hasil = await _denganTtl(
      '$_awalanPerairan$kode',
      ttlPrakiraan,
      () => _api.ambilJson(ApiConstants.maritimPerairanUrl(kode)),
      PrakiraanMaritim.fromJson,
    );
    // Hanya perairan aktif yang disimpan.
    await _cache.pangkasAwalan(_awalanPerairan, {kode});
    return hasil;
  }

  Future<DataBmkg<List<AreaPerairan>>> daftarPerairan() => _denganTtl(
    _kunciDaftar,
    ttlDaftar,
    () => _api.ambilJson(ApiConstants.maritimAreaUrl),
    AreaPerairan.daftarDariJson,
  );

  /// Perairan terdekat dari (lat, lon). Null bila data poligon tidak
  /// terbaca. Galat jaringan diteruskan bila belum ada hasil tersimpan.
  Future<PerairanTerdekat?> terdekat(double lat, double lon) async {
    final lama = await _cache.baca(_kunciTerdekat);
    final tersimpan = lama == null ? null : _bacaTerdekat(lama.json);
    final masihSegar =
        lama != null && _jam().difference(lama.diambil) < ttlTerdekat;
    if (tersimpan != null &&
        masihSegar &&
        jarakKmAntara(lat, lon, tersimpan.lat, tersimpan.lon) < _geserUlangKm) {
      return tersimpan.hasil;
    }
    try {
      final geojson = await _api.ambilJson(ApiConstants.maritimWilayahUrl);
      final arg = (geojson: geojson, lat: lat, lon: lon);
      final fitur = geojson['features'];
      // Data asli (379 poligon) dihitung di isolate agar UI tetap lancar;
      // data kecil (mis. uji) langsung saja.
      final hasil = fitur is List && fitur.length > 50
          ? await compute(cariPerairanTerdekatDariArgumen, arg)
          : cariPerairanTerdekatDariArgumen(arg);
      if (hasil != null) {
        await _cache.simpan(_kunciTerdekat, {
          'lat': lat,
          'lon': lon,
          'id': hasil.id,
          'nama': hasil.nama,
          'jarakKm': hasil.jarakKm,
        }, diambil: _jam());
      }
      return hasil;
    } on ApiException {
      // Luring: pakai hasil lama walau lokasi sedikit bergeser.
      if (tersimpan != null) return tersimpan.hasil;
      rethrow;
    }
  }

  static ({double lat, double lon, PerairanTerdekat hasil})? _bacaTerdekat(
    Map<String, dynamic> j,
  ) {
    final lat = j['lat'];
    final lon = j['lon'];
    final id = j['id'];
    final jarak = j['jarakKm'];
    if (lat is! num || lon is! num || id is! String || jarak is! num) {
      return null;
    }
    return (
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      hasil: (id: id, nama: '${j['nama'] ?? id}', jarakKm: jarak.toDouble()),
    );
  }

  Future<DataBmkg<T>> _denganTtl<T>(
    String kunci,
    Duration ttl,
    Future<Map<String, dynamic>> Function() jaringan,
    T Function(Map<String, dynamic>) urai,
  ) async {
    final lama = await _cache.baca(kunci);
    T? dariLama;
    if (lama != null) {
      try {
        dariLama = urai(lama.json);
      } on FormatException {
        dariLama = null; // Cache rusak: abaikan.
      }
    }
    // Masih segar: tidak perlu memanggil BMKG.
    if (dariLama != null && _jam().difference(lama!.diambil) < ttl) {
      return DataBmkg(dariLama, diperbarui: lama.diambil, dariCache: false);
    }
    try {
      final json = await jaringan();
      final T data;
      try {
        data = urai(json);
      } on FormatException catch (e) {
        throw ApiException.badFormat(e.message);
      }
      final sekarang = _jam();
      await _cache.simpan(kunci, json, diambil: sekarang);
      return DataBmkg(data, diperbarui: sekarang, dariCache: false);
    } on ApiException {
      if (dariLama == null) rethrow;
      return DataBmkg(dariLama, diperbarui: lama!.diambil, dariCache: true);
    }
  }
}
