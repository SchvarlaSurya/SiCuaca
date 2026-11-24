import 'package:flutter/foundation.dart';

import '../core/panduan_siaga.dart';
import '../services/preferences_service.dart';

/// Checklist tas siaga bencana, tersimpan di perangkat (tanpa jaringan).
///
/// Centang disimpan dengan id butir yang stabil, bukan nomor urut, supaya
/// tetap benar bila daftar butir berubah.
class SiagaProvider extends ChangeNotifier {
  SiagaProvider(this._prefs);

  static const String kunci = 'checklist_tas_siaga_v2';

  /// Kunci versi lama (nomor urut dari 8 butir). Dipindahkan satu kali.
  static const String kunciLama = 'checklist_tas_siaga';

  /// Nomor urut lama menjadi id butir daftar BNPB yang sepadan.
  static const Map<int, String> petaLama = {
    0: 'air', // Air minum
    1: 'makanan', // Makanan tahan lama
    2: 'penerangan', // Senter dan baterai
    3: 'p3k', // Kotak P3K dan obat pribadi
    4: 'dokumen', // Dokumen penting
    5: 'peluit', // Peluit
    6: 'masker', // Masker
    7: 'radio', // Power bank
  };

  final PreferencesService _prefs;
  Set<String> _selesai = {};
  bool _dibuang = false;

  /// Id butir yang sudah dicentang (hanya butir yang masih ada di daftar).
  Set<String> get selesai => _selesai;

  int get jumlahSelesai => idTasSiaga.where(_selesai.contains).length;
  int get total => idTasSiaga.length;
  double get progres => total == 0 ? 0 : jumlahSelesai / total;

  bool sudah(String id) => _selesai.contains(id);

  Future<void> muat() async {
    var tersimpan = await _prefs.bacaDaftar(kunci);
    if (tersimpan == null) {
      final lama = await _prefs.bacaDaftar(kunciLama);
      if (lama != null) {
        tersimpan = [for (final s in lama) ?petaLama[int.tryParse(s)]];
        await _prefs.simpanDaftar(kunci, tersimpan);
        await _prefs.hapusKunci(kunciLama);
      }
    }
    _selesai = {...?tersimpan}..retainAll(idTasSiaga);
    _beritahu();
  }

  Future<void> toggle(String id) async {
    if (!idTasSiaga.contains(id)) return;
    final baru = {..._selesai};
    if (!baru.remove(id)) baru.add(id);
    _selesai = baru;
    _beritahu();
    await _prefs.simpanDaftar(kunci, baru.toList());
  }

  Future<void> setelUlang() async {
    _selesai = {};
    _beritahu();
    await _prefs.hapusKunci(kunci);
  }

  void _beritahu() {
    if (!_dibuang) notifyListeners();
  }

  @override
  void dispose() {
    _dibuang = true;
    super.dispose();
  }
}
