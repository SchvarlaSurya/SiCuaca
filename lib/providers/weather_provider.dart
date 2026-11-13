import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../services/bmkg_repository.dart';
import '../services/preferences_service.dart';
import 'lokasi_provider.dart';

enum StatusCuaca { belumAdaWilayah, loading, berhasil, error }

/// State prakiraan cuaca untuk wilayah aktif.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider(this._repo, this._prefs, this._lokasi);

  final BmkgRepository _repo;
  final PreferencesService _prefs;
  final LokasiProvider _lokasi;

  StatusCuaca _status = StatusCuaca.loading;
  Lokasi? _wilayah;
  Prakiraan? _prakiraan;
  ApiException? _galat;
  DateTime? _diperbarui;
  bool _dariCache = false;

  /// Naik setiap permintaan baru, agar respons lama yang datang terlambat
  /// tidak menimpa wilayah yang baru dipilih.
  int _permintaan = 0;

  StatusCuaca get status => _status;
  Lokasi? get wilayah => _wilayah;
  Prakiraan? get prakiraan => _prakiraan;

  /// Error terakhir (untuk dipetakan ke teks oleh widget).
  ApiException? get galat => _galat;

  /// Waktu data prakiraan diambil dari BMKG.
  DateTime? get diperbarui => _diperbarui;

  /// True bila jaringan gagal dan prakiraan berasal dari cache.
  bool get dariCache => _dariCache;

  /// Dipanggil sekali saat aplikasi dibuka: pulihkan wilayah terakhir, atau
  /// coba GPS bila belum pernah memilih wilayah.
  Future<void> mulai() async {
    final terakhir = await _prefs.wilayahTerakhir();
    if (terakhir != null) {
      await pilihWilayah(terakhir);
    } else {
      _status = StatusCuaca.belumAdaWilayah;
      notifyListeners();
      await pakaiLokasiGps();
    }
  }

  Future<void> pakaiLokasiGps() async {
    final lokasi = await _lokasi.deteksi();
    if (lokasi != null) await pilihWilayah(lokasi);
  }

  Future<void> pilihWilayah(Lokasi lokasi) async {
    _wilayah = lokasi;
    _lokasi.reset();
    await _prefs.simpanWilayahTerakhir(lokasi);
    await _muat();
  }

  Future<void> muatUlang() async {
    if (_wilayah != null) await _muat();
  }

  Future<void> _muat() async {
    final wilayah = _wilayah;
    if (wilayah == null) return;
    final ke = ++_permintaan;

    _status = StatusCuaca.loading;
    _galat = null;
    notifyListeners();

    try {
      // Cache prakiraan hanya disimpan untuk wilayah aktif + favorit.
      final favorit = await _prefs.favorit();
      final hasil = await _repo.prakiraan(
        wilayah.adm4,
        dipertahankan: {for (final f in favorit) f.adm4},
      );
      if (ke != _permintaan) return;
      _prakiraan = hasil.data;
      _diperbarui = hasil.diperbarui;
      _dariCache = hasil.dariCache;
      _status = StatusCuaca.berhasil;
    } on ApiException catch (e) {
      if (ke != _permintaan) return;
      _galat = e;
      _status = StatusCuaca.error;
    } catch (_) {
      if (ke != _permintaan) return;
      _galat = ApiException.unknown();
      _status = StatusCuaca.error;
    }
    notifyListeners();
  }
}
