import 'package:flutter/material.dart';

import '../core/astronomi.dart';
import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import 'kartu_kaca.dart';

/// Nama fase bulan dalam bahasa aktif.
String namaFaseBulan(AppLocalizations l, FaseBulan fase) => switch (fase) {
  FaseBulan.baru => l.faseBaru,
  FaseBulan.sabitAwal => l.faseSabitAwal,
  FaseBulan.perempatPertama => l.fasePerempatPertama,
  FaseBulan.cembungAwal => l.faseCembungAwal,
  FaseBulan.purnama => l.fasePurnama,
  FaseBulan.cembungAkhir => l.faseCembungAkhir,
  FaseBulan.perempatAkhir => l.fasePerempatAkhir,
  FaseBulan.sabitAkhir => l.faseSabitAkhir,
};

/// Matahari dan bulan hari ini dalam satu kartu kaca: jam terbit dan
/// terbenam, lama siang, serta fase bulan. Semuanya dihitung di dalam
/// aplikasi dari lokasi dan tanggal (lihat [Astronomi]), bukan data BMKG, dan
/// kartunya mengatakan itu.
class KartuMatahariBulan extends StatelessWidget {
  const KartuMatahariBulan({
    super.key,
    required this.lat,
    required this.lon,
    required this.hariSetempat,
    required this.selisih,
  });

  final double lat;
  final double lon;

  /// Jam dinding setempat sekarang (DateTime UTC yang sudah digeser zona).
  final DateTime hariSetempat;
  final Duration selisih;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final data = Astronomi.hitung(
      lat: lat,
      lon: lon,
      tanggalSetempat: hariSetempat,
      selisih: selisih,
    );
    String saat(DateTime? t) => t == null ? l.tidakAdaHariIni : Format.jam(t);
    final siang = data.lamaSiang;

    return KartuKaca(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.langitJudul, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Kolom(
                    ikon: IkonApp.terbitTerbenam,
                    judul: l.matahari,
                    baris: [
                      (l.terbit, saat(data.matahari.terbit)),
                      (l.terbenam, saat(data.matahari.terbenam)),
                      (
                        l.lamaSiang,
                        siang == null
                            ? Format.tandaKosong
                            : l.lamaSiangNilai(
                                siang.inHours,
                                siang.inMinutes % 60,
                              ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                  width: 24,
                  color: AppTheme.kacaTepi(theme.brightness),
                ),
                Expanded(
                  child: _Kolom(
                    ikon: IkonApp.faseBulan,
                    judul: l.bulan,
                    baris: [
                      (l.terbit, saat(data.bulan.terbit)),
                      (l.terbenam, saat(data.bulan.terbenam)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${namaFaseBulan(l, data.fase)} · '
            '${l.terangBulan((data.terangBulan * 100).round())}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l.langitCatatan,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Kolom extends StatelessWidget {
  const _Kolom({required this.ikon, required this.judul, required this.baris});

  final IconData ikon;
  final String judul;
  final List<(String, String)> baris;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IkonDuo(ikon, size: 22, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(judul, style: theme.textTheme.labelLarge)),
          ],
        ),
        const SizedBox(height: 8),
        for (final (label, nilai) in baris)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    nilai,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
