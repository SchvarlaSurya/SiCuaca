import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/detektor_lag.dart';
import 'package:app/core/navigasi.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/widgets/pantau_lag_kaca.dart';

import 'helpers.dart';

const _mulus = Duration(milliseconds: 8);
const _lag = Duration(milliseconds: 60);

/// Mengirim [n] frame berdurasi [lama] ke detektor; true bila ada yang memicu.
bool _kirim(DetektorLag d, int n, Duration lama) {
  var picu = false;
  for (var i = 0; i < n; i++) {
    picu = d.catat(lama) || picu;
  }
  return picu;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DetektorLag', () {
    test('aplikasi mulus tidak pernah memicu', () {
      final d = DetektorLag();
      expect(_kirim(d, 600, _mulus), isFalse);
    });

    test('satu jendela buruk saja belum memicu; dua berturut-turut memicu', () {
      final d = DetektorLag();
      expect(_kirim(d, 60, _lag), isFalse);
      expect(_kirim(d, 60, _lag), isTrue);
    });

    test('jendela mulus di tengah mengulang hitungan', () {
      final d = DetektorLag();
      expect(_kirim(d, 60, _lag), isFalse);
      expect(_kirim(d, 60, _mulus), isFalse);
      expect(_kirim(d, 60, _lag), isFalse, reason: 'hitungan mulai dari nol');
      expect(_kirim(d, 60, _lag), isTrue);
    });

    test('lonjakan sesaat (beberapa frame) tidak dianggap lag', () {
      final d = DetektorLag();
      for (var jendela = 0; jendela < 5; jendela++) {
        // 5 dari 60 frame lambat = 8 %, di bawah ambang 30 %.
        expect(_kirim(d, 5, _lag), isFalse);
        expect(_kirim(d, 55, _mulus), isFalse);
      }
    });

    test('ambang tepat 30 % dihitung buruk, 29 % tidak', () {
      final d = DetektorLag();
      expect(_kirim(d, 17, _lag) || _kirim(d, 43, _mulus), isFalse);
      expect(_kirim(d, 18, _lag) || _kirim(d, 42, _mulus), isFalse);
      // Jendela pertama 17/60 = 28 % (baik), kedua 18/60 = 30 % (buruk):
      // hanya satu buruk, belum memicu. Jendela buruk lagi memicu.
      expect(_kirim(d, 18, _lag) || _kirim(d, 42, _mulus), isTrue);
    });

    test('setelah memicu, hitungan mulai dari nol; ulang() membersihkan', () {
      final d = DetektorLag();
      _kirim(d, 120, _lag);
      expect(_kirim(d, 60, _lag), isFalse);
      d.ulang();
      expect(_kirim(d, 60, _lag), isFalse);
      expect(_kirim(d, 60, _lag), isTrue);
    });
  });

  group('PantauLagKaca', () {
    late StreamController<Duration> frame;
    late PengaturanProvider pengaturan;

    setUp(() async {
      frame = StreamController<Duration>.broadcast();
      pengaturan = PengaturanProvider(
        PreferencesService(),
        bahasa: PilihanBahasa.indonesia,
      );
      await pengaturan.aturKacaCair(true);
    });
    tearDown(() => frame.close());

    Future<void> pasang(
      WidgetTester tester, {
      Duration jedaAwal = Duration.zero,
    }) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PengaturanProvider>.value(
          value: pengaturan,
          child: MaterialApp(
            navigatorKey: Navigasi.navigatorKey,
            locale: const Locale('id'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, anak) => PantauLagKaca(
              aktif: true,
              jedaAwal: jedaAwal,
              sumberFrame: frame.stream,
              child: anak!,
            ),
            home: const Scaffold(body: Text('beranda')),
          ),
        ),
      );
    }

    Future<void> kirimLag(WidgetTester tester, int jumlah) async {
      for (var i = 0; i < jumlah; i++) {
        frame.add(_lag);
      }
      await tester.pump();
    }

    testWidgets('lag terus-menerus memunculkan tawaran; "Matikan" mematikan '
        'kaca dan tidak ditanya lagi', (tester) async {
      await pasang(tester);
      await kirimLag(tester, 120);

      expect(find.text(l.kacaLagJudul), findsOneWidget);
      expect(find.text(l.kacaLagIsi), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('kacaLag.matikan')));
      await tester.pumpAndSettle();

      expect(find.text(l.kacaLagJudul), findsNothing);
      expect(pengaturan.kacaCair, isFalse);
      expect(pengaturan.tawaranKacaDijawab, isTrue);

      // Kaca sudah mati: lag berikutnya tidak memunculkan apa pun.
      await kirimLag(tester, 240);
      expect(find.text(l.kacaLagJudul), findsNothing);
    });

    testWidgets('"Tetap nyalakan" membiarkan kaca menyala dan tidak ditanya '
        'lagi', (tester) async {
      await pasang(tester);
      await kirimLag(tester, 120);
      expect(find.text(l.kacaLagJudul), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('kacaLag.tetap')));
      await tester.pumpAndSettle();

      expect(pengaturan.kacaCair, isTrue);
      expect(pengaturan.tawaranKacaDijawab, isTrue);

      await kirimLag(tester, 240);
      expect(find.text(l.kacaLagJudul), findsNothing);
    });

    testWidgets('jawaban tersimpan: aplikasi dibuka lagi tidak bertanya', (
      tester,
    ) async {
      await pasang(tester);
      await kirimLag(tester, 120);
      await tester.tap(find.byKey(const ValueKey('kacaLag.tetap')));
      await tester.pumpAndSettle();

      final baru = PengaturanProvider(PreferencesService());
      await baru.muat();
      expect(baru.tawaranKacaDijawab, isTrue);
    });

    testWidgets('frame mulus tidak memunculkan tawaran', (tester) async {
      await pasang(tester);
      for (var i = 0; i < 600; i++) {
        frame.add(_mulus);
      }
      await tester.pump();
      expect(find.text(l.kacaLagJudul), findsNothing);
      expect(pengaturan.kacaCair, isTrue);
    });

    testWidgets('frame di masa jeda awal diabaikan', (tester) async {
      await pasang(tester, jedaAwal: const Duration(hours: 1));
      await kirimLag(tester, 600);
      expect(find.text(l.kacaLagJudul), findsNothing);
    });

    testWidgets('kaca sudah mati: lag tidak memunculkan tawaran', (
      tester,
    ) async {
      await pengaturan.aturKacaCair(false);
      await pasang(tester);
      await kirimLag(tester, 600);
      expect(find.text(l.kacaLagJudul), findsNothing);
    });

    testWidgets('aktif: false tidak memantau (build debug)', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PengaturanProvider>.value(
          value: pengaturan,
          child: MaterialApp(
            navigatorKey: Navigasi.navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, anak) => PantauLagKaca(
              aktif: false,
              jedaAwal: Duration.zero,
              sumberFrame: frame.stream,
              child: anak!,
            ),
            home: const Scaffold(body: Text('beranda')),
          ),
        ),
      );
      await kirimLag(tester, 600);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
