import 'package:flutter/material.dart';

import '../core/constants.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppConstants.appName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Aplikasi prakiraan cuaca dan info gempa bumi Indonesia.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: scheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan '
                      'Geofisika). SiCuaca bukan aplikasi resmi BMKG.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
