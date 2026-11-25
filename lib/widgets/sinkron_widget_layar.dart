import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/pengaturan_provider.dart';
import '../providers/weather_provider.dart';
import '../services/widget_layar_service.dart';

/// Menjaga widget layar utama tetap sama dengan data cuaca di aplikasi:
/// setiap kali prakiraan baru dimuat (atau bahasa berganti), data
/// disimpan untuk widget dan widget digambar ulang. Tidak menampilkan
/// apa pun sendiri.
class SinkronWidgetLayar extends StatefulWidget {
  const SinkronWidgetLayar({super.key, required this.child});

  final Widget child;

  @override
  State<SinkronWidgetLayar> createState() => _SinkronWidgetLayarState();
}

class _SinkronWidgetLayarState extends State<SinkronWidgetLayar> {
  Object? _prakiraanTerakhir;
  PilihanBahasa? _bahasaTerakhir;

  static String _kodeBahasa(PilihanBahasa b) => switch (b) {
    PilihanBahasa.sistem => 'sistem',
    PilihanBahasa.indonesia => 'id',
    PilihanBahasa.inggris => 'en',
  };

  @override
  Widget build(BuildContext context) {
    final cuaca = context.watch<WeatherProvider>();
    final bahasa = context.watch<PengaturanProvider>().bahasa;
    final prakiraan = cuaca.prakiraan;
    if (prakiraan != null &&
        (!identical(prakiraan, _prakiraanTerakhir) ||
            bahasa != _bahasaTerakhir)) {
      _prakiraanTerakhir = prakiraan;
      _bahasaTerakhir = bahasa;
      final penyimpan = context.read<PenyimpanWidget>();
      final diperbarui = cuaca.diperbarui ?? DateTime.now();
      // Sesudah frame ini; penyimpanan dan pembaruan widget berjalan async.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetLayar.dorong(
          penyimpan,
          prakiraan: prakiraan,
          bahasa: _kodeBahasa(bahasa),
          diperbarui: diperbarui,
        );
      });
    }
    return widget.child;
  }
}
