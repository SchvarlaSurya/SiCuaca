import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/l10n.dart';
import '../models/prakiraan.dart';

/// Entri prakiraan dari jam terdekat sekarang sampai 24 jam ke depan
/// (maksimal 9 titik, satu per 3 jam). Dihitung dari data yang sudah ada.
List<EntriPrakiraan> entri24Jam(Prakiraan prakiraan, EntriPrakiraan sekarang) {
  final awal = sekarang.waktuUtc;
  if (awal == null) return const [];
  final batas = awal.add(const Duration(hours: 24));
  return [
    for (final e in prakiraan.semuaEntri)
      if (e.suhu != null &&
          e.waktuUtc != null &&
          !e.waktuUtc!.isBefore(awal) &&
          !e.waktuUtc!.isAfter(batas))
        e,
  ];
}

/// Grafik garis suhu untuk [entri] (statis, tanpa animasi). Minimal tiga
/// titik, bila kurang tidak ditampilkan. Garis dan label memakai [warna]
/// supaya kontrasnya sama dengan teks kartu.
class GrafikSuhu extends StatelessWidget {
  const GrafikSuhu({
    super.key,
    required this.entri,
    required this.warna,
    required this.warnaRedup,
  });

  final List<EntriPrakiraan> entri;
  final Color warna;
  final Color warnaRedup;

  static const double _tinggi = 56;
  static const double _inset = 22;

  @override
  Widget build(BuildContext context) {
    final suhu = [for (final e in entri) e.suhu!];
    if (suhu.length < 3) return const SizedBox.shrink();
    final l = context.l10n;
    final theme = Theme.of(context);
    final rendah = suhu.reduce((a, b) => a < b ? a : b).round();
    final tinggi = suhu.reduce((a, b) => a > b ? a : b).round();

    return Semantics(
      label: l.grafikSuhuSemantik(
        '${suhu.first.round()}',
        '$tinggi',
        '$rendah',
      ),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.grafikSuhuJudul} · $rendah°–$tinggi°',
              style: theme.textTheme.bodySmall?.copyWith(color: warnaRedup),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: _tinggi,
              child: CustomPaint(
                size: const Size(double.infinity, _tinggi),
                painter: _GarisSuhu(suhu: suhu, warna: warna, inset: _inset),
              ),
            ),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, batas) {
                final n = entri.length;
                final lebar = batas.maxWidth - 2 * _inset;
                return SizedBox(
                  height: 18 * MediaQuery.textScalerOf(context).scale(1),
                  child: Stack(
                    children: [
                      for (var i = 0; i < n; i += 2)
                        Positioned(
                          left: _inset + lebar * i / (n - 1) - _inset,
                          width: 2 * _inset,
                          child: Text(
                            Format.jam(entri[i].waktuLokal).substring(0, 2),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: warnaRedup,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GarisSuhu extends CustomPainter {
  _GarisSuhu({required this.suhu, required this.warna, required this.inset});

  final List<double> suhu;
  final Color warna;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final n = suhu.length;
    final min = suhu.reduce((a, b) => a < b ? a : b);
    final max = suhu.reduce((a, b) => a > b ? a : b);
    final rentang = max - min;
    const vPad = 8.0;
    final lebar = size.width - 2 * inset;

    Offset titik(int i) {
      final y = rentang == 0
          ? size.height / 2
          : vPad + (size.height - 2 * vPad) * (1 - (suhu[i] - min) / rentang);
      return Offset(inset + lebar * i / (n - 1), y);
    }

    final garis = Path()..moveTo(titik(0).dx, titik(0).dy);
    for (var i = 1; i < n; i++) {
      final a = titik(i - 1);
      final b = titik(i);
      final tengah = (a.dx + b.dx) / 2;
      garis.cubicTo(tengah, a.dy, tengah, b.dy, b.dx, b.dy);
    }
    canvas.drawPath(
      garis,
      Paint()
        ..color = warna
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final isi = Paint()..color = warna;
    for (var i = 1; i < n; i++) {
      canvas.drawCircle(titik(i), 3, isi);
    }
    // Titik pertama = sekarang: lebih besar dengan cincin.
    canvas.drawCircle(titik(0), 6.5, isi);
    canvas.drawCircle(
      titik(0),
      6.5,
      Paint()
        ..color = warna.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(_GarisSuhu lama) =>
      lama.suhu != suhu || lama.warna != warna || lama.inset != inset;
}
