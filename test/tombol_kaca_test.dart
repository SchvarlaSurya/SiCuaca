import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/l10n.dart';
import 'package:app/screens/riwayat_gempa_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/widgets/tombol_kaca.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);
final l = lookupAppLocalizations(const Locale('id'));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tombol atas tab Gempa berupa tombol kaca dan tetap berfungsi', (
    tester,
  ) async {
    await tester.pumpWidget(buatApp(gps: _gps, offline: true));
    await tester.pumpAndSettle();
    await tester.tap(navTab('gempa'));
    await tester.pumpAndSettle();

    for (final nama in [l.navPeringatan, l.siagaJudul, l.riwayatJudul]) {
      expect(
        find.ancestor(
          of: find.byTooltip(nama),
          matching: find.byType(TombolKaca),
        ),
        findsOneWidget,
      );
    }

    await tester.tap(find.byIcon(IkonApp.riwayat));
    await tester.pumpAndSettle();
    expect(find.byType(RiwayatGempaScreen), findsOneWidget);
  });

  testWidgets('menu grafik di Riwayat muncul dari tombol kaca dan membuka '
      'grafik', (tester) async {
    await tester.pumpWidget(buatApp(gps: _gps, offline: true));
    await tester.pumpAndSettle();
    await tester.tap(navTab('gempa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(IkonApp.riwayat));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(IkonApp.grafik));
    await tester.pumpAndSettle();
    expect(find.text(l.grafikPerHari), findsOneWidget);
    expect(find.text(l.grafikPerMinggu), findsOneWidget);

    await tester.tap(find.text(l.grafikPerHari));
    await tester.pumpAndSettle();
    expect(find.byType(GrafikGempaScreen), findsOneWidget);

    // Tombol kembali bawaan (ikon lingkaran kaca) tetap menutup halaman.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(GrafikGempaScreen), findsNothing);
    expect(find.byType(RiwayatGempaScreen), findsOneWidget);
    expect(find.byType(LingkaranKaca), findsOneWidget);
  });
}
