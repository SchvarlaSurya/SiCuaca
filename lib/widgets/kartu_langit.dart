import 'package:flutter/material.dart';

import '../core/astronomi.dart';
import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import 'gambar_bulan.dart';
import 'kartu_kaca.dart';
import 'lintasan_langit.dart';

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

/// Matahari dan bulan dalam satu kartu kaca: garis lintasan dari terbit ke
/// terbenam dengan ikon benda di posisi jam sekarang, lama siang, dan gambar
/// bulan berbayangan sesuai fase. Semuanya dihitung di dalam aplikasi dari
/// lokasi dan tanggal (lihat [Astronomi]), bukan data BMKG, dan kartunya
/// mengatakan itu.
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
    LintasanLangit? lintasan(BendaLangit b) => Astronomi.lintasan(
      benda: b,
      lat: lat,
      lon: lon,
      sekarangSetempat: hariSetempat,
      selisih: selisih,
    );
    final siang = data.lamaSiang;
    final fase = namaFaseBulan(l, data.fase);
    final terang = l.terangBulan((data.terangBulan * 100).round());

    return KartuKaca(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.langitJudul, style: theme.textTheme.titleSmall),
          const SizedBox(height: 14),
          Row(
            children: [
              IkonDuo(IkonApp.terbitTerbenam, size: 22, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.matahari, style: theme.textTheme.labelLarge),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Label dan nilai di baris sendiri: tetap muat saat huruf besar.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l.lamaSiang,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                siang == null
                    ? Format.tandaKosong
                    : l.lamaSiangNilai(siang.inHours, siang.inMinutes % 60),
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          LintasanLangitView(
            benda: BendaLangit.matahari,
            lintasan: lintasan(BendaLangit.matahari),
            hariSetempat: hariSetempat,
          ),
          Divider(height: 28, color: AppTheme.kacaTepi(theme.brightness)),
          Row(
            children: [
              GambarBulan(
                elongasi: data.elongasi,
                selatan: lat < 0,
                ukuran: 60,
                semantik: '$fase, $terang',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.bulan, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 2),
                    Text(fase, style: theme.textTheme.titleMedium),
                    Text(
                      terang,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LintasanLangitView(
            benda: BendaLangit.bulan,
            lintasan: lintasan(BendaLangit.bulan),
            hariSetempat: hariSetempat,
            elongasi: data.elongasi,
            selatan: lat < 0,
          ),
          const SizedBox(height: 12),
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
