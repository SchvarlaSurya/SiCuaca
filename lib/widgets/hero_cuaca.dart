import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../core/warna_semantik.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../services/share_service.dart';
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
    // Gradasi ungu selalu gelap, jadi ujung kondisinya diambil dari palet
    // gelap dan teksnya terang di kedua tema. Kontras terendah teks
    // terhadap #302080, #6250DB, dan 10 warna kondisi gelap: 5,21:1.
    final gaya = GayaHero.untuk(
      KondisiLangit.dari(entri.deskripsi),
      malam: entri.malam,
      kecerahan: Brightness.dark,
    );
    final teks = polos ? scheme.onPrimaryContainer : Colors.white;
    final redup = polos ? scheme.onPrimaryContainer : gaya.teks;
    final deskripsi = l.deskripsiCuaca(entri);

    final kartu = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 10, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusHero),
        color: polos ? scheme.primaryContainer : null,
        gradient: polos
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF302080),
                  const Color(0xFF6250DB),
                  gaya.bawah,
                ],
              ),
        boxShadow: polos
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF4E3BCC).withValues(alpha: .26),
                  blurRadius: 26,
                  offset: const Offset(0, 13),
                ),
              ],
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
                        Row(
                          children: [
                            Icon(IkonApp.tempat, size: 17, color: teks),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                wilayah.desa,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: teks,
                                ),
                              ),
                            ),
                          ],
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(IkonApp.bagikan),
                      color: teks,
                      tooltip: l.bagikanCuaca,
                      onPressed: () {
                        ShareService.bagikanCuaca(
                          l,
                          desa: wilayah.desa,
                          induk: wilayah.labelInduk,
                          kondisi: deskripsi.isEmpty
                              ? entri.deskripsi
                              : deskripsi,
                          suhu: Format.suhu(entri.suhu),
                          kelembapan: Format.persen(entri.kelembapan),
                          angin: Format.angin(
                            l,
                            entri.kecepatanAngin,
                            entri.arahAngin,
                          ),
                        );
                      },
                    ),
                    ?aksi,
                  ],
                ),
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
                        fontSize: 72,
                        letterSpacing: -3,
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

    // Kartu sengaja statis (syarat Fase 5.5): tanpa animasi latar.
    return kartu;
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
