import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../core/warna_semantik.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import 'ikon_cuaca.dart';
import 'status_data.dart';

/// Kartu utama cuaca: nama tempat, suhu 64 sp, kondisi, jam prakiraan.
///
/// Latarnya gradasi statis sesuai kondisi × siang/malam × tema. Bila
/// pengguna mengaktifkan "kurangi gerakan/animasi", gradasi dimatikan dan
/// kartu memakai warna kontainer primer biasa.
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
    final polos = MediaQuery.of(context).disableAnimations;
    final gaya = GayaHero.untuk(
      KondisiLangit.dari(entri.deskripsi),
      malam: entri.malam,
      kecerahan: theme.brightness,
    );
    final teks = polos ? scheme.onPrimaryContainer : gaya.teks;
    final redup = polos ? scheme.onPrimaryContainer : gaya.redup;
    final deskripsi = l.deskripsiCuaca(entri);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusHero),
        color: polos ? scheme.primaryContainer : null,
        gradient: polos
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gaya.atas, gaya.bawah],
              ),
      ),
      child: IconTheme(
        data: IconThemeData(color: teks),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wilayah.desa,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: teks,
                          ),
                        ),
                        Text(
                          wilayah.labelInduk,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: redup,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ?aksi,
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      Format.suhu(entri.suhu),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: teks,
                      ),
                    ),
                  ),
                  IkonCuaca(
                    deskripsi: entri.deskripsi,
                    malam: entri.malam,
                    size: 56,
                    warna: teks,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              deskripsi.isEmpty ? Format.tandaKosong : deskripsi,
              style: theme.textTheme.titleMedium?.copyWith(color: teks),
            ),
            Text(
              l.pukul(
                '${Format.jam(entri.waktuLokal)} '
                        '${Format.zona(selisihZona)}'
                    .trim(),
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: redup),
            ),
          ],
        ),
      ),
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
