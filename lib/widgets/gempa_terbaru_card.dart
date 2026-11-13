import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/navigasi.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import 'badge_magnitudo.dart';
import 'status_data.dart';
import 'sumber_bmkg.dart';

/// Kartu gempa terbaru (autogempa). Ketuk untuk membuka detail.
///
/// [utama] = true di tab Gempa → Terbaru: magnitudo jadi angka besar 64 sp.
/// Di Beranda bentuknya ringkas (badge), karena informasi utama Beranda
/// adalah suhu.
class GempaTerbaruCard extends StatelessWidget {
  const GempaTerbaruCard({super.key, this.utama = false});

  final bool utama;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    final keadaan = provider.terbaru;
    final gempa = keadaan.data;

    final isi = switch (keadaan.status) {
      StatusMuat.loading => MemuatData(
        pesan: context.l10n.memuatGempa,
        bentuk: utama ? BentukKerangka.kartu : BentukKerangka.baris,
      ),
      StatusMuat.error => GagalMuat(
        pesan: context.l10n.pesanGalat(keadaan.galat),
        onCobaLagi: provider.muatTerbaru,
      ),
      StatusMuat.berhasil when gempa != null => _Isi(
        gempa: gempa,
        jarak: provider.jarakKm(gempa),
        diperbarui: keadaan.diperbarui,
        utama: utama,
      ),
      StatusMuat.berhasil => KosongData(pesan: context.l10n.gempaKosong),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: utama
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusHero),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            )
          : null,
      child: InkWell(
        onTap: gempa == null ? null : () => Navigasi.bukaDetailGempa(gempa),
        child: Padding(padding: const EdgeInsets.all(16), child: isi),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  const _Isi({
    required this.gempa,
    required this.jarak,
    required this.diperbarui,
    required this.utama,
  });

  final Gempa gempa;
  final double? jarak;
  final DateTime? diperbarui;
  final bool utama;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final jarak = this.jarak;

    final keterangan = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gempa.wilayah.isEmpty ? Format.tandaKosong : gempa.wilayah,
          style: utama
              ? theme.textTheme.titleMedium
              : theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${Format.waktuRelatif(l, gempa.waktuUtc, DateTime.now())} · '
          '${Format.waktuLengkap(l, gempa.waktuUtc)}',
          style: redup,
        ),
        if (gempa.kedalaman.isNotEmpty)
          Text(l.kedalamanSingkat(gempa.kedalaman), style: redup),
        if (jarak != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(IkonApp.jarak, size: 16, color: scheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l.jarakKm(Format.jarak(l, jarak)),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (utama) ...[
          MagnitudoBesar(
            magnitudo: gempa.magnitudoAngka,
            teks: gempa.magnitudo,
          ),
          const SizedBox(height: 8),
          keterangan,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BadgeMagnitudo(
                magnitudo: gempa.magnitudoAngka,
                teks: gempa.magnitudo,
              ),
              const SizedBox(width: 12),
              Expanded(child: keterangan),
              Icon(IkonApp.selengkapnya, color: scheme.onSurfaceVariant),
            ],
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: LabelDiperbarui(waktu: diperbarui)),
            const SumberBmkg(),
          ],
        ),
      ],
    );
  }
}
