import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../core/geo.dart';
import '../models/gempa.dart';
import '../services/bmkg_repository.dart';
import '../services/cache_service.dart';
import 'lokasi_provider.dart';

enum StatusMuat { loading, berhasil, error }

/// Keadaan satu sumber data gempa.
class KeadaanGempa<T> {
  const KeadaanGempa.loading()
    : status = StatusMuat.loading,
      data = null,
      galat = null,
      diperbarui = null,
      dariCache = false;

  KeadaanGempa.berhasil(DataBmkg<T> hasil)
    : status = StatusMuat.berhasil,
      data = hasil.data,
      galat = null,
      diperbarui = hasil.diperbarui,
      dariCache = hasil.dariCache;

  const KeadaanGempa.error(ApiException this.galat)
    : status = StatusMuat.error,
      data = null,
      diperbarui = null,
      dariCache = false;

  final StatusMuat status;
  final T? data;
  final ApiException? galat;
  final DateTime? diperbarui;
  final bool dariCache;
}

/// Data gempa BMKG: gempa terbaru, M 5.0+, dan dirasakan, plus jarak ke
/// posisi GPS pengguna (dari [LokasiProvider]).
class GempaProvider extends ChangeNotifier {
  GempaProvider(this._repo, this._lokasi, [CacheService? cache])
    : _cache = cache ?? CacheService() {
    _lokasi.addListener(_lokasiBerubah);
  }

  final BmkgRepository _repo;
  final LokasiProvider _lokasi;
  final CacheService _cache;

  KeadaanGempa<Gempa> _terbaru = const KeadaanGempa.loading();
  KeadaanGempa<List<Gempa>> _terkini = const KeadaanGempa.loading();
  KeadaanGempa<List<Gempa>> _dirasakan = const KeadaanGempa.loading();
  bool _dibuang = false;
  List<Gempa> _riwayat = const [];

  KeadaanGempa<Gempa> get terbaru => _terbaru;
  KeadaanGempa<List<Gempa>> get terkini => _terkini;
  KeadaanGempa<List<Gempa>> get dirasakan => _dirasakan;
  List<Gempa> get riwayat => _riwayat;

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
    _riwayat = await _cache.bacaRiwayatGempa();
    _beritahu();
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
    _terbaru = await _ambil(_repo.gempaTerbaru);
    _perbaruiRiwayat();
    _beritahu();
  }

  Future<void> muatTerkini() async {
    _terkini = const KeadaanGempa.loading();
    _beritahu();
    _terkini = await _ambil(_repo.gempaTerkini);
    _perbaruiRiwayat();
    _beritahu();
  }

  Future<void> muatDirasakan() async {
    _dirasakan = const KeadaanGempa.loading();
    _beritahu();
    _dirasakan = await _ambil(_repo.gempaDirasakan);
    _perbaruiRiwayat();
    _beritahu();
  }

  void _perbaruiRiwayat() {
    final gabungan = <Gempa>[
      ..._riwayat,
      if (_terbaru.data != null) _terbaru.data!,
      ...?_terkini.data,
      ...?_dirasakan.data,
    ];
    final unik = <String, Gempa>{
      for (final gempa in gabungan) gempa.kunci: gempa,
    };
    final hasil =
        unik.values.where((gempa) {
          final waktu = gempa.waktuUtc;
          return waktu == null ||
              DateTime.now().toUtc().difference(waktu).inDays <= 30;
        }).toList()..sort((a, b) {
          if (a.waktuUtc == null) return 1;
          if (b.waktuUtc == null) return -1;
          return b.waktuUtc!.compareTo(a.waktuUtc!);
        });
    _riwayat = hasil;
    _cache.simpanRiwayatGempa(hasil);
  }

  Future<KeadaanGempa<T>> _ambil<T>(
    Future<DataBmkg<T>> Function() ambil,
  ) async {
    try {
      return KeadaanGempa.berhasil(await ambil());
    } on ApiException catch (e) {
      return KeadaanGempa.error(e);
    } catch (_) {
      return KeadaanGempa.error(ApiException.unknown());
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
