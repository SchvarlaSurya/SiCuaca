import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Foto bulan NASA dan shader pencahayaannya, dimuat sekali dan dipakai
/// bersama. Sampai [siap] bernilai true (atau bila gagal dimuat, mis. di
/// perangkat tanpa dukungan shader), bulan digambar dengan bentuk prosedural
/// ([lukisBulan] punya jalur cadangan).
///
/// Sumber gambar: NASA Scientific Visualization Studio, CGI Moon Kit
/// (data Lunar Reconnaissance Orbiter), lihat assets/bulan/KREDIT-NASA.txt.
abstract final class AsetBulan {
  static final siap = ValueNotifier<bool>(false);
  static bool _gagal = false;
  static Future<void>? _proses;

  static ui.FragmentProgram? _program;
  static final _warna = <int, ui.Image>{};
  static final _peta = <int, ui.Image>{};

  static const _ukuranWarna = [256, 512, 1024];
  static const _ukuranPeta = [256, 512];

  /// Mulai memuat (sekali). Aman dipanggil berulang.
  static Future<void> muat() => _proses ??= _muat();

  static Future<void> _muat() async {
    try {
      _program = await ui.FragmentProgram.fromAsset('shaders/bulan.frag');
      for (final u in _ukuranWarna) {
        _warna[u] = await _gambar('assets/bulan/bulan_warna_$u.webp');
      }
      for (final u in _ukuranPeta) {
        _peta[u] = await _gambar('assets/bulan/bulan_relief_$u.webp');
      }
      siap.value = true;
    } catch (e) {
      _gagal = true;
      debugPrint('Foto bulan tidak dimuat, memakai gambar prosedural: $e');
    }
  }

  static Future<ui.Image> _gambar(String jalur) async {
    final data = await rootBundle.load(jalur);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  /// Apakah jalur foto + shader bisa dipakai sekarang.
  static bool get bisaDipakai => siap.value && !_gagal;

  /// Shader siap pakai untuk bulan berdiameter [diameterPiksel] (piksel
  /// perangkat) dan sudut fase [elongasi] (derajat). Memilih tekstur yang
  /// ukurannya paling dekat di atas diameter, supaya tidak berkilau saat
  /// diperkecil.
  static ui.FragmentShader? shader({
    required double diameterPiksel,
    required double ukuranLokal,
    required double elongasi,
  }) {
    if (!bisaDipakai) return null;
    int pilih(List<int> daftar) => daftar.firstWhere(
      (u) => u >= diameterPiksel,
      orElse: () => daftar.last,
    );
    final rad = elongasi * math.pi / 180;
    final s = _program!.fragmentShader()
      ..setFloat(0, ukuranLokal)
      ..setFloat(1, ukuranLokal)
      ..setFloat(2, math.sin(rad))
      ..setFloat(3, -math.cos(rad))
      ..setFloat(4, .16)
      ..setFloat(5, .06)
      ..setImageSampler(0, _warna[pilih(_ukuranWarna)]!)
      ..setImageSampler(1, _peta[pilih(_ukuranPeta)]!);
    return s;
  }
}
