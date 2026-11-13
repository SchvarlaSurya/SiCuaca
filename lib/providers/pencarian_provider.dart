import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/lokasi.dart';
import '../services/wilayah_service.dart';

enum StatusDataWilayah { memuat, siap, gagal }

/// Pencarian wilayah di dataset lokal. Dibuat per layar pencarian.
class PencarianProvider extends ChangeNotifier {
  PencarianProvider(this._wilayah) {
    _siapkan();
  }

  static const Duration _jeda = Duration(milliseconds: 200);

  final WilayahService _wilayah;
  IndeksWilayah? _indeks;
  Timer? _timer;
  bool _dibuang = false;

  StatusDataWilayah _status = StatusDataWilayah.memuat;
  String _query = '';
  List<Lokasi> _hasil = const [];

  StatusDataWilayah get status => _status;
  String get query => _query;
  List<Lokasi> get hasil => _hasil;

  Future<void> _siapkan() async {
    try {
      _indeks = await _wilayah.muat();
      _status = StatusDataWilayah.siap;
      _jalankan();
    } catch (_) {
      _status = StatusDataWilayah.gagal;
    }
    if (!_dibuang) notifyListeners();
  }

  void ubahQuery(String query) {
    _query = query;
    _timer?.cancel();
    _timer = Timer(_jeda, () {
      _jalankan();
      if (!_dibuang) notifyListeners();
    });
  }

  void _jalankan() {
    final indeks = _indeks;
    _hasil = indeks == null ? const [] : indeks.cari(_query);
  }

  @override
  void dispose() {
    _dibuang = true;
    _timer?.cancel();
    super.dispose();
  }
}
