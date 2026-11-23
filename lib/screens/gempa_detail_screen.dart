import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../widgets/ajak_lokasi.dart';
import '../widgets/badge_magnitudo.dart';
import '../widgets/status_data.dart';
import '../widgets/sumber_bmkg.dart';
import '../widgets/app_chrome.dart';

/// Halaman detail gempa. Dibuka lewat [Navigasi.bukaDetailGempa] (dari
/// daftar, kartu Beranda, maupun ketukan notifikasi). Semua isi dibangun
/// dari objek [Gempa] yang diberikan, tanpa memanggil API, sehingga tetap
/// tampil walau internet mati.
///
/// Informasi utama: magnitudo (angka 64 sp + label tingkat).
class GempaDetailScreen extends StatelessWidget {
  const GempaDetailScreen({super.key, required this.gempa});

  final Gempa gempa;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final jarak = context.watch<GempaProvider>().jarakKm(gempa);
    final lat = gempa.lat;
    final lon = gempa.lon;
    final teksKoordinat = [
      if (lat != null && lon != null) Format.koordinat(lat, lon),
      if (gempa.lintang.isNotEmpty || gempa.bujur.isNotEmpty)
        '(${[gempa.lintang, gempa.bujur].where((s) => s.isNotEmpty).join(', ')})',
    ].join(' ');

    return Scaffold(
      appBar: AppBar(
        title: Text(l.gempaDetailJudul),
        actions: [
          IconButton(
            tooltip: 'Salin ringkasan',
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final teks =
                  'Gempa M${gempa.magnitudo} terjadi ${gempa.wilayah} '
                  'pada ${gempa.tanggal} ${gempa.jam}. Kedalaman ${gempa.kedalaman}. '
                  'Sumber: BMKG.';
              await Clipboard.setData(ClipboardData(text: teks));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ringkasan disalin ke clipboard'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: LatarAtmosfer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            MasukLembut(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B1C78), Color(0xFF6651D7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusHero),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MagnitudoBesar(
                      magnitudo: gempa.magnitudoAngka,
                      teks: gempa.magnitudo,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gempa.wilayah.isEmpty
                          ? Format.tandaKosong
                          : gempa.wilayah,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        Format.waktuLengkap(l, gempa.waktuUtc),
                        Format.waktuRelatif(l, gempa.waktuUtc, DateTime.now()),
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE4DFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            MasukLembut(
              delay: const Duration(milliseconds: 90),
              child: KisiTile(
                children: [
                  TileInfo(
                    ikon: IkonApp.kedalaman,
                    label: l.kedalaman,
                    nilai: gempa.kedalaman,
                  ),
                  if (jarak != null)
                    TileInfo(
                      ikon: IkonApp.jarak,
                      label: l.jarakDariAnda,
                      nilai: l.jarakKm(Format.jarak(l, jarak)),
                    ),
                ],
              ),
            ),
            if (jarak == null && gempa.punyaKoordinat) ...[
              const SizedBox(height: 8),
              const AjakLokasi(),
            ],
            const SizedBox(height: 8),
            MasukLembut(
              delay: const Duration(milliseconds: 160),
              child: Card(
                child: Column(
                  children: [
                    _Baris(
                      ikon: IkonApp.waktu,
                      label: l.waktuKejadian,
                      nilai: Format.waktuLengkap(l, gempa.waktuUtc),
                    ),
                    const Divider(indent: 48),
                    _Baris(
                      ikon: IkonApp.koordinat,
                      label: l.koordinat,
                      nilai: teksKoordinat,
                    ),
                    if (gempa.potensi.isNotEmpty) ...[
                      const Divider(indent: 48),
                      _Baris(
                        ikon: IkonApp.potensi,
                        label: l.potensi,
                        nilai: gempa.potensi,
                      ),
                    ],
                    if (gempa.dirasakan.isNotEmpty) ...[
                      const Divider(indent: 48),
                      _Baris(
                        ikon: IkonApp.dirasakan,
                        label: l.dirasakanDi,
                        nilai: gempa.dirasakan,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            JudulBagian(l.shakemapJudul),
            MasukLembut(
              delay: const Duration(milliseconds: 220),
              child: _Shakemap(url: gempa.shakemapUrl),
            ),
            const SizedBox(height: 16),
            const SumberBmkg(),
          ],
        ),
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
      color: scheme.surfaceContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IkonApp.gambarTidakAda, color: scheme.onSurfaceVariant),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
      child: url == null
          ? tidakTersedia()
          : Image.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
              semanticLabel: context.l10n.shakemapJudul,
              loadingBuilder: (context, child, progres) {
                if (progres == null) return child;
                // Kerangka statis selama gambar dimuat.
                return Container(height: 240, color: scheme.surfaceContainer);
              },
              errorBuilder: (_, _, _) => tidakTersedia(),
            ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: theme.colorScheme.onSurfaceVariant),
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
