import 'package:flutter/material.dart';

import '../core/astronomi.dart';
import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/ringkas_harian.dart';
import '../core/theme.dart';
import '../models/prakiraan.dart';
import 'ikon_cuaca.dart';
import 'kartu_kaca.dart';

/// Suhu tanpa satuan untuk deret ringkas, mis. "28°".
String suhuPendek(double? c) =>
    c == null ? Format.tandaKosong : '${c.round()}°';

/// Prakiraan per jam dalam kartu kaca: deret geser "Sekarang · 12:00 · …"
/// berisi jam, ikon cuaca berwarna, dan suhu. Entri pertama (yang sedang
/// berlaku) disorot.
class DeretPerJam extends StatelessWidget {
  const DeretPerJam({super.key, required this.entri});

  final List<EntriPrakiraan> entri;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return KartuKaca(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(l.perJamJudul, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(height: 8),
          // Tinggi mengikuti isi (aman untuk huruf besar); digeser mendatar.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, e) in entri.indexed) ...[
                  if (i > 0) const SizedBox(width: 4),
                  _SelJam(entri: e, sekarang: i == 0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelJam extends StatelessWidget {
  const _SelJam({required this.entri, required this.sekarang});

  final EntriPrakiraan entri;
  final bool sekarang;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = sekarang ? l.sekarang : Format.jam(entri.waktuLokal);
    return Semantics(
      label: '$label, ${l.deskripsiCuaca(entri)}, ${Format.suhu(entri.suhu)}',
      excludeSemantics: true,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: sekarang
            ? BoxDecoration(
                color: scheme.primary.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: theme.textTheme.labelMedium?.copyWith(
                color: sekarang ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            IkonCuaca(deskripsi: entri.deskripsi, malam: entri.malam, size: 30),
            const SizedBox(height: 6),
            Text(suhuPendek(entri.suhu), style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Ringkasan detail saat ini dalam satu kartu kaca: kelembapan, angin,
/// jarak pandang (bila ada), dan titik embun (dihitung dari suhu dan
/// kelembapan), masing-masing dengan ikon dan label teks. Sampai tiga sel
/// dalam satu baris; lebih dari itu dibagi dua baris agar tidak sempit.
class RingkasDetail extends StatelessWidget {
  const RingkasDetail({super.key, required this.entri});

  final EntriPrakiraan entri;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final item = [
      (IkonApp.kelembapan, l.kelembapan, Format.persen(entri.kelembapan)),
      (
        IkonApp.angin,
        l.angin,
        Format.angin(l, entri.kecepatanAngin, entri.arahAngin),
      ),
      if (entri.jarakPandang case final jarak? when jarak.trim().isNotEmpty)
        (IkonApp.jarakPandang, l.jarakPandang, jarak.trim()),
      if (entri.suhu case final suhu? when entri.kelembapan != null)
        (
          IkonApp.titikEmbun,
          l.titikEmbun,
          Format.suhu(Astronomi.titikEmbun(suhu, entri.kelembapan!)),
        ),
    ];
    final garis = AppTheme.kacaTepi(Theme.of(context).brightness);
    return KartuKaca(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: item.length <= 3
          ? _BarisDetail(item: item, kolom: item.length)
          : Column(
              children: [
                _BarisDetail(item: item.sublist(0, 2), kolom: 2),
                Divider(height: 24, color: garis),
                _BarisDetail(item: item.sublist(2), kolom: 2),
              ],
            ),
    );
  }
}

typedef _ItemDetail = (IconData, String, String);

/// Satu baris sel detail dengan pembatas tegak. [kolom] lebih besar dari
/// jumlah item menyisakan ruang kosong di kanan supaya lebar sel tetap sama.
class _BarisDetail extends StatelessWidget {
  const _BarisDetail({required this.item, required this.kolom});

  final List<_ItemDetail> item;
  final int kolom;

  @override
  Widget build(BuildContext context) {
    final garis = AppTheme.kacaTepi(Theme.of(context).brightness);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (ikon, label, nilai)) in item.indexed) ...[
            if (i > 0) VerticalDivider(width: 1, color: garis),
            Expanded(
              child: _SelDetail(ikon: ikon, label: label, nilai: nilai),
            ),
          ],
          for (var i = item.length; i < kolom; i++) const Spacer(),
        ],
      ),
    );
  }
}

class _SelDetail extends StatelessWidget {
  const _SelDetail({
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          IkonDuo(ikon, size: 24, color: scheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nilai,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

/// Prakiraan harian dalam kartu kaca: hari, ikon siang, kondisi, dan suhu
/// tertinggi/terendah dari data 3-jam BMKG.
class DaftarHarian extends StatelessWidget {
  const DaftarHarian({super.key, required this.hari, required this.hariIni});

  final List<RingkasHari> hari;

  /// Jam dinding setempat sekarang, untuk label "Hari ini"/"Besok".
  final DateTime hariIni;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return KartuKaca(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final (i, h) in hari.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppTheme.kacaTepi(theme.brightness),
              ),
            Semantics(
              label: l.harianSemantik(
                Format.labelHari(l, h.tanggal, hariIni),
                l.deskripsiCuaca(h.wakil),
                Format.suhu(h.tertinggi),
                Format.suhu(h.terendah),
              ),
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        Format.labelHari(l, h.tanggal, hariIni),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    IkonCuaca(
                      deskripsi: h.wakil.deskripsi,
                      malam: false,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Text(
                        l.deskripsiCuaca(h.wakil),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: suhuPendek(h.tertinggi),
                            style: theme.textTheme.titleMedium,
                          ),
                          TextSpan(
                            text: ' / ${suhuPendek(h.terendah)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
