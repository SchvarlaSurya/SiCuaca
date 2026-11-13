import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/l10n.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../widgets/ajak_lokasi.dart';
import '../widgets/badge_magnitudo.dart';
import '../widgets/sumber_bmkg.dart';

/// Halaman detail gempa. Dibuka lewat [Navigasi.bukaDetailGempa] (dari
/// daftar, kartu Beranda, maupun ketukan notifikasi). Semua isi dibangun
/// dari objek [Gempa] yang diberikan, tanpa memanggil API, sehingga tetap
/// tampil walau internet mati.
class GempaDetailScreen extends StatelessWidget {
  const GempaDetailScreen({super.key, required this.gempa});

  final Gempa gempa;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final jarak = context.watch<GempaProvider>().jarakKm(gempa);
    final lat = gempa.lat;
    final lon = gempa.lon;
    final teksKoordinat = [
      if (lat != null && lon != null) Format.koordinat(lat, lon),
      if (gempa.lintang.isNotEmpty || gempa.bujur.isNotEmpty)
        '(${[gempa.lintang, gempa.bujur].where((s) => s.isNotEmpty).join(', ')})',
    ].join(' ');

    return Scaffold(
      appBar: AppBar(title: Text(l.gempaDetailJudul)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BadgeMagnitudo(
                magnitudo: gempa.magnitudoAngka,
                teks: gempa.magnitudo,
                besar: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gempa.wilayah.isEmpty
                          ? Format.tandaKosong
                          : gempa.wilayah,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Format.waktuRelatif(l, gempa.waktuUtc, DateTime.now()),
                      style: redup,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Shakemap(url: gempa.shakemapUrl),
          const SizedBox(height: 16),
          _Baris(
            ikon: Icons.schedule,
            label: context.l10n.waktuKejadian,
            nilai: Format.waktuLengkap(l, gempa.waktuUtc),
          ),
          _Baris(
            ikon: Icons.place_outlined,
            label: context.l10n.pusatGempa,
            nilai: gempa.wilayah,
          ),
          _Baris(
            ikon: Icons.speed,
            label: context.l10n.magnitudo,
            nilai: gempa.magnitudo,
          ),
          _Baris(
            ikon: Icons.vertical_align_bottom,
            label: context.l10n.kedalaman,
            nilai: gempa.kedalaman,
          ),
          _Baris(
            ikon: Icons.my_location,
            label: context.l10n.koordinat,
            nilai: teksKoordinat,
          ),
          if (gempa.potensi.isNotEmpty)
            _Baris(
              ikon: Icons.waves,
              label: context.l10n.potensi,
              nilai: gempa.potensi,
            ),
          if (gempa.dirasakan.isNotEmpty)
            _Baris(
              ikon: Icons.groups_outlined,
              label: context.l10n.dirasakanDi,
              nilai: gempa.dirasakan,
            ),
          if (jarak != null)
            _Baris(
              ikon: Icons.near_me_outlined,
              label: context.l10n.jarakDariAnda,
              nilai: context.l10n.jarakKm(Format.jarak(l, jarak)),
            )
          else if (gempa.punyaKoordinat)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AjakLokasi(),
            ),
          const SizedBox(height: 16),
          const SumberBmkg(),
        ],
      ),
    );
  }
}

class _Shakemap extends StatelessWidget {
  const _Shakemap({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final url = this.url;

    Widget tidakTersedia() => Container(
      height: 120,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      color: scheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.shakemapTidakTersedia,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.shakemapJudul, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url == null
              ? tidakTersedia()
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  semanticLabel: context.l10n.shakemapJudul,
                  loadingBuilder: (context, child, progres) {
                    if (progres == null) return child;
                    final total = progres.expectedTotalBytes;
                    return SizedBox(
                      height: 240,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: total == null
                              ? null
                              : progres.cumulativeBytesLoaded / total,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => tidakTersedia(),
                ),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris({required this.ikon, required this.label, required this.nilai});

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nilai.isEmpty ? Format.tandaKosong : nilai,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
