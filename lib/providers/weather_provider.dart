import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import 'lokasi_provider.dart';

enum StatusCuaca { belumAdaWilayah, loading, berhasil, error }

/// State prakiraan cuaca untuk wilayah aktif.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider(this._api, this._prefs, this._lokasi);

  final ApiService _api;
  final PreferencesService _prefs;
  final LokasiProvider _lokasi;

  StatusCuaca _status = StatusCuaca.loading;
  Lokasi? _wilayah;
  Prakiraan? _prakiraan;
  String? _pesanError;

  /// Naik setiap permintaan baru, agar respons lama yang datang terlambat
  /// tidak menimpa wilayah yang baru dipilih.
  int _permintaan = 0;

  StatusCuaca get status => _status;
  Lokasi? get wilayah => _wilayah;
  Prakiraan? get prakiraan => _prakiraan;
  String? get pesanError => _pesanError;

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
    _pesanError = null;
    notifyListeners();

    try {
      final hasil = await _api.fetchPrakiraanCuaca(wilayah.adm4);
      if (ke != _permintaan) return;
      _prakiraan = hasil;
      _status = StatusCuaca.berhasil;
    } on ApiException catch (e) {
      if (ke != _permintaan) return;
      _pesanError = e.message;
      _status = StatusCuaca.error;
    } catch (_) {
      if (ke != _permintaan) return;
      _pesanError = ApiException.unknown().message;
      _status = StatusCuaca.error;
    }
    notifyListeners();
  }
}
