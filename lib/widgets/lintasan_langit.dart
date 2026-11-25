import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/astronomi.dart';
import '../core/format.dart';
import '../core/l10n.dart';
import 'gambar_bulan.dart';

/// Garis lintasan matahari atau bulan dari terbit ke terbenam, dengan ikon
/// benda yang berada di titik sesuai jam sekarang. Bentuk garisnya tinggi
/// sebenarnya benda sepanjang lintasan (bukan setengah lingkaran buatan).
/// Saat halaman dibuka, ikon meluncur dari titik terbit ke posisinya (diam
/// bila "kurangi gerakan" nyala). Bulan digambar dengan bayangan fasenya.
class LintasanLangitView extends StatelessWidget {
  const LintasanLangitView({
    super.key,
    required this.benda,
    required this.lintasan,
    required this.hariSetempat,
    this.elongasi = 0,
    this.selatan = true,
    this.tinggi = 104,
  });

  final BendaLangit benda;
  final LintasanLangit? lintasan;

  /// Jam dinding setempat sekarang, untuk menandai terbit/terbenam yang jatuh
  /// di hari lain dengan "+1" atau "-1".
  final DateTime hariSetempat;

  /// Hanya untuk bulan: dipakai menggambar fase pada ikonnya.
  final double elongasi;
  final bool selatan;
  final double tinggi;

  static const _jingga = Color(0xFFF5A623);

  String _jam(DateTime t) {
    final hari = DateTime.utc(
      hariSetempat.year,
      hariSetempat.month,
      hariSetempat.day,
    );
    final beda = DateTime.utc(t.year, t.month, t.day).difference(hari).inDays;
    final tanda = beda == 0 ? '' : (beda > 0 ? ' (+$beda)' : ' ($beda)');
    return '${Format.jam(t)}$tanda';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final nama = benda == BendaLangit.matahari ? l.matahari : l.bulan;
    final lin = lintasan;
    if (lin == null) {
      return Text(
        '$nama: ${l.tidakAdaHariIni}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }
    final garis = benda == BendaLangit.matahari ? _jingga : scheme.primary;
    final reduksi = MediaQuery.of(context).disableAnimations;
    final di = lin.posisi;

    Widget ujung(String label, String nilai, CrossAxisAlignment sisi) => Column(
      crossAxisAlignment: sisi,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        Text(nilai, style: theme.textTheme.titleSmall),
      ],
    );

    return Semantics(
      label:
          '$nama, ${l.terbit} ${_jam(lin.terbit)}, '
          '${l.terbenam} ${_jam(lin.terbenam)}',
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: tinggi,
            child: Stack(
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: di ?? 0),
                    duration: reduksi
                        ? Duration.zero
                        : const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, p, _) => CustomPaint(
                      painter: _PelukisLintasan(
                        lintasan: lin,
                        progres: p,
                        adaIkon: di != null,
                        benda: benda,
                        warna: garis,
                        warnaGaris: scheme.onSurface.withValues(alpha: .28),
                        elongasi: elongasi,
                        selatan: selatan,
                      ),
                    ),
                  ),
                ),
                if (di == null)
                  Align(
                    alignment: const Alignment(0, .1),
                    child: Text(
                      l.diBawahHorizon,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ujung(l.terbit, _jam(lin.terbit), CrossAxisAlignment.start),
              ujung(l.terbenam, _jam(lin.terbenam), CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }
}

class _PelukisLintasan extends CustomPainter {
  _PelukisLintasan({
    required this.lintasan,
    required this.progres,
    required this.adaIkon,
    required this.benda,
    required this.warna,
    required this.warnaGaris,
    required this.elongasi,
    required this.selatan,
  });

  final LintasanLangit lintasan;

  /// 0..1: sejauh mana ikon sudah meluncur sepanjang lintasan (dalam waktu).
  final double progres;
  final bool adaIkon;
  final BendaLangit benda;
  final Color warna;
  final Color warnaGaris;
  final double elongasi;
  final bool selatan;

  static const _tepi = 14.0; // ruang untuk ikon di kiri dan kanan
  static const _atas = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final dasar = size.height - 4;
    final lebar = size.width - _tepi * 2;
    final titik = lintasan.titik;
    final n = titik.length - 1;
    // Tinggi dinormalkan ke 40 derajat atau lebih supaya lengkung rendah
    // (bulan di lintang tinggi) tetap terbaca; bentuknya tetap sebenarnya.
    final tertinggi = titik.fold<double>(0, (a, t) => math.max(a, t.tinggi));
    final skala = math.max(tertinggi, 40);
    final area = dasar - _atas;

    // Titik ke-i di layar; ujung lintasan tepat di cakrawala.
    Offset di(int i) => Offset(
      _tepi + lebar * i / n,
      i == 0 || i == n
          ? dasar
          : dasar - area * (titik[i].tinggi.clamp(0, 90) / skala).clamp(0, 1),
    );

    final jalur = Path()..moveTo(di(0).dx, di(0).dy);
    for (var i = 1; i <= n; i++) {
      jalur.lineTo(di(i).dx, di(i).dy);
    }

    // Isian di bawah lengkung.
    canvas.drawPath(
      Path.from(jalur)..close(),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, dasar - area),
          Offset(0, dasar),
          [warna.withValues(alpha: .22), warna.withValues(alpha: 0)],
        ),
    );

    // Garis cakrawala.
    canvas.drawLine(
      Offset(0, dasar),
      Offset(size.width, dasar),
      Paint()
        ..color = warnaGaris
        ..strokeWidth = 1,
    );

    // Lengkung bertitik-titik (seluruh lintasan).
    final metrik = jalur.computeMetrics().first;
    final putus = Paint()
      ..color = warna.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var d = 0.0; d < metrik.length; d += 9) {
      canvas.drawPath(
        metrik.extractPath(d, math.min(d + 4.5, metrik.length)),
        putus,
      );
    }

    // Bagian yang sudah dilalui: garis penuh sampai ikon. Titik tersebar
    // seragam dalam waktu, jadi posisi ikon cukup diinterpolasi antar titik.
    if (adaIkon || progres > 0) {
      final pos = progres.clamp(0.0, 1.0) * n;
      final i = pos.floor().clamp(0, n - 1);
      final ujung = Offset.lerp(di(i), di(i + 1), pos - i)!;
      final lalu = Path()..moveTo(di(0).dx, di(0).dy);
      for (var k = 1; k <= i; k++) {
        lalu.lineTo(di(k).dx, di(k).dy);
      }
      lalu.lineTo(ujung.dx, ujung.dy);
      canvas.drawPath(
        lalu,
        Paint()
          ..color = warna
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      _ikon(canvas, ujung);
    }
  }

  void _ikon(Canvas canvas, Offset p) {
    if (benda == BendaLangit.matahari) {
      canvas.drawCircle(
        p,
        18,
        Paint()
          ..shader = ui.Gradient.radial(p, 18, [
            const Color(0xFFFFC83D).withValues(alpha: .55),
            const Color(0xFFFFC83D).withValues(alpha: 0),
          ]),
      );
      canvas.drawCircle(p, 8.5, Paint()..color = const Color(0xFFFFC83D));
      canvas.drawCircle(
        p,
        8.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withValues(alpha: .85),
      );
    } else {
      lukisBulan(canvas, p, 11, elongasi, selatan: selatan);
    }
  }

  @override
  bool shouldRepaint(_PelukisLintasan lama) =>
      lama.progres != progres ||
      lama.lintasan != lintasan ||
      lama.warna != warna ||
      lama.elongasi != elongasi ||
      lama.warnaGaris != warnaGaris;
}
