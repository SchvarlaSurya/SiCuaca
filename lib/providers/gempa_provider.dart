import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../core/geo.dart';
import '../models/gempa.dart';
import '../services/api_service.dart';
import 'lokasi_provider.dart';

enum StatusMuat { loading, berhasil, error }

/// Keadaan satu sumber data gempa.
class KeadaanGempa<T> {
  const KeadaanGempa.loading()
    : status = StatusMuat.loading,
      data = null,
      pesan = null;
  const KeadaanGempa.berhasil(T this.data)
    : status = StatusMuat.berhasil,
      pesan = null;
  const KeadaanGempa.error(String this.pesan)
    : status = StatusMuat.error,
      data = null;

  final StatusMuat status;
  final T? data;
  final String? pesan;
}

/// Data gempa BMKG: gempa terbaru, M 5.0+, dan dirasakan, plus jarak ke
/// posisi GPS pengguna (dari [LokasiProvider]).
class GempaProvider extends ChangeNotifier {
  GempaProvider(this._api, this._lokasi) {
    _lokasi.addListener(_lokasiBerubah);
  }

  final ApiService _api;
  final LokasiProvider _lokasi;

  KeadaanGempa<Gempa> _terbaru = const KeadaanGempa.loading();
  KeadaanGempa<List<Gempa>> _terkini = const KeadaanGempa.loading();
  KeadaanGempa<List<Gempa>> _dirasakan = const KeadaanGempa.loading();
  bool _dibuang = false;

  KeadaanGempa<Gempa> get terbaru => _terbaru;
  KeadaanGempa<List<Gempa>> get terkini => _terkini;
  KeadaanGempa<List<Gempa>> get dirasakan => _dirasakan;

  /// True bila jarak bisa dihitung (posisi GPS tersedia).
  bool get adaPosisi => _lokasi.posisi != null;

  /// Jarak pusat gempa ke posisi pengguna, km; null bila salah satu
  /// koordinat tidak tersedia.
  double? jarakKm(Gempa gempa) {
    final posisi = _lokasi.posisi;
    final lat = gempa.lat;
    final lon = gempa.lon;
    if (posisi == null || lat == null || lon == null) return null;
    return jarakKmAntara(posisi.lat, posisi.lon, lat, lon);
  }

  /// Dipanggil sekali saat aplikasi dibuka.
  Future<void> mulai() async {
    if (!adaPosisi) {
      // Tanpa dialog: hanya terisi bila izin lokasi sudah pernah diberikan.
      _lokasi.segarkanPosisi();
    }
    await muatSemua();
  }

  Future<void> muatSemua() =>
      Future.wait([muatTerbaru(), muatTerkini(), muatDirasakan()]);

  Future<void> muatTerbaru() async {
    _terbaru = const KeadaanGempa.loading();
    _beritahu();
    _terbaru = await _ambil(_api.fetchAutoGempa);
    _beritahu();
  }

  Future<void> muatTerkini() async {
    _terkini = const KeadaanGempa.loading();
    _beritahu();
    _terkini = await _ambil(_api.fetchGempaTerkini);
    _beritahu();
  }

  Future<void> muatDirasakan() async {
    _dirasakan = const KeadaanGempa.loading();
    _beritahu();
    _dirasakan = await _ambil(_api.fetchGempaDirasakan);
    _beritahu();
  }

  Future<KeadaanGempa<T>> _ambil<T>(Future<T> Function() ambil) async {
    try {
      return KeadaanGempa.berhasil(await ambil());
    } on ApiException catch (e) {
      return KeadaanGempa.error(e.message);
    } catch (_) {
      return KeadaanGempa.error(ApiException.unknown().message);
    }
  }

  void _lokasiBerubah() => _beritahu();

  void _beritahu() {
    if (!_dibuang) notifyListeners();
  }

  @override
  void dispose() {
    _dibuang = true;
    _lokasi.removeListener(_lokasiBerubah);
    super.dispose();
  }
}
