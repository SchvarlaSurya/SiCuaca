import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../models/gempa.dart';
import '../services/api_service.dart';

enum StatusKoneksi { loading, berhasil, gagal }

/// Menguji koneksi ke BMKG dengan mengambil gempa terbaru.
class UjiKoneksiProvider extends ChangeNotifier {
  UjiKoneksiProvider(this._apiService);

  final ApiService _apiService;

  StatusKoneksi _status = StatusKoneksi.loading;
  Gempa? _gempa;
  String? _pesanError;

  StatusKoneksi get status => _status;
  Gempa? get gempa => _gempa;
  String? get pesanError => _pesanError;

  Future<void> ujiKoneksi() async {
    _status = StatusKoneksi.loading;
    _pesanError = null;
    notifyListeners();

    try {
      _gempa = await _apiService.fetchAutoGempa();
      _status = StatusKoneksi.berhasil;
    } on ApiException catch (e) {
      _pesanError = e.message;
      _status = StatusKoneksi.gagal;
    } catch (_) {
      _pesanError = ApiException.unknown().message;
      _status = StatusKoneksi.gagal;
    }
    notifyListeners();
  }
}
