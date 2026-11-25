import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../services/share_service.dart';
import 'angka_berhitung.dart';
import 'ikon_cuaca.dart';
import 'status_data.dart';
import 'tombol_kaca.dart';

/// Hero cuaca gaya "Langit Kaca": langsung di atas latar langit (tanpa
/// kartu). Pil lokasi kaca, suhu besar bergaya tipis, kondisi, jam
/// prakiraan, dan ikon cuaca berwarna besar.
class HeroCuaca extends StatelessWidget {
  const HeroCuaca({
    super.key,
    required this.wilayah,
    required this.entri,
    required this.selisihZona,
    this.aksi,
  });

  final Lokasi wilayah;
  final EntriPrakiraan entri;
  final Duration? selisihZona;

  /// Tombol di kanan atas (mis. favorit).
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final deskripsi = l.deskripsiCuaca(entri);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PilLokasi(wilayah: wilayah)),
            const SizedBox(width: 8),
            TombolKaca(
              tooltip: l.bagikanCuaca,
              icon: const IkonDuo(IkonApp.bagikan),
              onPressed: () {
                ShareService.bagikanCuaca(
                  l,
                  desa: wilayah.desa,
                  induk: wilayah.labelInduk,
                  kondisi: deskripsi.isEmpty ? entri.deskripsi : deskripsi,
                  suhu: Format.suhu(entri.suhu),
                  kelembapan: Format.persen(entri.kelembapan),
                  angin: Format.angin(l, entri.kecepatanAngin, entri.arahAngin),
                );
              },
            ),
            ?aksi,
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SuhuBerhitung(
                    nilai: entri.suhu,
                    style: TextStyle(
                      fontFamily: AppTheme.hurufIsi,
                      fontSize: 84,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                      letterSpacing: -4,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    deskripsi.isEmpty ? Format.tandaKosong : deskripsi,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.pukul(
                      '${Format.jam(entri.waktuLokal)} '
                              '${Format.zona(selisihZona)}'
                          .trim(),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IkonCuaca(
              deskripsi: entri.deskripsi,
              malam: entri.malam,
              size: 104,
            ),
          ],
        ),
      ],
    );
  }
}

/// Pil kaca berisi pin dan nama tempat, dengan wilayah induk di bawahnya.
class _PilLokasi extends StatelessWidget {
  const _PilLokasi({required this.wilayah});

  final Lokasi wilayah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
          decoration: BoxDecoration(
            color: AppTheme.kacaIsi(theme.brightness),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.kacaTepi(theme.brightness)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IkonDuo(IkonApp.tempat, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  wilayah.desa,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (wilayah.labelInduk.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              wilayah.labelInduk,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Tile kelembapan dan angin untuk satu entri prakiraan.
List<Widget> tileCuaca(BuildContext context, EntriPrakiraan entri) {
  final l = context.l10n;
  return [
    TileInfo(
      ikon: IkonApp.kelembapan,
      label: l.kelembapan,
      nilai: Format.persen(entri.kelembapan),
    ),
    TileInfo(
      ikon: IkonApp.angin,
      label: l.angin,
      nilai: Format.angin(l, entri.kecepatanAngin, entri.arahAngin),
    ),
  ];
}
