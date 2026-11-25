import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/ringkas_harian.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/widgets/deret_cuaca.dart';
import 'package:app/widgets/ikon_cuaca.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.17, lon: 106.82);

Widget _uji(Widget anak) => MaterialApp(
  home: Scaffold(body: Center(child: anak)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Ringkasan harian dari prakiraan 3-jam BMKG', () {
    final p = Prakiraan.fromJson(fixture('prakiraan_31.71.01.1001.json'));

    test('satu ringkasan per hari, tertinggi >= terendah, wakil dekat '
        'pukul 12', () {
      final h = ringkasHarian(p);
      expect(h, hasLength(p.hari.length));
      for (final (i, r) in h.indexed) {
        final semua = p.hari[i].map((e) => e.suhu).whereType<double>();
        expect(r.tertinggi, semua.reduce((a, b) => a > b ? a : b));
        expect(r.terendah, semua.reduce((a, b) => a < b ? a : b));
        expect(r.tertinggi! >= r.terendah!, isTrue);
        final jamWakil = r.wakil.waktuLokal!.hour;
        for (final e in p.hari[i]) {
          final j = e.waktuLokal!.hour;
          expect((jamWakil - 12).abs() <= (j - 12).abs(), isTrue);
        }
      }
    });
  });

  group('Ikon cuaca berwarna', () {
    testWidgets('tanpa warna: matahari kuning (isi); dengan warna: duotone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _uji(const IkonCuaca(deskripsi: 'Cerah', size: 48)),
      );
      final matahari = tester.widget<Icon>(find.byIcon(IkonApp.isiMatahari));
      expect(matahari.color, const Color(0xFFFFC533));

      await tester.pumpWidget(
        _uji(const IkonCuaca(deskripsi: 'Cerah Berawan', size: 48)),
      );
      expect(find.byIcon(IkonApp.isiMatahari), findsOneWidget);
      expect(find.byIcon(IkonApp.isiAwan), findsOneWidget);

      await tester.pumpWidget(
        _uji(const IkonCuaca(deskripsi: 'Cerah', malam: true, size: 48)),
      );
      expect(find.byIcon(IkonApp.isiBulan), findsOneWidget);

      await tester.pumpWidget(
        _uji(const IkonCuaca(deskripsi: 'Hujan Ringan', size: 48)),
      );
      expect(find.byIcon(IkonApp.isiAwanHujan), findsOneWidget);

      await tester.pumpWidget(
        _uji(
          const IkonCuaca(deskripsi: 'Cerah', size: 24, warna: Colors.white),
        ),
      );
      expect(find.byIcon(IkonApp.isiMatahari), findsNothing);
      expect(find.byType(IkonDuo), findsOneWidget);
    });
  });

  for (final tema in [PilihanTema.terang, PilihanTema.gelap]) {
    testWidgets('Beranda & Cuaca Langit Kaca, 360 dp + huruf 1,3x '
        '(${tema.name})', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        buatApp(
          gps: _gps,
          pengaturan: PengaturanProvider(
            PreferencesService(),
            bahasa: PilihanBahasa.indonesia,
            tema: tema,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Beranda: deret per jam dimulai "Sekarang", ringkasan detail.
      expect(find.byType(DeretPerJam), findsOneWidget);
      expect(find.text(l.sekarang), findsOneWidget);
      expect(find.byType(RingkasDetail), findsOneWidget);
      expect(find.text(l.kelembapan), findsOneWidget);

      // Cuaca: prakiraan harian dengan label hari.
      await tester.tap(navTab('cuaca'));
      await tester.pumpAndSettle();
      final harian = find.byType(DaftarHarian);
      await tester.scrollUntilVisible(
        harian,
        200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(harian, findsOneWidget);
      // Satu baris (ikon siang) per hari prakiraan.
      final hari = Prakiraan.fromJson(
        fixture('prakiraan_31.71.01.1001.json'),
      ).hari.length;
      expect(
        find.descendant(of: harian, matching: find.byType(IkonCuaca)),
        findsNWidgets(hari),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
