import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/screens/onboarding_screen.dart';
import 'package:app/screens/siaga_gempa_screen.dart';
import 'package:app/services/gps_service.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

/// Apakah [w] memuat potongan teks berfont monospasi dengan isi [teks].
bool _punyaKode(RichText w, String teks) {
  var ada = false;
  w.text.visitChildren((span) {
    if (span is TextSpan &&
        span.text == teks &&
        span.style?.fontFamily == 'monospace') {
      ada = true;
    }
    return true;
  });
  return ada;
}

bool _punyaMiring(RichText w, String teks) {
  var ada = false;
  w.text.visitChildren((span) {
    if (span is TextSpan &&
        span.text == teks &&
        span.style?.fontStyle == FontStyle.italic) {
      ada = true;
    }
    return true;
  });
  return ada;
}

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

  testWidgets('susunan atas: pengantar, Preferensi aplikasi dengan lencana '
      '"Lokal", ubin Tema dan Bahasa berdampingan', (tester) async {
    await bukaPengaturan(tester);
    expect(find.text(l.pengaturanIntro), findsOneWidget);
    expect(find.text(l.pengaturanPreferensi.toUpperCase()), findsOneWidget);
    expect(find.text(l.pengaturanLokal), findsOneWidget);

    final tema = tester.getTopLeft(find.text(l.tentangTema));
    final bahasa = tester.getTopLeft(find.text(l.tentangBahasa));
    // Sebaris (ubin setengah lebar), Bahasa di kanan Tema.
    expect(bahasa.dy, tema.dy);
    expect(bahasa.dx, greaterThan(tema.dx + 100));
    // Nilai terpilih tampil besar di dalam ubin.
    expect(find.text(l.ikutiSistem), findsOneWidget); // tema
    expect(find.text(l.bahasaIndonesia), findsOneWidget); // bahasa
    // Tema masih "Ikuti sistem" (tanpa lencana), bahasa dipilih eksplisit
    // Indonesia oleh tes, jadi satu lencana "Aktif" di ubin Bahasa.
    expect(find.text(l.pengaturanAktif), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('memilih tema Terang menampilkan lencana Aktif di ubin Tema', (
    tester,
  ) async {
    await bukaPengaturan(tester);
    await tester.tap(find.text(l.tentangTema));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.temaTerang).last);
    await tester.pumpAndSettle();
    // Kini tema dan bahasa sama-sama dipilih eksplisit.
    expect(find.text(l.pengaturanAktif), findsNWidgets(2));
    expect(find.text(l.temaTerang), findsOneWidget);
  });

  testWidgets('kartu Peringatan cepat: label, judul, dan ambang dalam '
      'lencana', (tester) async {
    await bukaPengaturan(tester);
    expect(
      find.text(l.pengaturanPeringatanCepat.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(l.notifJudul), findsOneWidget);
    // Tanpa Firebase di tes: kartu redup dengan alasan, lencana "Mati".
    expect(find.text(l.notifBelumAktif), findsOneWidget);
    expect(find.text(l.notifMati), findsOneWidget);
  });

  testWidgets('Tampilan & tata letak: Efek kaca cair berlencana iOS Glass, '
      'Urutan Beranda', (tester) async {
    await bukaPengaturan(tester);
    await gulirKeTengah(tester, find.text(l.kacaCairJudul));
    expect(find.text(l.pengaturanTampilan.toUpperCase()), findsOneWidget);
    expect(find.text(l.kacaCairLencana), findsOneWidget);
    expect(find.text(l.urutanBerandaJudul), findsOneWidget);
  });

  testWidgets('Tentang SiCuaca: enam baris, kalimat bukan-resmi dimiringkan, '
      'nama repositori monospasi', (tester) async {
    await bukaPengaturan(tester);
    await gulirKeTengah(tester, find.text(l.tentangJudul.toUpperCase()));
    expect(find.text(l.tentangJudul.toUpperCase()), findsOneWidget);
    await gulirKeTengah(tester, find.text(l.tentangVersi));
    for (final judul in [
      l.layananJudul,
      l.appName,
      l.lisensiDataWilayah,
      l.panduanAplikasi,
      l.lisensiSumberTerbuka,
      l.tentangVersi,
    ]) {
      expect(find.text(judul), findsWidgets, reason: judul);
    }
    expect(find.text(l.versiTerpasang), findsOneWidget);

    final sumber = find.byWidgetPredicate(
      (w) =>
          w is RichText &&
          w.text.toPlainText().contains(l.tentangSumber.split('.').first),
    );
    expect(sumber, findsOneWidget);
    expect(_punyaMiring(tester.widget<RichText>(sumber), l.bukanResmi), isTrue);

    await gulirKeTengah(tester, find.text(l.lisensiDataWilayah));
    final wilayah = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains('cahyadsn/wilayah'),
    );
    expect(wilayah, findsOneWidget);
    expect(
      _punyaKode(tester.widget<RichText>(wilayah), 'cahyadsn/wilayah'),
      isTrue,
    );
  });

  testWidgets('dua tombol kaca di kanan atas: Siaga gempa dan Panduan', (
    tester,
  ) async {
    await bukaPengaturan(tester);
    final siaga = find.byTooltip(l.siagaJudul);
    final panduan = find.byTooltip(l.panduanAplikasi);
    expect(siaga, findsWidgets);
    expect(panduan, findsWidgets);

    await tester.tap(panduan.first);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(OnboardingScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(l.siagaJudul).first);
    await tester.pumpAndSettle();
    expect(find.byType(SiagaGempaScreen), findsOneWidget);
  });

  testWidgets('huruf besar 1,3x di 360 dp: seluruh layar tanpa overflow', (
    tester,
  ) async {
    await bukaPengaturan(tester, skala: 1.3);
    expect(tester.takeException(), isNull);
    final daftar = find.byType(ListView).last;
    for (var i = 0; i < 9; i++) {
      await tester.drag(daftar, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
