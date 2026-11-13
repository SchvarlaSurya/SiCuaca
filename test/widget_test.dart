import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/exceptions.dart';
import 'package:app/core/strings.dart';
import 'package:app/main.dart';
import 'package:app/models/gempa.dart';
import 'package:app/models/ambang_gempa.dart';
import 'package:app/models/lokasi.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/favorit_provider.dart';
import 'package:app/providers/notifikasi_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/notifikasi_service.dart';
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

class _FakeNotif extends NotifikasiService {
  _FakeNotif({this.izin = true, this.gagal = false, this.aktif = true});

  final bool izin;
  final bool gagal;
  final bool aktif;
  final List<AmbangGempa> langgananDipanggil = [];

  @override
  bool get siap => aktif;

  @override
  Future<bool> mintaIzin() async => izin;

  @override
  Future<void> langganan(AmbangGempa ambang) async {
    if (gagal) throw Exception('SERVICE_NOT_AVAILABLE');
    langgananDipanggil.add(ambang);
  }

  @override
  Future<void> bukaPengaturanAplikasi() async {}
}

Widget _app({
  required HasilGps gps,
  bool offline = false,
  NotifikasiService? notif,
}) => SiCuacaApp(
  apiService: _FakeApi(offline: offline),
  gpsService: _FakeGps(gps),
  wilayahService: _FakeWilayah(),
  notifikasiService: notif,
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

  group('Notifikasi gempa', () {
    test('memilih M5 subscribe ke gempa_m5 dan tersimpan', () async {
      final service = _FakeNotif();
      final p = NotifikasiProvider(service, PreferencesService());
      await p.muat();
      await p.pilih(AmbangGempa.m5);

      expect(service.langgananDipanggil, [AmbangGempa.m5]);
      expect(AmbangGempa.m5.topik, 'gempa_m5');
      final dibukaLagi = NotifikasiProvider(service, PreferencesService());
      await dibukaLagi.muat();
      expect(dibukaLagi.ambang, AmbangGempa.m5);
    });

    test('izin ditolak: pilihan tidak berubah, tidak crash', () async {
      final service = _FakeNotif(izin: false);
      final p = NotifikasiProvider(service, PreferencesService());
      await p.pilih(AmbangGempa.m4);

      expect(p.ambang, AmbangGempa.mati);
      expect(p.izinDitolak, isTrue);
      expect(p.pesan, Str.notifIzinDitolak);
      expect(service.langgananDipanggil, isEmpty);
    });

    test('mematikan notifikasi tidak meminta izin', () async {
      SharedPreferences.setMockInitialValues({'ambang_gempa': 'm6'});
      final service = _FakeNotif(izin: false);
      final p = NotifikasiProvider(service, PreferencesService());
      await p.muat();
      await p.pilih(AmbangGempa.mati);

      expect(p.ambang, AmbangGempa.mati);
      expect(service.langgananDipanggil, [AmbangGempa.mati]);
    });

    test('gagal subscribe (offline): pesan jelas, pilihan tetap', () async {
      final p = NotifikasiProvider(
        _FakeNotif(gagal: true),
        PreferencesService(),
      );
      await p.pilih(AmbangGempa.m5);

      expect(p.ambang, AmbangGempa.mati);
      expect(p.pesan, Str.notifGagalLangganan);
    });

    test('Firebase belum dikonfigurasi: pesan belum aktif', () async {
      final p = NotifikasiProvider(
        _FakeNotif(aktif: false),
        PreferencesService(),
      );
      await p.pilih(AmbangGempa.m5);

      expect(p.ambang, AmbangGempa.mati);
      expect(p.pesan, Str.notifBelumAktif);
    });

    testWidgets('tab Peringatan: memilih ambang mengubah pilihan', (
      tester,
    ) async {
      final service = _FakeNotif();
      await tester.pumpWidget(
        _app(gps: const HasilGps(StatusGps.ditolak), notif: service),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.warning_amber_outlined).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(Str.notifM5));
      await tester.pumpAndSettle();

      expect(service.langgananDipanggil, [AmbangGempa.m5]);
      final radio = tester.widget<RadioGroup<AmbangGempa>>(
        find.byType(RadioGroup<AmbangGempa>),
      );
      expect(radio.groupValue, AmbangGempa.m5);
    });
  });
}
