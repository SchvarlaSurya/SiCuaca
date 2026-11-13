import 'package:flutter/material.dart';

import '../models/gempa.dart';
import '../screens/gempa_detail_screen.dart';

/// Titik navigasi terpusat. Dipakai juga dari luar pohon widget (ketukan
/// notifikasi), karena itu memakai navigator key global.
class Navigasi {
  const Navigasi._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
