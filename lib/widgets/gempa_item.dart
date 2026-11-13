import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/strings.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../screens/gempa_detail_screen.dart';
import 'badge_magnitudo.dart';

/// Satu baris gempa di daftar. Diketuk membuka halaman detail.
class GempaItem extends StatelessWidget {
  const GempaItem({super.key, required this.gempa});

  final Gempa gempa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final jarak = context.watch<GempaProvider>().jarakKm(gempa);
    final keterangan = gempa.potensi.isNotEmpty
        ? gempa.potensi
        : gempa.dirasakan;
    final ikonKeterangan = gempa.potensi.isNotEmpty
        ? Icons.waves
        : Icons.groups_outlined;

    return InkWell(
      onTap: () => bukaDetailGempa(context, gempa),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BadgeMagnitudo(
              magnitudo: gempa.magnitudoAngka,
              teks: gempa.magnitudo,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gempa.wilayah.isEmpty ? Str.tandaKosong : gempa.wilayah,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      Format.waktuRelatif(gempa.waktuUtc, DateTime.now()),
                      if (gempa.kedalaman.isNotEmpty)
                        Str.kedalamanSingkat(gempa.kedalaman),
                    ].join(' · '),
                    style: redup,
                  ),
                  if (keterangan.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(ikonKeterangan, size: 14, color: redup?.color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            keterangan,
                            style: redup,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (jarak != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Str.jarakKm(Format.jarak(jarak)),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
