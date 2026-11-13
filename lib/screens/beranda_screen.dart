import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../widgets/aksi_wilayah.dart';
import '../widgets/cuaca_saat_ini_card.dart';
import '../widgets/lokasi_banner.dart';
import '../widgets/uji_koneksi_card.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Str.appName),
        actions: const [AksiWilayah()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(Str.berandaJudul, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            Str.berandaKeterangan,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const LokasiBanner(),
          const CuacaSaatIniCard(),
          const SizedBox(height: 16),
          const UjiKoneksiCard(),
        ],
      ),
    );
  }
}
