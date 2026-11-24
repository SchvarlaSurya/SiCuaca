import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
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
        _AksiBulat(
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
        _AksiBulat(
          tooltip: context.l10n.cariWilayah,
          onPressed: () => bukaPencarian(context),
          icon: const IkonDuo(IkonApp.cari),
        ),
      ],
    );
  }
}

class _AksiBulat extends StatelessWidget {
  const _AksiBulat({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });
  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const CircleBorder(),
      child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: icon),
    ),
  );
}
