import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/widgets/aset_bulan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('semua berkas foto bulan dan shader ada di bundel aset', () async {
    for (final u in [256, 512, 1024]) {
      final d = await rootBundle.load('assets/bulan/bulan_warna_$u.webp');
      expect(d.lengthInBytes, greaterThan(1000), reason: 'warna $u');
    }
    for (final u in [256, 512]) {
      final d = await rootBundle.load('assets/bulan/bulan_relief_$u.webp');
      expect(d.lengthInBytes, greaterThan(1000), reason: 'relief $u');
    }
    final kredit = await rootBundle.loadString('assets/bulan/KREDIT-NASA.txt');
    expect(kredit, contains('NASA'));
    expect(kredit, contains('svs.gsfc.nasa.gov/4720'));
  });

  testWidgets('memuat foto dan shader, lalu menyediakan shader per fase', (
    tester,
  ) async {
    await tester.runAsync(AsetBulan.muat);
    expect(AsetBulan.siap.value, isTrue);
    expect(AsetBulan.bisaDipakai, isTrue);
    for (final e in [0.0, 90.0, 180.0, 270.0]) {
      expect(
        AsetBulan.shader(diameterPiksel: 180, ukuranLokal: 60, elongasi: e),
        isNotNull,
      );
    }
    // Ukuran besar memakai tekstur terbesar tanpa error.
    expect(
      AsetBulan.shader(diameterPiksel: 3000, ukuranLokal: 1000, elongasi: 45),
      isNotNull,
    );
  });
}
