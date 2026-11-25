import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/services/gps_service.dart';
import 'package:app/widgets/kartu_kaca.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> bukaPengaturan(WidgetTester tester, {double skala = 1}) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = skala;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(buatApp(gps: _gps, offline: true));
    await tester.pumpAndSettle();
    await tester.tap(navTab('pengaturan'));
    await tester.pumpAndSettle();
  }

  testWidgets('daftar berkelompok: empat bagian, satu kartu kaca tiap bagian', (
    tester,
  ) async {
    await bukaPengaturan(tester);
    // Judul tiap bagian ada; kartu kaca dibangun malas, jadi gulir ke bawah
    // dulu supaya bagian Tentang ikut terbangun.
    for (final judul in [
      l.pengaturanPreferensi,
      l.pengaturanPeringatan,
      l.pengaturanTampilan,
    ]) {
      expect(find.text(judul), findsOneWidget, reason: judul);
    }
    await tester.dragUntilVisible(
      find.text(l.tentangJudul),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    expect(find.text(l.tentangJudul), findsOneWidget);
    // Preferensi, Peringatan, Tampilan, Tentang.
    expect(find.byType(KartuKaca, skipOffstage: false), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tema dan Bahasa jadi baris dengan nilai di kanan, bukan dua '
      'kartu', (tester) async {
    await bukaPengaturan(tester);
    // Nilai terpilih tampil di baris yang sama dengan judulnya.
    final judulTema = tester.getTopLeft(find.text(l.tentangTema)).dy;
    final judulBahasa = tester.getTopLeft(find.text(l.tentangBahasa)).dy;
    expect(judulBahasa, greaterThan(judulTema + 30));
    expect(find.text(l.ikutiSistem), findsOneWidget); // tema
    expect(find.text(l.bahasaIndonesia), findsOneWidget); // bahasa
    // Dua baris itu satu kartu: tinggi sama dan lebar penuh.
    final lebarTema = tester.getSize(find.text(l.tentangTema)).width;
    expect(lebarTema, lessThan(200));
  });

  testWidgets('sumber data jadi catatan di bawah, bukan baris yang bisa '
      'diketuk', (tester) async {
    await bukaPengaturan(tester);
    await tester.dragUntilVisible(
      find.text(l.tentangSumber),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    final catatan = find.text(l.tentangSumber);
    expect(catatan, findsOneWidget);
    expect(
      find.ancestor(of: catatan, matching: find.byType(ListTile)),
      findsNothing,
    );
    // Atribusi dan penegasan bukan aplikasi resmi tetap tampil.
    expect(l.tentangSumber, contains('BMKG'));
  });

  testWidgets('huruf besar 1,3x di 360 dp: seluruh daftar tanpa overflow', (
    tester,
  ) async {
    await bukaPengaturan(tester, skala: 1.3);
    final daftar = find.byType(ListView).last;
    for (var i = 0; i < 8; i++) {
      await tester.drag(daftar, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
