import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/strings.dart';
import '../models/lokasi.dart';
import '../services/gps_service.dart';
import '../services/wilayah_service.dart';

enum StatusLokasi {
  idle,
  mencari,
  berhasil,
  layananMati,
  ditolak,
  ditolakPermanen,
  gagal,
  diluarWilayah,
}

/// Mengambil posisi GPS lalu memetakannya ke desa/kelurahan terdekat.
class LokasiProvider extends ChangeNotifier {
  LokasiProvider(this._gps, this._wilayah);

  final GpsService _gps;
  final WilayahService _wilayah;

  StatusLokasi _status = StatusLokasi.idle;
  StatusLokasi get status => _status;

  bool get sedangMencari => _status == StatusLokasi.mencari;

  /// Pesan untuk pengguna bila deteksi gagal; null bila tidak ada masalah.
  String? get pesan => switch (_status) {
    StatusLokasi.layananMati => Str.gpsLayananMati,
    StatusLokasi.ditolak => Str.gpsDitolak,
    StatusLokasi.ditolakPermanen => Str.gpsDitolakPermanen,
    StatusLokasi.gagal => Str.gpsGagal,
    StatusLokasi.diluarWilayah => Str.gpsDiluarWilayah,
    StatusLokasi.idle || StatusLokasi.mencari || StatusLokasi.berhasil => null,
  };

  /// Mengembalikan desa terdekat, atau null bila gagal (lihat [status]).
  Future<Lokasi?> deteksi() async {
    if (sedangMencari) return null;
    _ubah(StatusLokasi.mencari);

    final hasil = await _gps.ambilPosisi();
    final lat = hasil.lat;
    final lon = hasil.lon;
    if (hasil.status != StatusGps.berhasil || lat == null || lon == null) {
      _ubah(switch (hasil.status) {
        StatusGps.layananMati => StatusLokasi.layananMati,
        StatusGps.ditolak => StatusLokasi.ditolak,
        StatusGps.ditolakPermanen => StatusLokasi.ditolakPermanen,
        StatusGps.berhasil || StatusGps.gagal => StatusLokasi.gagal,
      });
      return null;
    }

    try {
      final indeks = await _wilayah.muat();
      final terdekat = indeks.terdekat(lat, lon);
      if (terdekat == null ||
          terdekat.jarakKm > WilayahConstants.radiusMaksimalKm) {
        _ubah(StatusLokasi.diluarWilayah);
        return null;
      }
      _ubah(StatusLokasi.berhasil);
      return terdekat.lokasi;
    } catch (_) {
      _ubah(StatusLokasi.gagal);
      return null;
    }
  }

  /// Hapus pesan kegagalan, mis. setelah pengguna memilih wilayah manual.
  void reset() {
    if (_status != StatusLokasi.idle && !sedangMencari) {
      _ubah(StatusLokasi.idle);
    }
  }

  Future<void> bukaPengaturan() {
    return _status == StatusLokasi.layananMati
        ? _gps.bukaPengaturanLokasi()
        : _gps.bukaPengaturanAplikasi();
  }

  void _ubah(StatusLokasi status) {
    _status = status;
    notifyListeners();
  }
}
