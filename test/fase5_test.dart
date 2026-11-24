import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/exceptions.dart';
import 'package:app/core/format.dart';
import 'package:app/core/l10n.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/gempa_provider.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/providers/weather_provider.dart';
import 'package:app/services/bmkg_repository.dart';
import 'package:app/services/cache_service.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';

import 'helpers.dart';

const _gpsJakarta = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('CacheService', () {
    test('simpan lalu baca, dengan waktu pengambilan', () async {
      final cache = CacheService();
      final waktu = DateTime.utc(2026, 11, 13, 7, 0);
      await cache.simpan('uji', {'a': 1}, diambil: waktu);

      final entri = await cache.baca('uji');
      expect(entri!.json, {'a': 1});
      expect(entri.diambil, waktu);
      expect(await cache.baca('tidak-ada'), isNull);
    });

    test('isi rusak dianggap tidak ada', () async {
      SharedPreferences.setMockInitialValues({
        'cache.rusak': 'bukan json',
        'cache.salah': '{"json": [1], "diambil": "x"}',
      });
      final cache = CacheService();
      expect(await cache.baca('rusak'), isNull);
      expect(await cache.baca('salah'), isNull);
    });

    test(
      'pangkas hanya menyisakan prakiraan wilayah yang dipertahankan',
      () async {
        final cache = CacheService();
        for (final kode in ['A', 'B', 'C']) {
          await cache.simpan(CacheService.kunciPrakiraan(kode), {'k': kode});
        }
        await cache.simpan(CacheService.kunciGempaTerkini, {'g': 1});

        await cache.pangkasPrakiraan({'A', 'C'});

        expect(await cache.baca(CacheService.kunciPrakiraan('A')), isNotNull);
        expect(await cache.baca(CacheService.kunciPrakiraan('B')), isNull);
        expect(await cache.baca(CacheService.kunciPrakiraan('C')), isNotNull);
        // Cache gempa tidak ikut dipangkas.
        expect(await cache.baca(CacheService.kunciGempaTerkini), isNotNull);
      },
    );
  });

  group('BmkgRepository: jaringan dulu, cache bila gagal', () {
    test('online: data baru disimpan ke cache', () async {
      final api = FakeApi();
      final repo = BmkgRepository(api, CacheService());

      final hasil = await repo.gempaTerkini();

      expect(hasil.dariCache, isFalse);
      expect(hasil.data, hasLength(15));
      expect(
        await CacheService().baca(CacheService.kunciGempaTerkini),
        isNotNull,
      );
    });

    test('offline dengan cache: data lama + waktu pengambilannya', () async {
      final api = FakeApi();
      final repo = BmkgRepository(api, CacheService());
      final pertama = await repo.prakiraan('31.71.01.1001');
      api.offline = true;

      final kedua = await repo.prakiraan('31.71.01.1001');

      expect(kedua.dariCache, isTrue);
      expect(kedua.data.lokasi.desa, 'Gambir');
      expect(
        kedua.diperbarui.toUtc(),
        pertama.diperbarui
            .toUtc()
            .subtract(Duration(microseconds: pertama.diperbarui.microsecond))
            .add(Duration(microseconds: pertama.diperbarui.microsecond)),
      );
    });

    test('offline tanpa cache: error jaringan diteruskan', () async {
      final repo = BmkgRepository(FakeApi(offline: true), CacheService());
      expect(
        repo.gempaDirasakan(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.noInternet,
          ),
        ),
      );
    });

    test('cache rusak saat offline: error jaringan diteruskan', () async {
      await CacheService().simpan(CacheService.kunciGempaTerbaru, {
        'bukan': 'gempa',
      });
      final repo = BmkgRepository(FakeApi(offline: true), CacheService());
      expect(repo.gempaTerbaru(), throwsA(isA<ApiException>()));
    });

    test('prakiraan wilayah lain (bukan aktif/favorit) dipangkas', () async {
      final cache = CacheService();
      await cache.simpan(CacheService.kunciPrakiraan('99.99.99.9999'), {
        'lama': true,
      });
      final repo = BmkgRepository(FakeApi(), cache);

      await repo.prakiraan('31.71.01.1001', dipertahankan: {'35.07.10.2001'});

      expect(
        await cache.baca(CacheService.kunciPrakiraan('99.99.99.9999')),
        isNull,
      );
      expect(
        await cache.baca(CacheService.kunciPrakiraan('31.71.01.1001')),
        isNotNull,
      );
    });
  });

  testWidgets('mode pesawat setelah data dimuat: data lama + banner offline', (
    tester,
  ) async {
    final api = FakeApi();
    await tester.pumpWidget(buatApp(gps: _gpsJakarta, api: api));
    await tester.pumpAndSettle();
    expect(find.text(l.cuacaSaatIni), findsOneWidget);
    expect(find.text(l.modeOffline), findsNothing);

    api.offline = true;
    final konteks = tester.element(find.text(l.cuacaSaatIni));
    final cuacaP = Provider.of<WeatherProvider>(konteks, listen: false);
    final gempaP = Provider.of<GempaProvider>(konteks, listen: false);
    await Future.wait([cuacaP.muatUlang(), gempaP.muatTerbaru()]);
    await tester.pumpAndSettle();

    // Data tetap tampil, dengan banner dan label waktu.
    expect(find.text(l.cuacaSaatIni), findsOneWidget);
    expect(find.textContaining(l.modeOffline), findsOneWidget);
    // Kartu gempa ada di bawah layar uji; cek lewat provider.
    final gempa = gempaP.terbaru;
    expect(gempa.dariCache, isTrue);
    expect(gempa.data?.magnitudo, '4.1');
    expect(find.textContaining('Diperbarui:'), findsWidgets);
    expect(find.text(l.errTidakAdaInternet), findsNothing);
  });

  group('Bahasa dan tema', () {
    testWidgets('ikuti sistem: bahasa tak didukung jatuh ke Indonesia', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = [const Locale('fr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(
        buatApp(
          gps: const HasilGps(StatusGps.ditolak),
          pengaturan: PengaturanProvider(PreferencesService()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l.navBeranda), findsWidgets);
      expect(find.text(en.navBeranda), findsNothing);
    });

    testWidgets('ganti ke English mengubah teks tanpa restart dan tersimpan', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: _gpsJakarta));
      await tester.pumpAndSettle();
      expect(find.text('Beranda'), findsWidgets);

      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.tentangBahasa));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.bahasaInggris).last);
      await tester.pumpAndSettle();

      // Tab, judul, dan halaman Tentang berganti bahasa.
      expect(find.text(en.navPengaturan), findsWidgets);
      expect(find.text(en.navBeranda), findsOneWidget);
      expect(find.text(en.tentangBahasa), findsOneWidget);
      expect(find.text('Beranda'), findsNothing);

      // Format waktu ikut bahasa: kartu Beranda memakai bentuk Inggris.
      await tester.tap(navTab('beranda'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ago'), findsWidgets);
      expect(find.text(en.cuacaSaatIni), findsOneWidget);
      expect(find.textContaining('km from you'), findsWidgets);

      final dibukaLagi = PengaturanProvider(PreferencesService());
      await dibukaLagi.muat();
      expect(dibukaLagi.bahasa, PilihanBahasa.inggris);
    });

    testWidgets('tema gelap diterapkan dan tersimpan', (tester) async {
      await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
      await tester.pumpAndSettle();

      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.tentangTema));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.temaGelap).last);
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(find.text(l.temaGelap), findsOneWidget);

      final dibukaLagi = PengaturanProvider(PreferencesService());
      await dibukaLagi.muat();
      expect(dibukaLagi.tema, PilihanTema.gelap);
    });

    test('pilihan rusak di penyimpanan kembali ke bawaan', () async {
      SharedPreferences.setMockInitialValues({'bahasa': 'klingon', 'tema': 7});
      final p = PengaturanProvider(PreferencesService());
      await p.muat();
      expect(p.bahasa, PilihanBahasa.sistem);
      expect(p.tema, PilihanTema.sistem);
    });
  });

  group('Format dua bahasa', () {
    test('waktu relatif dan jarak', () {
      final now = DateTime.utc(2026, 11, 13, 12);
      expect(
        Format.waktuRelatif(en, now.subtract(const Duration(minutes: 1)), now),
        '1 minute ago',
      );
      expect(
        Format.waktuRelatif(en, now.subtract(const Duration(hours: 5)), now),
        '5 hours ago',
      );
      expect(
        Format.waktuRelatif(l, now.subtract(const Duration(hours: 5)), now),
        '5 jam lalu',
      );
      expect(Format.jarak(en, 1117.3), '1,117');
      expect(Format.jarak(l, 1117.3), '1.117');
      expect(Format.desimal(en, 5.5), '5.5');
      expect(Format.desimal(l, 5.5), '5,5');
      expect(Format.angin(en, 5.4, 'NE'), '5.4 km/h from the northeast');
      expect(Format.angin(l, 5.4, 'NE'), '5,4 km/j dari Timur Laut');
    });

    testWidgets('tanggal lengkap mengikuti bahasa', (tester) async {
      // Data simbol tanggal intl dimuat lewat delegate lokalisasi Flutter.
      await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
      await tester.pumpAndSettle();
      final w = DateTime.utc(2026, 11, 13, 7, 31, 39);
      expect(Format.waktuLengkap(l, w), startsWith('Jumat, 13 Nov 2026'));
      expect(Format.waktuLengkap(en, w), startsWith('Friday, 13 Nov 2026'));
    });

    test('deskripsi cuaca: weather_desc_en, lalu cadangan, lalu asli', () {
      EntriPrakiraan entri(String id, String en) =>
          EntriPrakiraan.fromJson({'weather_desc': id, 'weather_desc_en': en});
      expect(
        en.deskripsiCuaca(entri('Berawan', 'Mostly Cloudy')),
        'Mostly Cloudy',
      );
      expect(en.deskripsiCuaca(entri('Hujan Lebat', '')), 'Heavy Rain');
      expect(en.deskripsiCuaca(entri('Hujan Es', '')), 'Hujan Es');
      expect(l.deskripsiCuaca(entri('Berawan', 'Mostly Cloudy')), 'Berawan');
    });
  });

  for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
    testWidgets(
      'skala huruf 1.3x dan layar sempit tanpa overflow (${bahasa.name})',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75; // ±393 x 873 dp, seperti Pixel 7
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          buatApp(
            gps: _gpsJakarta,
            pengaturan: PengaturanProvider(
              PreferencesService(),
              bahasa: bahasa,
              tema: PilihanTema.gelap,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Kunjungi semua tab dan sub-tab; overflow akan menggagalkan test.
        for (final tab in ['cuaca', 'gempa', 'pengaturan', 'beranda']) {
          await tester.tap(navTab(tab));
          await tester.pumpAndSettle();
        }
        await bukaPeringatan(tester);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(navTab('gempa'));
        await tester.pumpAndSettle();
        final t = lookupAppLocalizations(bahasa.locale!);
        for (final tab in [t.gempaTabTerkini, t.gempaTabDirasakan]) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
