import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/format.dart';
import 'package:app/core/l10n.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/main_shell.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/core/logo_sicuaca.dart';
import 'package:app/widgets/angka_berhitung.dart';
import 'package:app/widgets/pencet_lembut.dart';
import 'package:app/widgets/splash_gerbang.dart';
import 'package:app/widgets/transisi_tab.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);
final l = lookupAppLocalizations(const Locale('id'));

Widget _bungkus(Widget anak, {bool tanpaGerak = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: tanpaGerak),
    child: Scaffold(body: anak),
  ),
);

/// Tab uji yang menyimpan state (hitungan ketukan) untuk membuktikan state
/// tidak hilang saat berpindah tab.
class _Hitung extends StatefulWidget {
  const _Hitung(this.nama);

  final String nama;

  @override
  State<_Hitung> createState() => _HitungState();
}

class _HitungState extends State<_Hitung> {
  int n = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => n++),
      child: Text('${widget.nama}:$n'),
    ),
  );
}

/// Memajukan waktu dalam langkah kecil (16 ms). Jam splash membatasi lompatan
/// waktu per frame, jadi satu pump besar tidak memajukan animasinya.
Future<void> _pompa(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 16; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('TransisiTab', () {
    Widget susun(int indeks, {bool tanpaGerak = false}) => _bungkus(
      TransisiTab(
        indeks: indeks,
        anak: const [_Hitung('A'), _Hitung('B'), _Hitung('C')],
      ),
      tanpaGerak: tanpaGerak,
    );

    testWidgets('transisi berurutan: tab lama habis memudar sebelum tab baru '
        'tampak, setelah selesai hanya tab baru', (tester) async {
      await tester.pumpWidget(susun(0));
      expect(find.text('A:0'), findsOneWidget);
      expect(find.text('B:0'), findsNothing);

      double opasitas(String teks) {
        final f = find.ancestor(
          of: find.text(teks),
          matching: find.byType(FadeTransition),
        );
        return tester.widget<FadeTransition>(f.first).opacity.value;
      }

      await tester.pumpWidget(susun(1));
      await tester.pump(const Duration(milliseconds: 60));
      // Paruh awal: lama masih ada tapi memudar, baru belum tampak.
      expect(find.text('A:0'), findsOneWidget);
      expect(find.text('B:0'), findsOneWidget);
      expect(opasitas('A:0'), lessThan(1));
      expect(opasitas('B:0'), 0);

      await tester.pump(const Duration(milliseconds: 150));
      // Paruh akhir: lama sudah hilang, baru memudar masuk.
      expect(opasitas('A:0'), 0);
      expect(opasitas('B:0'), greaterThan(0));

      await tester.pumpAndSettle();
      expect(find.text('A:0'), findsNothing);
      expect(find.text('B:0'), findsOneWidget);
    });

    testWidgets('state tab bertahan saat pindah bolak-balik', (tester) async {
      await tester.pumpWidget(susun(0));
      await tester.tap(find.text('A:0'));
      await tester.pump();
      await tester.tap(find.text('A:1'));
      await tester.pump();
      expect(find.text('A:2'), findsOneWidget);

      await tester.pumpWidget(susun(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B:0'));
      await tester.pump();

      await tester.pumpWidget(susun(0));
      await tester.pumpAndSettle();
      expect(find.text('A:2'), findsOneWidget);
      expect(find.text('B:1'), findsNothing);

      await tester.pumpWidget(susun(1));
      await tester.pumpAndSettle();
      expect(find.text('B:1'), findsOneWidget);
    });

    testWidgets('kurangi gerakan: pindah langsung tanpa tab ganda', (
      tester,
    ) async {
      await tester.pumpWidget(susun(0, tanpaGerak: true));
      await tester.pumpWidget(susun(2, tanpaGerak: true));
      await tester.pump();
      expect(find.text('A:0'), findsNothing);
      expect(find.text('C:0'), findsOneWidget);
    });

    testWidgets('tab lama tidak menerima ketukan selama transisi', (
      tester,
    ) async {
      await tester.pumpWidget(susun(0));
      await tester.pumpWidget(susun(1));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.text('A:0'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.pumpWidget(susun(0));
      await tester.pumpAndSettle();
      expect(find.text('A:0'), findsOneWidget);
    });
  });

  group('Pindah tab di aplikasi', () {
    testWidgets('navbar berpindah tab dengan transisi dan hasilnya benar', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true));
      await tester.pumpAndSettle();
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(TransisiTab), findsOneWidget);

      await tester.tap(navTab('pengaturan'));
      await tester.pump(const Duration(milliseconds: 120));
      // Di tengah transisi dua tab ada di pohon tampil.
      await tester.pumpAndSettle();
      expect(find.text(l.navPengaturan), findsWidgets);

      await tester.tap(navTab('beranda'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('PencetLembut', () {
    testWidgets('mengecil saat ditekan, kembali saat dilepas, ketukan tetap '
        'sampai ke tombol', (tester) async {
      var diketuk = 0;
      await tester.pumpWidget(
        _bungkus(
          Center(
            child: PencetLembut(
              child: FilledButton(
                onPressed: () => diketuk++,
                child: const Text('Tombol'),
              ),
            ),
          ),
        ),
      );
      double skala() => tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(PencetLembut),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;

      expect(skala(), 1);
      final jari = await tester.startGesture(
        tester.getCenter(find.text('Tombol')),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(skala(), lessThan(1));

      await jari.up();
      await tester.pumpAndSettle();
      expect(skala(), 1);
      expect(diketuk, 1);
    });

    testWidgets('kurangi gerakan: tidak mengecil', (tester) async {
      await tester.pumpWidget(
        _bungkus(
          Center(
            child: PencetLembut(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Tombol'),
              ),
            ),
          ),
          tanpaGerak: true,
        ),
      );
      final jari = await tester.startGesture(
        tester.getCenter(find.text('Tombol')),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      await jari.up();
    });
  });

  group('SuhuBerhitung', () {
    testWidgets('berakhir tepat di nilai akhir, mulai dari bawahnya', (
      tester,
    ) async {
      await tester.pumpWidget(_bungkus(const SuhuBerhitung(nilai: 31.4)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(Format.suhu(31.4)), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text(Format.suhu(31.4)), findsOneWidget);
    });

    testWidgets('kurangi gerakan dan suhu kosong: langsung tampil', (
      tester,
    ) async {
      await tester.pumpWidget(
        _bungkus(const SuhuBerhitung(nilai: 28), tanpaGerak: true),
      );
      expect(find.text(Format.suhu(28)), findsOneWidget);

      await tester.pumpWidget(_bungkus(const SuhuBerhitung(nilai: null)));
      expect(find.text(Format.tandaKosong), findsOneWidget);
    });
  });

  group('Splash', () {
    testWidgets('tampil lalu hilang, aplikasi di bawahnya tidak dibuat ulang', (
      tester,
    ) async {
      await tester.pumpWidget(
        buatApp(
          gps: _gps,
          offline: true,
          splash: true,
          pengaturan: PengaturanProvider(
            PreferencesService(),
            bahasa: PilihanBahasa.indonesia,
          ),
        ),
      );
      // Awal: hanya logo (sama dengan splash native), teks belum keluar.
      await _pompa(tester, 96);
      expect(find.byType(TampilanLogo), findsOneWidget);
      // Teks splash dibuka dari samping logo lewat ClipRect: lebarnya 0 di
      // awal lalu tumbuh.
      final klipTeks = find.byKey(const ValueKey('splash.teks'));
      final lebarAwal = tester.getSize(klipTeks).width;
      expect(lebarAwal, lessThan(1));
      final shell = tester.state(find.byType(MainShell));

      // Setelah teks keluar dari samping logo, tulisannya terbuka penuh dan
      // penegasan bukan resmi ikut tampil.
      await _pompa(tester, 1200);
      expect(tester.getSize(klipTeks).width, greaterThan(80));
      expect(find.text(l.bukanResmi), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(TampilanLogo), findsNothing);
      expect(find.text(l.bukanResmi), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
      expect(tester.state(find.byType(MainShell)), same(shell));
    });

    testWidgets('frame tersendat tidak menghabiskan animasi: teks tetap '
        'sempat keluar', (tester) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true, splash: true));
      // Frame pertama hanya splash; aplikasi dipasang setelahnya.
      expect(find.byType(MainShell), findsNothing);
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(MainShell), findsOneWidget);
      // Satu frame yang sangat lambat (mis. shader pertama kali): waktu yang
      // dihitung dibatasi, bukan 1,5 detik sekaligus.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byType(TampilanLogo), findsOneWidget);
      final klip = find.byKey(const ValueKey('splash.teks'));
      expect(tester.getSize(klip).width, lessThan(80));
      await _pompa(tester, 2400);
      await tester.pumpAndSettle();
      expect(find.byType(TampilanLogo), findsNothing);
    });

    testWidgets('menahan ketukan selama tampil', (tester) async {
      await tester.pumpWidget(buatApp(gps: _gps, offline: true, splash: true));
      await _pompa(tester, 304);
      await tester.tap(navTab('gempa'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      // Ketukan saat splash diabaikan: tab tetap Beranda.
      expect(find.text(l.gempaTerbaruKeterangan), findsNothing);
    });

    testWidgets('kurangi gerakan: splash dilewati', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(buatApp(gps: _gps, offline: true, splash: true));
      await tester.pump();
      expect(find.byType(TampilanLogo), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    test('warna splash dalam aplikasi sama dengan splash Android', () {
      expect(SplashGerbang.warnaAwal.toARGB32(), 0xFF0B2552);
    });
  });

  group('Onboarding bergerak', () {
    testWidgets('geser halaman memudarkan ilustrasi lalu teks halaman baru '
        'masuk', (tester) async {
      await tester.pumpWidget(
        buatApp(gps: _gps, offline: true, sudahOnboarding: false),
      );
      await tester.pumpAndSettle();
      expect(find.text(l.onboardingCuacaJudul), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text(l.onboardingGempaJudul), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('kurangi gerakan: tombol Lanjut langsung pindah halaman', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        buatApp(gps: _gps, offline: true, sudahOnboarding: false),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.onboardingLanjut));
      await tester.pump();
      await tester.pump();
      expect(find.text(l.onboardingGempaJudul), findsOneWidget);
    });
  });
}
