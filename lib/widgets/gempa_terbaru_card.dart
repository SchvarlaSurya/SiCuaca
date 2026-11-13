import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/navigasi.dart';
import '../core/strings.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import 'badge_magnitudo.dart';
import 'status_gempa.dart';
import 'sumber_bmkg.dart';

/// Kartu ringkasan gempa terbaru (autogempa). Dipakai di Beranda dan tab
/// Gempa → Terbaru. Ketuk untuk membuka detail.
class GempaTerbaruCard extends StatelessWidget {
  const GempaTerbaruCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    final keadaan = provider.terbaru;
    final gempa = keadaan.data;
    final theme = Theme.of(context);

    final isi = switch (keadaan.status) {
      StatusMuat.loading => const MemuatGempa(),
      StatusMuat.error => GagalGempa(
        pesan: keadaan.pesan ?? Str.errTakTerduga,
        onCobaLagi: provider.muatTerbaru,
      ),
      StatusMuat.berhasil when gempa != null => _Isi(
        gempa: gempa,
        jarak: provider.jarakKm(gempa),
      ),
      StatusMuat.berhasil => const KosongGempa(),
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: gempa == null ? null : () => Navigasi.bukaDetailGempa(gempa),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.waves, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Str.gempaTerbaruJudul,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (gempa != null)
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              isi,
            ],
          ),
        ),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  const _Isi({required this.gempa, required this.jarak});

  final Gempa gempa;
  final double? jarak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final jarak = this.jarak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BadgeMagnitudo(
              magnitudo: gempa.magnitudoAngka,
              teks: gempa.magnitudo,
              besar: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gempa.wilayah.isEmpty ? Str.tandaKosong : gempa.wilayah,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Format.waktuRelatif(gempa.waktuUtc, DateTime.now())} · '
                    '${Format.waktuLengkap(gempa.waktuUtc)}',
                    style: redup,
                  ),
                  if (gempa.kedalaman.isNotEmpty)
                    Text(Str.kedalamanSingkat(gempa.kedalaman), style: redup),
                  if (jarak != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      Str.jarakKm(Format.jarak(jarak)),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Align(alignment: Alignment.centerRight, child: SumberBmkg()),
      ],
    );
  }
}
