import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/l10n.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/riwayat_gempa_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/widgets/tombol_kaca.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);
final l = lookupAppLocalizations(const Locale('id'));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GrupTombolKaca.jumlahTerakhir = null;
  });

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

  group('Grup tombol kaca membelah', () {
    // Jarak antara tombol baru (Peringatan, paling kiri) dan tombol terdekat
    // yang sudah ada (Siap Siaga).
    double jarak(WidgetTester tester) =>
        tester.getCenter(find.byTooltip(l.siagaJudul)).dx -
        tester.getCenter(find.byTooltip(l.navPeringatan)).dx;

    testWidgets('Beranda (2 tombol) ke Gempa (3 tombol): tombol baru keluar '
        'dari tombol terdekat lalu meluncur ke tempatnya', (tester) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true));
      await tester.pumpAndSettle();
      expect(GrupTombolKaca.jumlahTerakhir, 2);

      await tester.tap(navTab('gempa'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final tengah = jarak(tester);

      await tester.pumpAndSettle();
      final akhir = jarak(tester);
      expect(akhir, closeTo(TombolKaca.lebarSlot, 0.5));
      // Di tengah animasi tombol baru masih menumpuk dekat tetangganya.
      expect(tengah, lessThan(akhir - 8));
      expect(GrupTombolKaca.jumlahTerakhir, 3);
    });

    testWidgets('efek kaca cair dimatikan: tombol langsung di tempat', (
      tester,
    ) async {
      final pengaturan = PengaturanProvider(
        PreferencesService(),
        bahasa: PilihanBahasa.indonesia,
      );
      await pengaturan.aturKacaCair(false);
      await tester.pumpWidget(
        buatApp(gps: _gps, offline: true, pengaturan: pengaturan),
      );
      await tester.pumpAndSettle();
      await tester.tap(navTab('gempa'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(jarak(tester), closeTo(TombolKaca.lebarSlot, 0.5));

      // Seluruh aplikasi memakai kaca sederhana tanpa shader.
      final tema = tester.widget<GlassTheme>(find.byType(GlassTheme).first);
      expect(tema.data.light, GlassThemeVariant.minimalLight);
      await tester.pumpAndSettle();
    });
  });

  testWidgets('sakelar Pengaturan menyimpan pilihan kaca cair', (tester) async {
    await tester.pumpWidget(buatApp(gps: _gps, offline: true));
    await tester.pumpAndSettle();
    await tester.tap(navTab('pengaturan'));
    await tester.pumpAndSettle();

    final sakelar = find.byKey(const ValueKey('pengaturan.kacaCair'));
    expect(tester.widget<SwitchListTile>(sakelar).value, isTrue);
    await tester.tap(sakelar);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(sakelar).value, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('kaca_cair'), 'tidak');
    final baru = PengaturanProvider(PreferencesService());
    await baru.muat();
    expect(baru.kacaCair, isFalse);
  });

  testWidgets('lensa kaca diam di tab aktif ikut pindah saat tab berganti', (
    tester,
  ) async {
    await tester.pumpWidget(buatApp(gps: _gps, offline: true));
    await tester.pumpAndSettle();
    Finder lensa() => find.descendant(
      of: find.byType(AnimatedPositioned),
      matching: find.byType(GlassContainer),
    );
    final awal = tester.getCenter(lensa()).dx;
    expect(awal, closeTo(tester.getCenter(navTab('beranda')).dx, 2));

    await tester.tap(navTab('gempa'));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(lensa()).dx,
      closeTo(tester.getCenter(navTab('gempa')).dx, 2),
    );
  });
}
