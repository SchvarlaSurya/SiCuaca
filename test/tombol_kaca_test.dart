import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/l10n.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/cuaca_screen.dart';
import 'package:app/screens/perbandingan_cuaca_screen.dart';
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

  testWidgets('tombol atas tab Gempa: tombol kaca 44 px, maks. 3 per baris', (
    tester,
  ) async {
    await tester.pumpWidget(buatApp(gps: _gps, offline: true));
    await tester.pumpAndSettle();
    await tester.tap(navTab('gempa'));
    await tester.pumpAndSettle();

    for (final nama in [l.navPeringatan, l.riwayatJudul]) {
      final tombol = find.ancestor(
        of: find.byTooltip(nama),
        matching: find.byType(TombolKaca),
      );
      expect(tombol, findsOneWidget);
    }
    // Siap Siaga tidak lagi di atas (sudah ada kartu di halaman).
    expect(find.byTooltip(l.siagaJudul), findsNothing);
    expect(
      tester.getSize(find.byType(GlassIconButton).first).width,
      TombolKaca.ukuran,
    );

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

  testWidgets('Cuaca: 3 tombol (favorit, cari, Lainnya); bandingkan, bagikan, '
      'dan lokasi ada di menu Lainnya', (tester) async {
    await tester.pumpWidget(buatApp(gps: _gps));
    await tester.pumpAndSettle();
    await tester.tap(navTab('cuaca'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GrupTombolKaca).first,
        matching: find.byType(TombolKaca),
      ),
      findsNWidgets(TombolKaca.maksPerBaris),
    );
    expect(find.byTooltip(l.bandingkanFavorit), findsNothing);

    await tester.tap(find.byTooltip(l.lainnya));
    await tester.pumpAndSettle();
    expect(find.text(l.bandingkanFavorit), findsOneWidget);
    expect(find.text(l.bagikanCuaca), findsOneWidget);
    expect(find.text(l.gunakanLokasiSaya), findsOneWidget);

    await tester.tap(find.text(l.bandingkanFavorit));
    await tester.pumpAndSettle();
    expect(find.byType(PerbandinganCuacaScreen), findsOneWidget);
  });

  group('Grup tombol kaca membelah seperti jeli', () {
    // Jarak antara tombol baru (Favorit, paling kiri) dan tombol terdekat
    // yang sudah ada (Cari wilayah).
    Finder diGrupCuaca(String nama) => find.descendant(
      of: find.descendant(
        of: find.byType(CuacaScreen),
        matching: find.byType(GrupTombolKaca),
      ),
      matching: find.byTooltip(nama),
    );
    double jarak(WidgetTester tester) =>
        tester.getCenter(diGrupCuaca(l.cariWilayah)).dx -
        tester.getCenter(diGrupCuaca(l.tambahFavorit)).dx;

    testWidgets('Beranda (2 tombol) ke Cuaca (3 tombol): tombol baru keluar '
        'dari tombol terdekat lalu meluncur ke tempatnya', (tester) async {
      await tester.pumpWidget(buatApp(gps: _gps));
      await tester.pumpAndSettle();
      expect(GrupTombolKaca.jumlahTerakhir, 2);

      await tester.tap(navTab('cuaca'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final tengah = jarak(tester);

      await tester.pumpAndSettle();
      final akhir = jarak(tester);
      expect(akhir, closeTo(TombolKaca.lebarSlot, 0.5));
      // Di tengah animasi tombol baru masih menempel di tetangganya.
      expect(tengah, lessThan(akhir - 8));
      expect(GrupTombolKaca.jumlahTerakhir, 3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('efek kaca cair dimatikan: tombol langsung di tempat dan '
        'kaca tanpa shader', (tester) async {
      final pengaturan = PengaturanProvider(
        PreferencesService(),
        bahasa: PilihanBahasa.indonesia,
      );
      await pengaturan.aturKacaCair(false);
      await tester.pumpWidget(buatApp(gps: _gps, pengaturan: pengaturan));
      await tester.pumpAndSettle();
      await tester.tap(navTab('cuaca'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(jarak(tester), closeTo(TombolKaca.lebarSlot, 0.5));

      final tema = tester.widget<GlassTheme>(find.byType(GlassTheme).first);
      expect(tema.data.light, GlassThemeVariant.minimalLight);
      await tester.pumpAndSettle();
    });
  });

  group('Tombol ditekan seperti jeli', () {
    // Transform terluar di dalam tooltip tombol = efek jeli tekan.
    Matrix4 transformTombol(WidgetTester tester, String nama) => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byTooltip(nama),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform;

    testWidgets('ditahan mengembang, dilepas bergoyang lalu kembali', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true));
      await tester.pumpAndSettle();
      // Tombol yang tidak pindah halaman, jadi bisa diamati sampai diam.
      final tombol = find.byTooltip(l.gunakanLokasiSaya);
      final jari = await tester.startGesture(tester.getCenter(tombol));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final ditahan = transformTombol(tester, l.gunakanLokasiSaya);
      expect(ditahan.storage[0], greaterThan(1.05)); // melebar
      expect(ditahan.storage[5], greaterThan(1.03)); // meninggi

      await jari.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final goyang = transformTombol(tester, l.gunakanLokasiSaya);
      expect(goyang.storage[0], isNot(closeTo(1, 0.001)));

      await tester.pumpAndSettle();
      final diam = transformTombol(tester, l.gunakanLokasiSaya);
      expect(diam.storage[0], closeTo(1, 0.001));
      expect(diam.storage[5], closeTo(1, 0.001));
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

  group('Lensa kaca navbar', () {
    final lensa = find.byKey(const ValueKey('nav.lensa'));
    double opasitas(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find.ancestor(of: lensa, matching: find.byType(FadeTransition)).first,
        )
        .opacity
        .value;

    testWidgets('lensa diam pindah ke tab aktif', (tester) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(lensa).dx,
        closeTo(tester.getCenter(navTab('beranda')).dx, 2),
      );
      await tester.tap(navTab('gempa'));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(lensa).dx,
        closeTo(tester.getCenter(navTab('gempa')).dx, 2),
      );
      expect(opasitas(tester), 1);
    });

    testWidgets('ketuk cepat: lensa diam tersembunyi selama gelembung jeli '
        'meluncur, baru muncul setelah gelembung tiba', (tester) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true));
      await tester.pumpAndSettle();
      await tester.tap(navTab('pengaturan'));
      for (final ms in [50, 200, 400]) {
        await tester.pump(Duration(milliseconds: ms == 50 ? 50 : 150));
        expect(opasitas(tester), 0, reason: 'masih meluncur ($ms ms)');
      }
      await tester.pumpAndSettle();
      expect(opasitas(tester), 1);
    });
  });
}
