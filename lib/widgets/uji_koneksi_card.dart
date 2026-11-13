import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gempa.dart';
import '../providers/uji_koneksi_provider.dart';

/// Kartu yang membuktikan aplikasi bisa mengambil data asli dari BMKG.
class UjiKoneksiCard extends StatelessWidget {
  const UjiKoneksiCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UjiKoneksiProvider>();
    final theme = Theme.of(context);
    final sedangMemuat = provider.status == StatusKoneksi.loading;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_sync_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Uji Koneksi API',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Uji ulang',
                  onPressed: sedangMemuat ? null : provider.ujiKoneksi,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: switch (provider.status) {
                StatusKoneksi.loading => const _Memuat(),
                StatusKoneksi.berhasil => _Berhasil(gempa: provider.gempa!),
                StatusKoneksi.gagal => _Gagal(
                  pesan: provider.pesanError ?? '',
                  onCobaLagi: provider.ujiKoneksi,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Memuat extends StatelessWidget {
  const _Memuat();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 12),
          Text('Menghubungi server BMKG…'),
        ],
      ),
    );
  }
}

class _Berhasil extends StatelessWidget {
  const _Berhasil({required this.gempa});

  final Gempa gempa;

  static String _atauStrip(String teks) => teks.isEmpty ? '-' : teks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final waktu = [
      gempa.tanggal,
      gempa.jam,
    ].where((s) => s.isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 18, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              'Terhubung. Gempa terbaru:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _atauStrip(gempa.magnitudo),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Magnitudo',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _atauStrip(gempa.wilayah),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _atauStrip(waktu),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Gagal extends StatelessWidget {
  const _Gagal({required this.pesan, required this.onCobaLagi});

  final String pesan;
  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.wifi_off, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pesan,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onCobaLagi,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }
}
