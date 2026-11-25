import 'package:flutter/foundation.dart';

import '../models/kualitas_udara.dart';
import '../services/bmkg_repository.dart';
import '../services/kualitas_udara_repository.dart';

enum StatusUdara { awal, memuat, berhasil, gagal }

/// Kualitas udara untuk satu titik (wilayah yang sedang dilihat). Tidak
/// memuat apa pun sampai kartunya tampil ([muat]), supaya aplikasi tidak
/// memanggil layanan luar tanpa perlu.
class KualitasUdaraProvider extends ChangeNotifier {
  KualitasUdaraProvider(this._repo);

  final KualitasUdaraRepository _repo;

  StatusUdara _status = StatusUdara.awal;
  DataBmkg<KualitasUdara>? _data;
  Object? _galat;
  String? _kunciTitik;
  int _urutan = 0;

  StatusUdara get status => _status;
  DataBmkg<KualitasUdara>? get data => _data;
  Object? get galat => _galat;

  /// Muat untuk (lat, lon). Titik yang sama (setelah pembulatan) dan sudah
  /// berhasil dimuat tidak dimuat ulang kecuali [paksa].
  Future<void> muat(double lat, double lon, {bool paksa = false}) async {
    final kunci = KualitasUdaraRepository.kunci(lat, lon);
    if (!paksa &&
        kunci == _kunciTitik &&
        (_status == StatusUdara.memuat || _status == StatusUdara.berhasil)) {
      return;
    }
    final ini = ++_urutan;
    _kunciTitik = kunci;
    _status = StatusUdara.memuat;
    _galat = null;
    notifyListeners();
    try {
      final hasil = await _repo.ambil(lat, lon);
      if (ini != _urutan) return;
      _data = hasil;
      _status = StatusUdara.berhasil;
    } catch (e) {
      if (ini != _urutan) return;
      _galat = e;
      _data = null;
      _status = StatusUdara.gagal;
    }
    notifyListeners();
  }
}
