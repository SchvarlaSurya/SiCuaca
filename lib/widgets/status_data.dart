import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/l10n.dart';

/// Widget status bersama untuk semua layar data: memuat, gagal, kosong,
/// dan banner offline.

class MemuatData extends StatelessWidget {
  const MemuatData({super.key, required this.pesan});

  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(pesan)),
        ],
      ),
    );
  }
}

class GagalMuat extends StatelessWidget {
  const GagalMuat({
    super.key,
    required this.pesan,
    required this.onCobaLagi,
    this.aksiTambahan,
    this.ikon = Icons.cloud_off,
  });

  final String pesan;
  final VoidCallback onCobaLagi;
  final Widget? aksiTambahan;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
              Icon(ikon, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pesan,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onCobaLagi,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.cobaLagi),
            ),
            ?aksiTambahan,
          ],
        ),
      ],
    );
  }
}

class KosongData extends StatelessWidget {
  const KosongData({super.key, required this.pesan, this.rataTengah = true});

  final String pesan;
  final bool rataTengah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        pesan,
        textAlign: rataTengah ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Banner kecil "Mode offline" + waktu data terakhir diperbarui.
class BannerOffline extends StatelessWidget {
  const BannerOffline({super.key, required this.diperbarui});

  final DateTime? diperbarui;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final waktu = diperbarui;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                l.modeOffline,
                if (waktu != null) l.diperbarui(Format.waktuSingkat(l, waktu)),
              ].join(' '),
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label kecil "Diperbarui: (waktu)".
class LabelDiperbarui extends StatelessWidget {
  const LabelDiperbarui({super.key, required this.waktu});

  final DateTime? waktu;

  @override
  Widget build(BuildContext context) {
    final w = waktu;
    if (w == null) return const SizedBox.shrink();
    final l = context.l10n;
    final theme = Theme.of(context);
    return Text(
      l.diperbarui(Format.waktuSingkat(l, w)),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
