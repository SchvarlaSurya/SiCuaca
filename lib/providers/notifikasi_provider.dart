import 'package:flutter/foundation.dart';

import '../models/ambang_gempa.dart';
import '../services/notifikasi_service.dart';
import '../services/preferences_service.dart';

enum PesanNotifikasi { belumAktif, izinDitolak, gagalLangganan }

/// Pengaturan ambang notifikasi gempa.
class NotifikasiProvider extends ChangeNotifier {
  NotifikasiProvider(this._service, this._prefs);

  final NotifikasiService _service;
  final PreferencesService _prefs;

  AmbangGempa _ambang = AmbangGempa.mati;
  bool _memproses = false;
  bool _izinDitolak = false;
  PesanNotifikasi? _pesan;

  AmbangGempa get ambang => _ambang;
  bool get memproses => _memproses;
  bool get tersedia => _service.siap;

  /// True bila pesan terakhir adalah penolakan izin (tampilkan tombol
  /// pengaturan).
  bool get izinDitolak => _izinDitolak;

  PesanNotifikasi? get pesan => _pesan;

  Future<void> muat() async {
    _ambang = await _prefs.ambangGempa();
    notifyListeners();
  }

  Future<void> pilih(AmbangGempa baru) async {
    if (_memproses || baru == _ambang) return;
    if (!tersedia) {
      _ubahPesan(PesanNotifikasi.belumAktif);
      return;
    }

    _memproses = true;
    _izinDitolak = false;
    _pesan = null;
    notifyListeners();

    try {
      if (baru != AmbangGempa.mati && !await _service.mintaIzin()) {
        _izinDitolak = true;
        _pesan = PesanNotifikasi.izinDitolak;
        return;
      }
      await _service.langganan(baru);
      _ambang = baru;
      await _prefs.simpanAmbangGempa(baru);
    } catch (_) {
      _pesan = PesanNotifikasi.gagalLangganan;
    } finally {
      _memproses = false;
      notifyListeners();
    }
  }

  Future<void> bukaPengaturan() => _service.bukaPengaturanAplikasi();

  void _ubahPesan(PesanNotifikasi pesan) {
    _pesan = pesan;
    notifyListeners();
  }
}
