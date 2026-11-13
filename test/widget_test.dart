import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

import 'package:app/core/ikon.dart';
import 'package:app/models/ambang_gempa.dart';
import 'package:app/models/lokasi.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/favorit_provider.dart';
import 'package:app/providers/notifikasi_provider.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/wilayah_service.dart';

final _gambir = parseWilayah(tsvUji).cari('gambir').first;

Map<String, dynamic> _fixture() => fixture('prakiraan_31.71.01.1001.json');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
    final indeks = parseWilayah(tsvUji);

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
    await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
    await tester.pumpAndSettle();

    expect(find.text(l.gpsDitolak), findsOneWidget);
    expect(find.text(l.cariWilayah), findsWidgets);
  });

  testWidgets('GPS berhasil: cuaca desa terdekat tampil dan tersimpan', (
    tester,
  ) async {
    await tester.pumpWidget(
      buatApp(gps: const HasilGps(StatusGps.berhasil, lat: -6.17, lon: 106.82)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l.cuacaSaatIni), findsOneWidget);
    expect(find.text('Gambir'), findsWidgets);
    // Kartu cuaca dan kartu gempa terbaru masing-masing mencantumkan sumber.
    expect(find.text(l.sumberBmkg), findsNWidgets(2));
    // Posisi GPS tersedia: jarak gempa terbaru ke pengguna tampil.
    expect(find.textContaining('km dari Anda'), findsOneWidget);
    final tersimpan = await PreferencesService().wilayahTerakhir();
    expect(tersimpan?.adm4, '31.71.01.1001');

    await tester.tap(find.byIcon(IkonApp.cuaca).last);
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
      buatApp(gps: const HasilGps(StatusGps.gagal), offline: true),
    );
    await tester.pumpAndSettle();

    // Kartu cuaca dan kartu gempa terbaru sama-sama gagal.
    expect(find.text(l.errTidakAdaInternet), findsNWidgets(2));
    expect(find.text(l.cobaLagi), findsWidgets);
    expect(find.text(l.gpsGagal), findsNothing);
  });

  group('Notifikasi gempa', () {
    test('memilih M5 subscribe ke gempa_m5 dan tersimpan', () async {
      final service = FakeNotif();
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
      final service = FakeNotif(izin: false);
      final p = NotifikasiProvider(service, PreferencesService());
      await p.pilih(AmbangGempa.m4);

      expect(p.ambang, AmbangGempa.mati);
      expect(p.izinDitolak, isTrue);
      expect(p.pesan, PesanNotifikasi.izinDitolak);
      expect(service.langgananDipanggil, isEmpty);
    });

    test('mematikan notifikasi tidak meminta izin', () async {
      SharedPreferences.setMockInitialValues({'ambang_gempa': 'm6'});
      final service = FakeNotif(izin: false);
      final p = NotifikasiProvider(service, PreferencesService());
      await p.muat();
      await p.pilih(AmbangGempa.mati);

      expect(p.ambang, AmbangGempa.mati);
      expect(service.langgananDipanggil, [AmbangGempa.mati]);
    });

    test('gagal subscribe (offline): pesan jelas, pilihan tetap', () async {
      final p = NotifikasiProvider(
        FakeNotif(gagal: true),
        PreferencesService(),
      );
      await p.pilih(AmbangGempa.m5);

      expect(p.ambang, AmbangGempa.mati);
      expect(p.pesan, PesanNotifikasi.gagalLangganan);
    });

    test('Firebase belum dikonfigurasi: pesan belum aktif', () async {
      final p = NotifikasiProvider(
        FakeNotif(aktif: false),
        PreferencesService(),
      );
      await p.pilih(AmbangGempa.m5);

      expect(p.ambang, AmbangGempa.mati);
      expect(p.pesan, PesanNotifikasi.belumAktif);
    });

    testWidgets('tab Peringatan: memilih ambang mengubah pilihan', (
      tester,
    ) async {
      final service = FakeNotif();
      await tester.pumpWidget(
        buatApp(gps: const HasilGps(StatusGps.ditolak), notif: service),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(IkonApp.peringatan).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.notifM5));
      await tester.pumpAndSettle();

      expect(service.langgananDipanggil, [AmbangGempa.m5]);
      final radio = tester.widget<RadioGroup<AmbangGempa>>(
        find.byType(RadioGroup<AmbangGempa>),
      );
      expect(radio.groupValue, AmbangGempa.m5);
    });
  });

  group('Tab Gempa', () {
    testWidgets('tiga sub-tab berisi data, item membuka detail', (
      tester,
    ) async {
      await tester.pumpWidget(
        buatApp(
          gps: const HasilGps(StatusGps.berhasil, lat: -6.17, lon: 106.82),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(IkonApp.gempa).last);
      await tester.pumpAndSettle();
      expect(find.text(l.gempaTerbaruJudul), findsWidgets);

      await tester.tap(find.text(l.gempaTabTerkini));
      await tester.pumpAndSettle();
      expect(
        find.text('116 km TimurLaut HALMAHERASELATAN-MALUT'),
        findsOneWidget,
      );
      expect(find.text('Tidak berpotensi tsunami'), findsWidgets);
      expect(find.textContaining('km dari Anda'), findsWidgets);

      await tester.tap(find.text(l.gempaTabDirasakan));
      await tester.pumpAndSettle();
      expect(find.text('II - III Enggano'), findsWidgets);

      await tester.tap(find.text('II - III Enggano').first);
      await tester.pumpAndSettle();
      expect(find.text(l.gempaDetailJudul), findsOneWidget);
      expect(find.text(l.shakemapJudul), findsOneWidget);
      final gulir = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text(l.jarakDariAnda),
        200,
        scrollable: gulir,
      );
      expect(find.text(l.jarakDariAnda), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(l.sumberBmkg),
        200,
        scrollable: gulir,
      );
      expect(find.text(l.sumberBmkg), findsWidgets);
    });

    testWidgets('izin lokasi ditolak: jarak disembunyikan, ada ajakan', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(IkonApp.gempa).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.gempaTabTerkini));
      await tester.pumpAndSettle();

      expect(find.textContaining('km dari Anda'), findsNothing);
      expect(find.text(l.gpsDitolak), findsWidgets);
      expect(
        find.text('116 km TimurLaut HALMAHERASELATAN-MALUT'),
        findsOneWidget,
      );
    });

    testWidgets('offline: pesan jelas dan tombol coba lagi', (tester) async {
      await tester.pumpWidget(
        buatApp(gps: const HasilGps(StatusGps.ditolak), offline: true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(IkonApp.gempa).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.gempaTabDirasakan));
      await tester.pumpAndSettle();

      expect(find.text(l.errTidakAdaInternet), findsWidgets);
      expect(find.text(l.cobaLagi), findsWidgets);
    });
  });

  testWidgets('ketukan notifikasi membuka detail dari payload walau offline', (
    tester,
  ) async {
    final notif = FakeNotif();
    await tester.pumpWidget(
      buatApp(
        gps: const HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456),
        offline: true,
        notif: notif,
      ),
    );
    await tester.pumpAndSettle();

    notif.pembuka.tanganiData(const {
      'jenis': 'gempa',
      'gempa_key': '2026-11-13T04:49:34+00:00|-8.22,116.77',
      'magnitudo': '4.9',
      'wilayah': 'Pusat gempa berada di laut 29 km Barat Laut PULAUPANJANG',
      'kedalaman': '17 km',
      'waktu': '2026-11-13T04:49:34+00:00',
      'tanggal': '13 Nov 2026',
      'jam': '11:49:34 WIB',
      'koordinat': '-8.22,116.77',
      'shakemap': '20261113114934.mmi.jpg',
      'potensi': '',
      'dirasakan': 'IV Kab. Lombok Timur',
    }, sumber: 'uji');
    await tester.pumpAndSettle();

    expect(find.text(l.gempaDetailJudul), findsOneWidget);
    expect(find.text('4.9'), findsWidgets);
    final gulir = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text(l.jarakDariAnda),
      200,
      scrollable: gulir,
    );
    // Jakarta ke pusat gempa Lombok sekitar 1.117 km.
    expect(find.text(l.jarakKm('1.117')), findsOneWidget);
  });
}
