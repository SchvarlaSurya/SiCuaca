import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/constants.dart';
import 'package:app/core/exceptions.dart';
import 'package:app/core/perairan_terdekat.dart';
import 'package:app/core/tautan_resmi.dart';
import 'package:app/models/maritim.dart';
import 'package:app/providers/maritim_provider.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/layanan_screen.dart';
import 'package:app/screens/maritim_screen.dart';
import 'package:app/services/cache_service.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/maritim_repository.dart';
import 'package:app/services/preferences_service.dart';

import 'helpers.dart';

const _jakarta = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

/// Jam yang bisa dimajukan di test TTL.
class _Jam {
  DateTime sekarang = DateTime.utc(2026, 11, 24, 3);
  DateTime call() => sekarang;
}

/// Gulir [f] ke sekitar tengah layar (tidak tertutup navbar melayang),
/// lalu ketuk.
Future<void> _ketuk(WidgetTester tester, Finder f, {double arah = 200}) async {
  // Daftar dibangun malas: gulir dulu sampai butirnya ada ([arah] negatif =
  // ke atas).
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      arah,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await Scrollable.ensureVisible(tester.element(f), alignment: .4);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Model prakiraan maritim (data asli BMKG)', () {
    test('perairan: urut waktu, hari 1 per jam + hari 2-4 per 3 jam', () {
      final p = PrakiraanMaritim.fromJson(fixture('maritim_perairan.json'));
      expect(p.kode, 'P.A.05');
      expect(p.nama, 'Perairan Aceh Besar - Meulaboh');
      expect(p.entri, hasLength(41));
      expect(p.terbit, DateTime.utc(2026, 11, 23, 12));
      expect(p.berlakuSampai, DateTime.utc(2026, 11, 27));
      final a = p.entri.first;
      expect(a.waktuUtc, DateTime.utc(2026, 11, 24));
      expect(a.kategoriGelombang, 'Sedang');
      expect(a.tingkat, TingkatGelombang.sedang);
      expect(a.tinggiGelombang, 1.6);
      expect(a.arahAngin, 'Barat Laut');
      expect(a.anginKnot, 4);
      expect(a.hembusanKnot, 16);
      expect(a.arahArus, 'Barat Daya');
      expect(a.arusKnot, 1.5);
      expect(a.cuaca, 'Hujan Ringan');
      for (var i = 1; i < p.entri.length; i++) {
        expect(p.entri[i].waktuUtc.isAfter(p.entri[i - 1].waktuUtc), isTrue);
      }
    });

    test('respons rusak atau kosong ditolak; butir rusak dilewati', () {
      expect(
        () => PrakiraanMaritim.fromJson(const {'name': 'x'}),
        throwsFormatException,
      );
      expect(
        () => PrakiraanMaritim.fromJson(const {
          'code': 'P.X',
          'forecast_day1': [],
        }),
        throwsFormatException,
      );
      final p = PrakiraanMaritim.fromJson(const {
        'code': 'P.X',
        'forecast_day1': [
          {'time': 'bukan waktu', 'wave_cat': 'Tinggi'},
          'bukan objek',
          {
            'time': '2026-11-24 05:00 UTC',
            'wave_cat': 'Tinggi',
            'wave_height': 'x',
            'wind_speed': '7',
          },
        ],
      });
      expect(p.entri, hasLength(1));
      expect(p.entri.single.tinggiGelombang, isNull);
      expect(p.entri.single.anginKnot, 7);
      expect(p.nama, 'P.X');
    });

    test('kategori gelombang dari teks BMKG', () {
      expect(TingkatGelombang.dari(' Rendah '), TingkatGelombang.rendah);
      expect(TingkatGelombang.dari('SEDANG'), TingkatGelombang.sedang);
      expect(
        TingkatGelombang.dari('Sangat Tinggi'),
        TingkatGelombang.sangatTinggi,
      );
      expect(TingkatGelombang.dari('Ekstrim'), TingkatGelombang.ekstrem);
      expect(TingkatGelombang.dari(''), TingkatGelombang.tidakDikenal);
      expect(TingkatGelombang.dari('Badai'), TingkatGelombang.tidakDikenal);
    });

    test('entri yang sedang berlaku', () {
      final p = PrakiraanMaritim.fromJson(fixture('maritim_perairan.json'));
      expect(p.terdekat(DateTime.utc(2026, 1, 1)), p.entri.first);
      expect(
        p.terdekat(DateTime.utc(2026, 11, 24, 5, 30)).waktuUtc,
        DateTime.utc(2026, 11, 24, 5),
      );
      expect(p.terdekat(DateTime.utc(2030)), p.entri.last);
      final mulai = p.mulaiDari(DateTime.utc(2026, 11, 24, 5, 30));
      expect(mulai.first.waktuUtc, DateTime.utc(2026, 11, 24, 5));
    });

    test('daftar perairan per provinsi', () {
      final d = AreaPerairan.daftarDariJson(
        fixture('maritim_area_province.json'),
      );
      expect(d, hasLength(375));
      expect(d.first.id, 'P.A.05');
      expect(d.first.provinsi, 'Aceh');
      expect(
        () => AreaPerairan.daftarDariJson(const {'x': 1}),
        throwsFormatException,
      );
      final ganda = AreaPerairan.daftarDariJson(const {
        'data': [
          {
            'province': 'A',
            'areas': [
              {'id': 'P.1', 'name': 'Satu'},
              {'id': 'P.1', 'name': 'Ganda'},
              {'id': '', 'name': 'Tanpa id'},
            ],
          },
        ],
      });
      expect(ganda.map((a) => a.nama), ['Satu']);
    });
  });

  group('Perairan terdekat dari lokasi (GeoJSON asli BMKG)', () {
    final geo = fixture('maritim_wilayah.geojson');

    test('Jakarta → Teluk Jakarta, Malang → Perairan Malang', () {
      final a = cariPerairanTerdekat(geo, -6.2088, 106.8456)!;
      expect(a.id, 'P.J.03');
      expect(a.nama, 'Teluk Jakarta');
      expect(a.jarakKm, closeTo(17.1, 1));
      expect(cariPerairanTerdekat(geo, -8.17, 112.64)!.id, 'P.O.30');
    });

    test('titik di laut (di dalam poligon) berjarak 0', () {
      final a = cariPerairanTerdekat(geo, -6.1, 106.74)!;
      expect(a.id, 'P.J.03');
      expect(a.jarakKm, 0);
    });

    test('GeoJSON rusak: null, tidak crash', () {
      expect(cariPerairanTerdekat(const {}, 0, 0), isNull);
      expect(
        cariPerairanTerdekat(
          const {
            'features': [
              {'properties': {}, 'geometry': {}},
              'x',
            ],
          },
          0,
          0,
        ),
        isNull,
      );
    });
  });

  group('Repository maritim: cache dengan TTL', () {
    late FakeApi api;
    late _Jam jam;
    late MaritimRepository repo;

    setUp(() {
      api = FakeApi();
      jam = _Jam();
      repo = MaritimRepository(api, CacheService(), jam: jam.call);
    });

    test('prakiraan segar (< 3 jam) tidak memanggil BMKG lagi', () async {
      final a = await repo.prakiraan('P.A.05');
      expect(api.panggilan, 1);
      expect(a.dariCache, isFalse);

      jam.sekarang = jam.sekarang.add(const Duration(hours: 2));
      final b = await repo.prakiraan('P.A.05');
      expect(api.panggilan, 1);
      expect(b.dariCache, isFalse);
      expect(b.data.entri, hasLength(41));

      jam.sekarang = jam.sekarang.add(const Duration(hours: 2));
      await repo.prakiraan('P.A.05');
      expect(api.panggilan, 2);
    });

    test(
      'kedaluwarsa + luring: data lama dipakai dan ditandai cache',
      () async {
        await repo.prakiraan('P.A.05');
        jam.sekarang = jam.sekarang.add(const Duration(hours: 5));
        api.offline = true;
        final b = await repo.prakiraan('P.A.05');
        expect(b.dariCache, isTrue);
        expect(b.diperbarui, DateTime.utc(2026, 11, 24, 3));
      },
    );

    test('luring tanpa cache: galat diteruskan', () async {
      api.offline = true;
      expect(() => repo.prakiraan('P.A.05'), throwsA(isA<ApiException>()));
    });

    test('hanya prakiraan perairan aktif yang disimpan', () async {
      await repo.prakiraan('P.A.05');
      await repo.prakiraan('P.J.03');
      final prefs = await SharedPreferences.getInstance();
      final kunci = prefs.getKeys().where(
        (k) => k.startsWith('${PrefsKeys.cache}maritim.perairan.'),
      );
      expect(kunci, ['${PrefsKeys.cache}maritim.perairan.P.J.03']);
    });

    test('daftar perairan disimpan 7 hari', () async {
      await repo.daftarPerairan();
      jam.sekarang = jam.sekarang.add(const Duration(days: 6));
      await repo.daftarPerairan();
      expect(api.panggilan, 1);
      jam.sekarang = jam.sekarang.add(const Duration(days: 2));
      await repo.daftarPerairan();
      expect(api.panggilan, 2);
    });

    test('perairan terdekat: GeoJSON diunduh sekali; diulang bila lokasi '
        'bergeser jauh', () async {
      final a = await repo.terdekat(-6.2088, 106.8456);
      expect(a!.id, 'P.J.03');
      expect(api.panggilan, 1);
      await repo.terdekat(-6.21, 106.85); // bergeser < 10 km
      expect(api.panggilan, 1);
      final b = await repo.terdekat(-8.17, 112.64); // pindah ke Malang
      expect(b!.id, 'P.O.30');
      expect(api.panggilan, 2);

      api.offline = true;
      final c = await repo.terdekat(-6.2, 106.8);
      expect(c!.id, 'P.O.30', reason: 'luring: hasil terakhir dipakai');
    });
  });

  group('Provider maritim', () {
    MaritimProvider buat({
      ({double lat, double lon})? posisi,
      bool luring = false,
    }) => MaritimProvider(
      MaritimRepository(FakeApi(offline: luring), CacheService()),
      PreferencesService(),
      posisi: () => posisi,
    );

    test('tanpa lokasi dan belum memilih: minta pilih', () async {
      final p = buat();
      await p.muat();
      expect(p.status, StatusMaritim.perluPilih);
    });

    test('dengan lokasi: perairan terdekat beserta jaraknya', () async {
      final p = buat(posisi: (lat: -6.2088, lon: 106.8456));
      await p.muat();
      expect(p.status, StatusMaritim.berhasil);
      expect(p.asal, AsalPerairan.terdekat);
      expect(p.kode, 'P.J.03');
      expect(p.jarakKm, closeTo(17.1, 1));
    });

    test('pilihan pengguna tersimpan dan didahulukan; bisa kembali ke '
        'terdekat', () async {
      final p = buat(posisi: (lat: -6.2088, lon: 106.8456));
      await p.pilih(
        const AreaPerairan(
          id: 'P.O.30',
          nama: 'Perairan Malang',
          provinsi: 'Jatim',
        ),
      );
      expect(p.asal, AsalPerairan.pilihan);
      expect(p.kode, 'P.O.30');

      final q = buat(posisi: (lat: -6.2088, lon: 106.8456));
      await q.muat();
      expect(q.kode, 'P.O.30');

      await q.pakaiTerdekat();
      expect(q.asal, AsalPerairan.terdekat);
      expect(q.kode, 'P.J.03');
    });

    test('jaringan gagal tanpa cache: status gagal', () async {
      final p = buat(posisi: (lat: -6.2, lon: 106.8), luring: true);
      await p.muat();
      expect(p.status, StatusMaritim.gagal);
      expect(p.galat, isA<ApiException>());
    });

    test('saring daftar perairan menurut nama atau provinsi', () {
      const d = [
        AreaPerairan(id: '1', nama: 'Teluk Jakarta', provinsi: 'DKI Jakarta'),
        AreaPerairan(id: '2', nama: 'Perairan Malang', provinsi: 'Jawa Timur'),
      ];
      expect(MaritimProvider.saring(d, 'teluk').map((a) => a.id), ['1']);
      expect(MaritimProvider.saring(d, 'jawa').map((a) => a.id), ['2']);
      expect(MaritimProvider.saring(d, ''), d);
    });
  });

  group('Layar Layanan dan Cuaca maritim', () {
    final dibuka = <Uri>[];
    var berhasilBuka = true;
    setUp(() {
      dibuka.clear();
      berhasilBuka = true;
      TautanResmiBmkg.pembuka = (uri) async {
        dibuka.add(uri);
        return berhasilBuka;
      };
    });

    for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
      final t = bahasa == PilihanBahasa.inggris ? en : l;

      testWidgets('360 dp + huruf 1,3x: Layanan dari Pengaturan, tautan resmi, '
          'lalu Cuaca maritim (${bahasa.name})', (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          buatApp(
            gps: _jakarta,
            pengaturan: PengaturanProvider(
              PreferencesService(),
              bahasa: bahasa,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(navTab('pengaturan'));
        await tester.pumpAndSettle();
        await _ketuk(tester, find.byKey(const ValueKey('pengaturan.layanan')));
        expect(find.byType(LayananScreen), findsOneWidget);

        // Enam layanan, tiap tautan keluar diberi label halaman resmi.
        for (final k in [
          'maritim',
          'radar',
          'penerbangan',
          'titikPanas',
          'iklim',
          'siaranPers',
        ]) {
          final kartu = find.byKey(ValueKey('layanan.$k'));
          await tester.scrollUntilVisible(
            kartu,
            150,
            scrollable: find.byType(Scrollable).last,
          );
          expect(kartu, findsOneWidget);
        }
        await tester.scrollUntilVisible(
          find.text(t.sumberBmkg),
          150,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text(t.sumberBmkg), findsOneWidget);

        // Tautan keluar: dibuka lewat pembuka, isi tidak diambil.
        await _ketuk(tester, find.byKey(const ValueKey('layanan.siaranPers')));
        expect(dibuka.single.toString(), TautanResmi.siaranPers);

        // Gagal membuka: pemberitahuan, tidak crash.
        berhasilBuka = false;
        await _ketuk(tester, find.byKey(const ValueKey('layanan.siaranPers')));
        expect(find.text(t.layananGagalBuka), findsOneWidget);

        // Cuaca maritim: perairan terdekat, kategori sebagai teks.
        await _ketuk(
          tester,
          find.byKey(const ValueKey('layanan.maritim')),
          arah: -200,
        );
        expect(find.byType(MaritimScreen), findsOneWidget);
        expect(find.text('Perairan Aceh Besar - Meulaboh'), findsOneWidget);
        expect(
          find.textContaining(
            t.maritimPerairanTerdekat('17').split('±').first.split('~').first,
          ),
          findsWidgets,
        );
        expect(
          find.text(t.gelombangSedang).evaluate().isNotEmpty ||
              find.text(t.gelombangRendah).evaluate().isNotEmpty,
          isTrue,
        );
        await tester.scrollUntilVisible(
          find.text(t.sumberBmkg),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text(t.sumberBmkg), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tanpa lokasi: pilih perairan lewat pencarian', (tester) async {
      await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
      await tester.pumpAndSettle();
      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
      await _ketuk(tester, find.byKey(const ValueKey('pengaturan.layanan')));
      await _ketuk(tester, find.byKey(const ValueKey('layanan.maritim')));
      expect(find.text(l.maritimPerluPilih), findsOneWidget);

      await tester.tap(find.byTooltip(l.maritimPilihPerairan));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'malang');
      await tester.pumpAndSettle();
      final malang = find.byKey(const ValueKey('perairan.P.O.30'));
      expect(malang, findsOneWidget);
      await tester.tap(malang);
      await tester.pumpAndSettle();
      expect(find.text(l.maritimPerairanPilihan), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('API gagal dan belum ada cache: pesan galat + coba lagi', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: _jakarta, offline: true));
      await tester.pumpAndSettle();
      final p = tester.element(find.byType(Scaffold).first);
      Navigator.of(
        p,
      ).push(MaterialPageRoute<void>(builder: (_) => const MaritimScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining(l.maritimGagal), findsOneWidget);
      expect(find.text(l.cobaLagi), findsOneWidget);
    });
  });
}
