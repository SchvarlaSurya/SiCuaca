import 'package:flutter/material.dart';

import '../core/strings.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(Str.navTentang)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(Str.appName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            Str.tentangKeterangan,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: scheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(child: Text(Str.tentangSumber)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.map_outlined, color: scheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(child: Text(Str.tentangDataWilayah)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: const Text(Str.lisensiSumberTerbuka),
            onTap: () =>
                showLicensePage(context: context, applicationName: Str.appName),
          ),
        ],
      ),
    );
  }
}
