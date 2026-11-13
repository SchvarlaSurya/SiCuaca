import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../providers/lokasi_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/pencarian_screen.dart';

/// Tombol AppBar: gunakan lokasi GPS dan cari wilayah.
class AksiWilayah extends StatelessWidget {
  const AksiWilayah({super.key});

  @override
  Widget build(BuildContext context) {
    final mencari = context.watch<LokasiProvider>().sedangMencari;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.l10n.gunakanLokasiSaya,
          onPressed: mencari
              ? null
              : context.read<WeatherProvider>().pakaiLokasiGps,
          icon: mencari
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
        ),
        IconButton(
          tooltip: context.l10n.cariWilayah,
          onPressed: () => bukaPencarian(context),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}
