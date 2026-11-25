import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/constants.dart';
import 'package:app/core/exceptions.dart';
import 'package:app/core/l10n.dart';
import 'package:app/core/uv.dart';
import 'package:app/models/kualitas_udara.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/kualitas_udara_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/cache_service.dart';
import 'package:app/services/kualitas_udara_repository.dart';
import 'package:app/screens/udara_uv_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/widgets/kartu_uv_udara.dart';

import 'helpers.dart';

/// Mencatat parameter permintaan dan membalas fixture Open-Meteo.
class _ApiUdara extends ApiService {
  _ApiUdara({this.offline = false});

  bool offline;
  final permintaan = <Map<String, dynamic>?>[];
  final urlDipanggil = <String>[];

  @override
  Future<Map<String, dynamic>> ambilJson(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    urlDipanggil.add(url);
    permintaan.add(queryParameters);
    if (offline) throw ApiException.noInternet();
    return fixture('openmeteo_udara.json');
  }
}

class _Jam {
  DateTime sekarang = DateTime.utc(2026, 11, 25, 3);
  DateTime call() => sekarang;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Model', () {
    test('membaca blok current dari respons Open-Meteo', () {
      final u = KualitasUdara.fromJson(fixture('openmeteo_udara.json'));
      expect(u.usAqi, 158);
      expect(u.pm25, 42.0);
      expect(u.pm10, 42.0);
      expect(u.ozon, 86.0);
      expect(u.nitrogenDioksida, 67.3);
      expect(u.waktu, DateTime.utc(2026, 11, 25, 9));
      expect(u.kategori, KategoriAqi.tidakSehat);
    });

    test('tanpa blok current: FormatException', () {
      expect(
        () => KualitasUdara.fromJson({'latitude': 1}),
        throwsFormatException,
      );
    });

    test('batas kategori US AQI', () {
      expect(KategoriAqi.dari(null), isNull);
      expect(KategoriAqi.dari(-1), isNull);
      expect(KategoriAqi.dari(0), KategoriAqi.baik);
      expect(KategoriAqi.dari(50), KategoriAqi.baik);
      expect(KategoriAqi.dari(51), KategoriAqi.sedang);
      expect(KategoriAqi.dari(100), KategoriAqi.sedang);
      expect(KategoriAqi.dari(101), KategoriAqi.sensitif);
      expect(KategoriAqi.dari(150), KategoriAqi.sensitif);
      expect(KategoriAqi.dari(151), KategoriAqi.tidakSehat);
      expect(KategoriAqi.dari(200), KategoriAqi.tidakSehat);
      expect(KategoriAqi.dari(201), KategoriAqi.sangatTidakSehat);
      expect(KategoriAqi.dari(300), KategoriAqi.sangatTidakSehat);
      expect(KategoriAqi.dari(301), KategoriAqi.berbahaya);
    });

    test('posisi penanda skala: monoton dari 0 sampai 1', () {
      expect(posisiAqi(0), 0);
      expect(posisiAqi(25), closeTo(1 / 12, .001));
      expect(posisiAqi(50), closeTo(1 / 6, .001));
      expect(posisiAqi(158), greaterThan(posisiAqi(100)));
      expect(posisiAqi(500), 1);
      expect(posisiAqi(900), 1);
      var terakhir = -1.0;
      for (var n = 0; n <= 500; n += 25) {
        expect(posisiAqi(n), greaterThanOrEqualTo(terakhir));
        terakhir = posisiAqi(n);
      }
    });
  });

  group('Repository', () {
    test('koordinat dibulatkan ke 0,1 derajat sebelum dikirim, tanpa kunci '
        'API', () async {
      final api = _ApiUdara();
      final repo = KualitasUdaraRepository(api, CacheService());
      await repo.ambil(-7.566612, 110.816745);
      expect(api.urlDipanggil.single, ApiConstants.openMeteoUdaraUrl);
      final q = api.permintaan.single!;
      expect(q['latitude'], -7.6);
      expect(q['longitude'], 110.8);
      expect(q['current'], ApiConstants.openMeteoUdaraParameter);
      // Tidak ada kunci/token di permintaan.
      expect(
        q.keys.map((k) => k.toLowerCase()),
        isNot(anyOf(contains('apikey'), contains('token'), contains('key'))),
      );
    });

    test(
      'titik yang sama dalam TTL diambil dari cache tanpa jaringan',
      () async {
        final api = _ApiUdara();
        final jam = _Jam();
        final repo = KualitasUdaraRepository(
          api,
          CacheService(),
          jam: jam.call,
        );
        final a = await repo.ambil(-6.21, 106.88);
        expect(a.dariCache, isFalse);
        jam.sekarang = jam.sekarang.add(const Duration(minutes: 30));
        final b = await repo.ambil(
          -6.19,
          106.92,
        ); // titik yang sama setelah bulat
        expect(api.urlDipanggil, hasLength(1));
        expect(b.data.usAqi, 158);
      },
    );

    test('lewat TTL: ambil ulang', () async {
      final api = _ApiUdara();
      final jam = _Jam();
      final repo = KualitasUdaraRepository(api, CacheService(), jam: jam.call);
      await repo.ambil(-6.2, 106.9);
      jam.sekarang = jam.sekarang.add(const Duration(hours: 1, minutes: 1));
      await repo.ambil(-6.2, 106.9);
      expect(api.urlDipanggil, hasLength(2));
    });

    test('luring dengan data lama: dipakai dan ditandai dari cache', () async {
      final api = _ApiUdara();
      final jam = _Jam();
      final repo = KualitasUdaraRepository(api, CacheService(), jam: jam.call);
      await repo.ambil(-6.2, 106.9);
      api.offline = true;
      jam.sekarang = jam.sekarang.add(const Duration(hours: 5));
      final hasil = await repo.ambil(-6.2, 106.9);
      expect(hasil.dariCache, isTrue);
      expect(hasil.data.usAqi, 158);
    });

    test('luring tanpa data lama: galat diteruskan', () async {
      final repo = KualitasUdaraRepository(
        _ApiUdara(offline: true),
        CacheService(),
      );
      await expectLater(repo.ambil(-6.2, 106.9), throwsA(isA<ApiException>()));
    });

    test('hanya titik aktif yang disimpan', () async {
      final repo = KualitasUdaraRepository(_ApiUdara(), CacheService());
      await repo.ambil(-6.2, 106.9);
      await repo.ambil(-7.6, 110.8);
      final cache = CacheService();
      expect(
        await cache.baca(KualitasUdaraRepository.kunci(-6.2, 106.9)),
        isNull,
      );
      expect(
        await cache.baca(KualitasUdaraRepository.kunci(-7.6, 110.8)),
        isNotNull,
      );
    });
  });

  group('Provider', () {
    test('memuat lalu berhasil; titik sama tidak dimuat ulang', () async {
      final api = _ApiUdara();
      final p = KualitasUdaraProvider(
        KualitasUdaraRepository(api, CacheService()),
      );
      expect(p.status, StatusUdara.awal);
      await p.muat(-6.2, 106.9);
      expect(p.status, StatusUdara.berhasil);
      expect(p.data!.data.usAqi, 158);
      await p.muat(-6.21, 106.88);
      expect(api.urlDipanggil, hasLength(1));
      await p.muat(-6.2, 106.9, paksa: true);
      // Paksa: TTL cache masih segar, jadi tetap tanpa panggilan baru.
      expect(p.status, StatusUdara.berhasil);
    });

    test('gagal tanpa cache: status gagal, bisa dicoba lagi', () async {
      final api = _ApiUdara(offline: true);
      final p = KualitasUdaraProvider(
        KualitasUdaraRepository(api, CacheService()),
      );
      await p.muat(-6.2, 106.9);
      expect(p.status, StatusUdara.gagal);
      expect(p.data, isNull);
      api.offline = false;
      await p.muat(-6.2, 106.9, paksa: true);
      expect(p.status, StatusUdara.berhasil);
    });
  });

  group('Halaman Udara dan UV', () {
    Prakiraan prakiraan() =>
        Prakiraan.fromJson(fixture('prakiraan_31.71.01.1001.json'));

    // Siang hari setempat (12.00 WIB) di tanggal fixture.
    DateTime siang() =>
        prakiraan().hari.first.first.waktuUtc!.add(const Duration(hours: 5));

    Widget susun(
      KualitasUdaraProvider p, {
      double skala = 1.3,
      DateTime Function()? jam,
    }) {
      return ChangeNotifierProvider<KualitasUdaraProvider>.value(
        value: p,
        child: MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 800),
              textScaler: TextScaler.linear(skala),
            ),
            child: UdaraUvScreen(prakiraan: prakiraan(), jam: jam ?? siang),
          ),
        ),
      );
    }

    void ukuran(WidgetTester tester) {
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('UV dan AQI di dua kartu dengan label sumber masing-masing, '
        'tanpa overflow (360 dp, huruf 1,3x)', (tester) async {
      ukuran(tester);
      final p = KualitasUdaraProvider(
        KualitasUdaraRepository(_ApiUdara(), CacheService()),
      );
      await tester.pumpWidget(susun(p));
      await tester.pumpAndSettle();

      expect(find.text(l.udaraUvJudul), findsOneWidget); // judul halaman
      expect(find.text(l.uvJudul), findsOneWidget);
      expect(find.text(l.udaraJudul), findsOneWidget);
      // AQI dari fixture: 158 = tidak sehat.
      expect(find.text(l.aqiTidakSehat), findsOneWidget);
      expect(find.text(l.aqiNilai(158)), findsOneWidget);
      expect(find.text(l.aqiSaranTidakSehat), findsOneWidget);
      // Dua kartu terpisah, label sumber terpisah.
      expect(find.byType(KartuUv), findsOneWidget);
      expect(find.byType(KartuUdara), findsOneWidget);
      expect(find.text(l.uvCatatan), findsOneWidget);
      expect(find.text(l.udaraSumber), findsOneWidget);
      expect(l.udaraSumber, contains('Open-Meteo'));
      expect(l.udaraSumber, contains('CAMS'));
      expect(l.udaraSumber, isNot(contains('BMKG')));
      expect(l.uvCatatan, contains('BMKG'));
      // Keterangan data yang dikirim ke layanan luar dan bukan resmi BMKG.
      expect(find.text(l.udaraPrivasi), findsOneWidget);
      expect(find.text(l.bukanResmi, skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gagal: pesan dan tombol Coba lagi memuat ulang', (
      tester,
    ) async {
      ukuran(tester);
      final api = _ApiUdara(offline: true);
      final p = KualitasUdaraProvider(
        KualitasUdaraRepository(api, CacheService()),
      );
      await tester.pumpWidget(susun(p));
      await tester.pumpAndSettle();
      expect(find.text(l.udaraGagal), findsOneWidget);
      expect(find.text(l.cobaLagi), findsOneWidget);
      // UV tetap tampil karena dihitung di dalam aplikasi.
      expect(find.text(l.uvJudul), findsOneWidget);

      api.offline = false;
      await tester.tap(find.text(l.cobaLagi));
      await tester.pumpAndSettle();
      expect(find.text(l.udaraGagal), findsNothing);
      expect(find.text(l.aqiTidakSehat), findsOneWidget);
    });

    testWidgets('data dari cache diberi tanda belum diperbarui', (
      tester,
    ) async {
      ukuran(tester);
      final api = _ApiUdara();
      final jam = _Jam();
      final repo = KualitasUdaraRepository(api, CacheService(), jam: jam.call);
      await repo.ambil(-6.17638, 106.82671);
      api.offline = true;
      jam.sekarang = jam.sekarang.add(const Duration(hours: 6));
      final p = KualitasUdaraProvider(repo);
      await tester.pumpWidget(susun(p));
      await tester.pumpAndSettle();
      expect(find.text(l.udaraDataTersimpan), findsOneWidget);
      expect(find.text(l.aqiTidakSehat), findsOneWidget);
    });

    testWidgets('UV malam hari: tidak ada sinar UV', (tester) async {
      ukuran(tester);
      final p = KualitasUdaraProvider(
        KualitasUdaraRepository(_ApiUdara(), CacheService()),
      );
      // 23.30 WIB.
      await tester.pumpWidget(
        susun(
          p,
          jam: () => siang().add(const Duration(hours: 11, minutes: 30)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l.uvMalam), findsOneWidget);
      expect(find.text(l.uvRendah), findsOneWidget);
    });

    testWidgets('tarik untuk memuat ulang memanggil layanan lagi', (
      tester,
    ) async {
      ukuran(tester);
      final api = _ApiUdara();
      final jam = _Jam();
      final p = KualitasUdaraProvider(
        KualitasUdaraRepository(api, CacheService(), jam: jam.call),
      );
      await tester.pumpWidget(susun(p));
      await tester.pumpAndSettle();
      expect(api.urlDipanggil, hasLength(1));
      // Lewat TTL, lalu tarik.
      jam.sekarang = jam.sekarang.add(const Duration(hours: 2));
      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(api.urlDipanggil, hasLength(2));
    });
  });

  group('Tautan dari layar Cuaca', () {
    testWidgets('layar Cuaca hanya punya tautan; UV dan udara ada di halaman '
        'terpisah', (tester) async {
      const gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);
      await tester.pumpWidget(buatApp(gps: gps));
      await tester.pumpAndSettle();
      await tester.tap(navTab('cuaca'));
      await tester.pumpAndSettle();

      expect(find.text(l.uvJudul), findsNothing);
      expect(find.text(l.udaraJudul), findsNothing);
      final tautan = find.byType(TautanUdaraUv);
      expect(tautan, findsOneWidget);

      await tester.ensureVisible(tautan);
      await tester.pumpAndSettle();
      await tester.tap(tautan);
      await tester.pumpAndSettle();

      expect(find.byType(UdaraUvScreen), findsOneWidget);
      expect(find.text(l.uvJudul), findsOneWidget);
      expect(find.text(l.udaraJudul), findsOneWidget);
      expect(find.text(l.aqiTidakSehat), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Teks kategori dan saran', () {
    test('semua kategori punya nama dan saran di dua bahasa', () {
      for (final bahasa in [l, en]) {
        for (final k in KategoriUv.values) {
          expect(namaKategoriUv(bahasa, k), isNotEmpty);
          expect(saranUv(bahasa, k), isNotEmpty);
        }
        for (final k in KategoriAqi.values) {
          expect(namaKategoriAqi(bahasa, k), isNotEmpty);
          expect(saranAqi(bahasa, k), isNotEmpty);
        }
        expect(bahasa.udaraSumber, contains('Open-Meteo'));
      }
    });
  });
}
