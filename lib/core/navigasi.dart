import 'package:flutter/material.dart';

import '../models/gempa.dart';
import '../screens/gempa_detail_screen.dart';
import '../screens/peringatan_screen.dart';
import '../screens/siaga_gempa_screen.dart';

/// Urutan tab di navigasi bawah.
abstract final class TabUtama {
  static const int beranda = 0;
  static const int cuaca = 1;
  static const int gempa = 2;
  static const int pengaturan = 3;
}

/// Titik navigasi terpusat. Dipakai juga dari luar pohon widget (ketukan
/// notifikasi), karena itu memakai navigator key global.
class Navigasi {
  const Navigasi._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Tab aktif di navigasi bawah. Diubah oleh tautan "Selengkapnya".
  static final ValueNotifier<int> tabAktif = ValueNotifier<int>(
    TabUtama.beranda,
  );

  /// Pindah ke tab [indeks] (lihat [TabUtama]).
  static void bukaTab(int indeks) => tabAktif.value = indeks;

  /// Membuka pengaturan notifikasi gempa (dulu tab sendiri, sekarang
  /// dibuka dari tab Gempa dan Beranda).
  static void bukaPeringatan() {
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => const PeringatanScreen()),
    );
  }

  /// Membuka layar Siap Siaga gempa (panduan, tas siaga, istilah).
  static void bukaSiaga() {
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => const SiagaGempaScreen()),
    );
  }

  /// Membuka halaman detail gempa. Mengembalikan false bila navigator belum
  /// siap (pemanggil boleh mencoba lagi nanti).
  static bool bukaDetailGempa(Gempa gempa) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return false;
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => GempaDetailScreen(gempa: gempa)),
    );
    return true;
  }
}
