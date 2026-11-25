import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/riwayat_gempa_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/widgets/deret_cuaca.dart';
import 'package:app/widgets/kartu_kaca.dart';
import 'package:app/widgets/tombol_kaca.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.17, lon: 106.82);

Future<PengaturanProvider> _pengaturan({required bool kaca}) async {
  final p = PengaturanProvider(
    PreferencesService(),
    bahasa: PilihanBahasa.indonesia,
  );
  await p.aturKacaCair(kaca);
  return p;
}

/// Tidak ada satu pun widget kaca cair (lapisan kaca, tombol kaca, tab bar).
void _tanpaKaca() {
  expect(find.byType(GlassContainer), findsNothing);
  expect(find.byType(GlassIconButton), findsNothing);
  expect(find.byType(GlassTabBar), findsNothing);
  expect(find.byType(GlassBackdropGroup), findsNothing);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('kaca NYALA: navbar, tombol, dan kartu memakai widget kaca', (
    tester,
  ) async {
    await tester.pumpWidget(
      buatApp(gps: _gps, pengaturan: await _pengaturan(kaca: true)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(find.byType(GlassIconButton), findsWidgets);
    expect(find.byType(GlassContainer), findsWidgets);
  });

  testWidgets('kaca MATI: seluruh aplikasi tanpa widget kaca, tetap berfungsi '
      '(360 dp + huruf 1,3x)', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      buatApp(gps: _gps, pengaturan: await _pengaturan(kaca: false)),
    );
    await tester.pumpAndSettle();

    // Beranda: kartu per jam dan ringkasan detail ada, tanpa kaca.
    expect(find.byType(DeretPerJam), findsOneWidget);
    expect(find.byType(RingkasDetail), findsOneWidget);
    expect(find.byType(KartuKaca), findsWidgets);
    expect(find.byType(TombolKaca), findsWidgets);
    _tanpaKaca();

    // Navbar ringan: kunci tab, label hanya di tab aktif, sorot di tab aktif.
    for (final tab in ['beranda', 'cuaca', 'gempa', 'pengaturan']) {
      expect(navTab(tab), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('nav.sorot')), findsOneWidget);
    expect(find.text(l.navBeranda), findsOneWidget);
    expect(find.text(l.navGempa), findsNothing);

    // Pindah tab lewat ketukan; sorot ikut pindah, label berganti.
    final sebelum = tester
        .getCenter(find.byKey(const ValueKey('nav.sorot')))
        .dx;
    await tester.tap(navTab('gempa'));
    await tester.pumpAndSettle();
    final sesudah = tester
        .getCenter(find.byKey(const ValueKey('nav.sorot')))
        .dx;
    expect(sesudah, greaterThan(sebelum));
    expect(find.text(l.navGempa), findsWidgets);
    _tanpaKaca();

    // Tombol atas berupa lingkaran biasa dan tetap membuka halaman.
    await tester.tap(find.byIcon(IkonApp.riwayat));
    await tester.pumpAndSettle();
    expect(find.byType(RiwayatGempaScreen), findsOneWidget);
    _tanpaKaca();

    // Tombol kembali (LingkaranKaca) juga tanpa kaca dan tetap berfungsi.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(RiwayatGempaScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navbar ringan: semantik tombol, terpilih, dan data langsung', (
    tester,
  ) async {
    final semantik = tester.ensureSemantics();
    await tester.pumpWidget(
      buatApp(gps: _gps, pengaturan: await _pengaturan(kaca: false)),
    );
    await tester.pumpAndSettle();
    final gempa = tester.getSemantics(navTab('gempa'));
    expect(gempa.label, startsWith(l.navGempa));
    expect(gempa.label, contains(l.magnitudo));
    expect(gempa.flagsCollection.isButton, isTrue);
    expect(
      tester.getSemantics(navTab('beranda')).flagsCollection.isSelected.index,
      isNot(0),
    );
    semantik.dispose();
  });

  testWidgets('menyalakan kembali di Pengaturan: kaca muncul lagi tanpa '
      'mulai ulang', (tester) async {
    await tester.pumpWidget(
      buatApp(gps: _gps, pengaturan: await _pengaturan(kaca: false)),
    );
    await tester.pumpAndSettle();
    _tanpaKaca();

    await tester.tap(navTab('pengaturan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pengaturan.kacaCair')));
    await tester.pumpAndSettle();
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
