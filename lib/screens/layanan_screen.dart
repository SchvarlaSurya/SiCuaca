import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/tautan_resmi.dart';
import '../widgets/app_chrome.dart';
import '../widgets/sumber_bmkg.dart';
import 'maritim_screen.dart';

/// Layanan BMKG yang belum ada di layar utama SiCuaca.
///
/// Hanya Cuaca maritim yang datanya diambil lewat API resmi BMKG. Layanan
/// lain tidak punya data terbuka untuk aplikasi, jadi kartunya membuka
/// halaman resmi BMKG (isinya tidak disalin). Radar ditunda karena aksesnya
/// belum terbuka; kartunya menyebut itu dengan jujur.
class LayananScreen extends StatelessWidget {
  const LayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final tautan = [
      (
        kunci: 'radar',
        ikon: IkonApp.radar,
        judul: l.layananRadarJudul,
        ket: l.layananRadarKet,
        url: TautanResmi.radar,
      ),
      (
        kunci: 'penerbangan',
        ikon: IkonApp.pesawat,
        judul: l.layananPenerbanganJudul,
        ket: l.layananPenerbanganKet,
        url: TautanResmi.penerbangan,
      ),
      (
        kunci: 'titikPanas',
        ikon: IkonApp.titikPanas,
        judul: l.layananTitikPanasJudul,
        ket: l.layananTitikPanasKet,
        url: TautanResmi.titikPanas,
      ),
      (
        kunci: 'iklim',
        ikon: IkonApp.iklim,
        judul: l.layananIklimJudul,
        ket: l.layananIklimKet,
        url: TautanResmi.iklim,
      ),
      (
        kunci: 'siaranPers',
        ikon: IkonApp.koran,
        judul: l.layananSiaranPersJudul,
        ket: l.layananSiaranPersKet,
        url: TautanResmi.siaranPers,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.layananJudul)),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            MasukLembut(
              child: _KartuLayanan(
                key: const ValueKey('layanan.maritim'),
                ikon: IkonApp.kapal,
                judul: l.layananMaritimJudul,
                keterangan: l.layananMaritimKet,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MaritimScreen(),
                  ),
                ),
              ),
            ),
            for (final (i, t) in tautan.indexed)
              MasukLembut(
                delay: Duration(milliseconds: 50 * (i + 1)),
                child: _KartuLayanan(
                  key: ValueKey('layanan.${t.kunci}'),
                  ikon: t.ikon,
                  judul: t.judul,
                  keterangan: t.ket,
                  tautanKeluar: true,
                  onTap: () => TautanResmiBmkg.buka(context, t.url),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              l.layananTautanCatatan,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const SumberBmkg(),
            const SizedBox(height: 4),
            Text(
              l.bukanResmi,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuLayanan extends StatelessWidget {
  const _KartuLayanan({
    super.key,
    required this.ikon,
    required this.judul,
    required this.keterangan,
    required this.onTap,
    this.tautanKeluar = false,
  });

  final IconData ikon;
  final String judul;
  final String keterangan;
  final VoidCallback onTap;
  final bool tautanKeluar;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: TekanLembut(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IkonDuo(ikon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      keterangan,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (tautanKeluar) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l.layananLabelTautan} · ${l.layananBukaResmi}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: IkonDuo(
                  IkonApp.selengkapnya,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
