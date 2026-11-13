import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/exceptions.dart';
import 'package:app/core/strings.dart';
import 'package:app/main.dart';
import 'package:app/models/gempa.dart';
import 'package:app/models/lokasi.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/favorit_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/wilayah_service.dart';

const _tsv =
    '31\tDKI Jakarta\r\n' // satu baris CRLF untuk menguji toleransi
    '31.71\tKota Adm. Jakarta Pusat\n'
    '31.71.01\tGambir\n'
    '31.71.01.1001\tGambir\t-6.17638\t106.82671\n'
    '31.71.01.1002\tCideng\t-6.17298\t106.80831\n'
    '35\tJawa Timur\n'
    '35.07\tKab. Malang\n'
    '35.07.10\tGondanglegi\n'
    '35.07.10.2001\tPutat Kidul\t-8.17004\t112.64473\n'
    "35.07.10.2002\tSuka'maju\t\t\n";

final _gambir = parseWilayah(_tsv).cari('gambir').first;

Map<String, dynamic> _fixture() =>
    jsonDecode(
          File('test/fixtures/prakiraan_31.71.01.1001.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

class _FakeApi extends ApiService {
  _FakeApi({this.offline = false});

  final bool offline;

  @override
  Future<Gempa> fetchAutoGempa() async {
    if (offline) throw ApiException.noInternet();
    return Gempa.fromJson(const {'Magnitude': '4.6', 'Wilayah': 'Laut'});
  }

  @override
  Future<Prakiraan> fetchPrakiraanCuaca(String adm4) async {
    if (offline) throw ApiException.noInternet();
    return Prakiraan.fromJson(_fixture());
  }
}

class _FakeGps extends GpsService {
  _FakeGps(this.hasil);

  final HasilGps hasil;

  @override
  Future<HasilGps> ambilPosisi() async => hasil;
}

class _FakeWilayah extends WilayahService {
  @override
  Future<IndeksWilayah> muat() async => parseWilayah(_tsv);
}

Widget _app({required HasilGps gps, bool offline = false}) => SiCuacaApp(
  apiService: _FakeApi(offline: offline),
  gpsService: _FakeGps(gps),
  wilayahService: _FakeWilayah(),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Gempa', () {
    test('tidak crash saat field hilang atau null', () {
      final gempa = Gempa.fromJson(const {'Magnitude': null});
      expect(gempa.magnitudo, '');
      expect(gempa.shakemapUrl, isNull);
    });
  });

  group('Prakiraan', () {
    test('membaca respons asli BMKG', () {
      final p = Prakiraan.fromJson(_fixture());
      expect(p.lokasi.desa, 'Gambir');
      expect(p.hari.length, 3);
      expect(p.hari.map((h) => h.length), [5, 8, 8]);
      final e = p.hari.first.first;
      expect(e.suhu, 31);
      expect(e.kelembapan, 65);
      expect(e.kecepatanAngin, 5.5);
      expect(e.waktuLokal, DateTime.utc(2026, 11, 13, 10));
      expect(e.jarakPandang, isNull);
      expect(p.selisihZona, const Duration(hours: 7));
    });

    test('tipe berbeda, null, atau elemen rusak tidak membuat crash', () {
      final p = Prakiraan.fromJson(const {
        'data': [
          {
            'cuaca': [
              [
                {'t': '30', 'hu': null, 'ws': '4,5', 'weather_desc': 7},
                'bukan objek',
              ],
              'bukan larik',
            ],
          },
        ],
      });
      final e = p.hari.single.single;
      expect(e.suhu, 30);
      expect(e.kelembapan, isNull);
      expect(e.kecepatanAngin, 4.5);
      expect(e.waktuLokal, isNull);
      expect(p.entriTerdekat(DateTime.now()), e);
    });

    test('data kosong melempar FormatException', () {
      expect(() => Prakiraan.fromJson(const {}), throwsFormatException);
    });
  });

  group('IndeksWilayah', () {
    final indeks = parseWilayah(_tsv);

    test('mencari nama desa, kecamatan, dan beberapa kata', () {
      expect(indeks.jumlahDesa, 4);
      expect(indeks.cari('ci').isEmpty, isTrue);
      expect(
        indeks.cari('cideng').single.labelLengkap,
        'Cideng, Gambir, Kota Adm. Jakarta Pusat, DKI Jakarta',
      );
      expect(indeks.cari('gondang').length, 2);
      expect(indeks.cari('putat malang').single.adm4, '35.07.10.2001');
      expect(indeks.cari('sukamaju').single.desa, "Suka'maju");
    });

    test('desa terdekat dari koordinat, lewati desa tanpa koordinat', () {
      final t = indeks.terdekat(-8.2, 112.6)!;
      expect(t.lokasi.desa, 'Putat Kidul');
      expect(t.jarakKm, lessThan(10));
    });
  });

  test('favorit tersimpan dan terbaca lagi', () async {
    final fav = FavoritProvider(PreferencesService());
    await fav.toggle(_gambir);
    final dibukaLagi = FavoritProvider(PreferencesService());
    await dibukaLagi.muat();
    expect(dibukaLagi.daftar.single.adm4, _gambir.adm4);
  });

  testWidgets('GPS ditolak: pesan jelas, pilihan manual tetap ada', (
    tester,
  ) async {
    await tester.pumpWidget(_app(gps: const HasilGps(StatusGps.ditolak)));
    await tester.pumpAndSettle();

    expect(find.text(Str.gpsDitolak), findsOneWidget);
    expect(find.text(Str.cariWilayah), findsWidgets);
  });

  testWidgets('GPS berhasil: cuaca desa terdekat tampil dan tersimpan', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(gps: const HasilGps(StatusGps.berhasil, lat: -6.17, lon: 106.82)),
    );
    await tester.pumpAndSettle();

    expect(find.text(Str.cuacaSaatIni), findsOneWidget);
    expect(find.text('Gambir'), findsWidgets);
    expect(find.text(Str.sumberBmkg), findsOneWidget);
    final tersimpan = await PreferencesService().wilayahTerakhir();
    expect(tersimpan?.adm4, '31.71.01.1001');

    await tester.tap(find.byIcon(Icons.wb_sunny_outlined).last);
    await tester.pumpAndSettle();
    expect(find.byType(Tab), findsNWidgets(3));
  });

  testWidgets('wilayah terakhir dipulihkan; offline menampilkan coba lagi', (
    tester,
  ) async {
    await PreferencesService().simpanWilayahTerakhir(
      const Lokasi(
        adm4: '31.71.01.1001',
        desa: 'Gambir',
        kecamatan: 'Gambir',
        kotkab: 'Kota Adm. Jakarta Pusat',
        provinsi: 'DKI Jakarta',
      ),
    );
    await tester.pumpWidget(
      _app(gps: const HasilGps(StatusGps.gagal), offline: true),
    );
    await tester.pumpAndSettle();

    // Kartu cuaca dan kartu uji koneksi sama-sama gagal.
    expect(find.text(Str.errTidakAdaInternet), findsNWidgets(2));
    expect(find.text(Str.cobaLagi), findsWidgets);
    expect(find.text(Str.gpsGagal), findsNothing);
  });
}
