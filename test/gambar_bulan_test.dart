import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/widgets/gambar_bulan.dart';

/// Bagian cakram (jari-jari 1) yang terang menurut [jalurTerangBulan],
/// diperkirakan dengan titik sampel.
double _bagianTerang(double elongasi) {
  final jalur = jalurTerangBulan(elongasi, 1);
  var di = 0;
  var terang = 0;
  const n = 220;
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) {
      final x = -1 + 2 * (i + .5) / n;
      final y = -1 + 2 * (j + .5) / n;
      if (x * x + y * y > 1) continue;
      di++;
      if (jalur.contains(Offset(x, y))) terang++;
    }
  }
  return terang / di;
}

void main() {
  group('jalurTerangBulan', () {
    test('luas bagian terang sama dengan (1 - cos elongasi) / 2', () {
      for (final e in [0.0, 30.0, 60.0, 90.0, 120.0, 150.0, 180.0]) {
        final harap = (1 - math.cos(e * math.pi / 180)) / 2;
        expect(_bagianTerang(e), closeTo(harap, .02), reason: 'elongasi $e');
      }
    });

    test('bulan membesar: sisi kanan terang; perempat pertama tepat separuh '
        'kanan', () {
      final j = jalurTerangBulan(90, 1);
      expect(j.contains(const Offset(.5, 0)), isTrue);
      expect(j.contains(const Offset(-.5, 0)), isFalse);
    });

    test('sabit tipis hanya di tepi kanan, cembung mencakup lewat tengah', () {
      final sabit = jalurTerangBulan(30, 1);
      expect(sabit.contains(const Offset(.9, 0)), isTrue);
      expect(sabit.contains(const Offset(.2, 0)), isFalse);
      final cembung = jalurTerangBulan(150, 1);
      expect(cembung.contains(const Offset(.2, 0)), isTrue);
      expect(cembung.contains(const Offset(-.9, 0)), isFalse);
    });
  });

  testWidgets('GambarBulan menggambar semua fase di dua belahan tanpa error', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(
          children: [
            for (final e in [0, 45, 90, 135, 180, 225, 270, 315, 359])
              for (final selatan in [true, false])
                GambarBulan(
                  elongasi: e.toDouble(),
                  ukuran: 64,
                  selatan: selatan,
                  semantik: 'bulan $e',
                ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(GambarBulan), findsNWidgets(18));
  });
}
