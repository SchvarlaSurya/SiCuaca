import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../providers/lokasi_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/pencarian_screen.dart';
import 'tombol_kaca.dart';

/// Tombol AppBar: gunakan lokasi GPS dan cari wilayah, dalam satu grup kaca.
/// [sebelum] = tombol lain halaman itu (mis. bagikan) yang ikut satu grup.
class AksiWilayah extends StatelessWidget {
  const AksiWilayah({super.key, this.sebelum = const []});

  final List<Widget> sebelum;

  @override
  Widget build(BuildContext context) {
    final mencari = context.watch<LokasiProvider>().sedangMencari;
    return GrupTombolKaca(
      children: [
        ...sebelum,
        TombolKaca(
          tooltip: context.l10n.gunakanLokasiSaya,
          onPressed: mencari
              ? null
              : context.read<WeatherProvider>().pakaiLokasiGps,
          icon: mencari
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const IkonDuo(IkonApp.lokasiSaya),
        ),
        TombolKaca(
          tooltip: context.l10n.cariWilayah,
          onPressed: () => bukaPencarian(context),
          icon: const IkonDuo(IkonApp.cari),
        ),
      ],
    );
  }
}
