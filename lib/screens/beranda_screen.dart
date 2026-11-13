import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../widgets/uji_koneksi_card.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Beranda', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Prakiraan cuaca dan info gempa bumi Indonesia. '
            'Ringkasan lengkap segera hadir.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const UjiKoneksiCard(),
        ],
      ),
    );
  }
}
