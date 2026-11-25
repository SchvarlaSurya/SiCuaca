import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/models/prakiraan.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/widget_layar_service.dart';

import 'helpers.dart';

/// Menyimpan data di memori dan mencatat urutan panggilan.
class _PenyimpanMemori implements PenyimpanWidget {
  final data = <String, String>{};
  final panggilan = <String>[];

  @override
  Future<void> simpan(Map<String, String> isi) async {
    panggilan.add('simpan');
    data.addAll(isi);
  }

  @override
  Future<void> segarkan() async => panggilan.add('segarkan');
}

class _PenyimpanRusak implements PenyimpanWidget {
  @override
  Future<void> simpan(Map<String, String> isi) async =>
      throw Exception('gagal simpan');

  @override
  Future<void> segarkan() async => throw Exception('gagal segarkan');
}

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Prakiraan prakiraan() =>
      Prakiraan.fromJson(fixture('prakiraan_31.71.01.1001.json'));

  group('Isi data widget', () {
    test(
      'memuat suhu, kelembapan, angin, kondisi dua bahasa, kode, wilayah',
      () {
        final p = prakiraan();
        final e = p.hari.first.first;
        final isi = WidgetLayar.susun(
          prakiraan: p,
          entri: e,
          bahasa: 'id',
          diperbarui: DateTime.utc(2026, 11, 25, 5),
        );
        expect(isi['ada_data'], '1');
        expect(isi['adm4'], '31.71.01.1001');
        expect(isi['wilayah'], contains(p.lokasi.desa));
        expect(isi['wilayah'], contains(p.lokasi.kotkab));
        expect(isi['suhu'], e.suhu!.round().toString());
        expect(isi['kelembapan'], e.kelembapan.toString());
        expect(isi['angin'], e.kecepatanAngin!.round().toString());
        expect(isi['kondisi_id'], e.deskripsi);
        expect(isi['kondisi_en'], e.deskripsiEn);
        expect(isi['kode'], e.kodeCuaca.toString());
        expect(isi['malam'], e.malam ? '1' : '0');
        expect(isi['bahasa'], 'id');
        expect(
          isi['diperbarui_ms'],
          DateTime.utc(2026, 11, 25, 5).millisecondsSinceEpoch.toString(),
        );
      },
    );

    test('hanya kunci yang dikenal widget; koordinat wilayah, bukan GPS', () {
      final p = prakiraan();
      final isi = WidgetLayar.susun(
        prakiraan: p,
        entri: p.hari.first.first,
        bahasa: 'sistem',
        diperbarui: DateTime.utc(2026),
      );
      expect(isi.keys.toSet(), {
        'ada_data',
        'adm4',
        'wilayah',
        'suhu',
        'kelembapan',
        'angin',
        'kondisi_id',
        'kondisi_en',
        'kode',
        'awan',
        'lat',
        'lon',
        'malam',
        'bahasa',
        'diperbarui_ms',
      });
      // Koordinat adalah titik pusat wilayah fixture, dua desimal (bukan GPS).
      expect(isi['lat'], p.lokasi.lat!.toStringAsFixed(2));
      expect(isi['lon'], p.lokasi.lon!.toStringAsFixed(2));
      expect(isi['lat'], matches(RegExp(r'^-?\d+\.\d{2}$')));
      expect(
        isi.keys.any((k) => k.contains('token') || k.contains('key')),
        isFalse,
      );
    });

    test('nilai kosong menjadi teks kosong, bukan "null"', () {
      final p = prakiraan();
      const kosong = EntriPrakiraan(
        waktuLokal: null,
        waktuUtc: null,
        kodeCuaca: null,
        deskripsi: '',
        suhu: null,
        kelembapan: null,
        kecepatanAngin: null,
        arahAngin: '',
        jarakPandang: null,
      );
      final isi = WidgetLayar.susun(
        prakiraan: p,
        entri: kosong,
        bahasa: 'en',
        diperbarui: DateTime.utc(2026),
      );
      for (final k in ['suhu', 'kelembapan', 'angin', 'kode', 'awan']) {
        expect(isi[k], '', reason: k);
      }
      expect(isi.values, isNot(contains('null')));
    });
  });

  group('Mendorong ke widget', () {
    test('simpan dulu, baru segarkan', () async {
      final penyimpan = _PenyimpanMemori();
      final p = prakiraan();
      await WidgetLayar.dorong(
        penyimpan,
        prakiraan: p,
        bahasa: 'id',
        diperbarui: DateTime.utc(2026, 11, 25),
        sekarang: p.hari.first.first.waktuUtc,
      );
      expect(penyimpan.panggilan, ['simpan', 'segarkan']);
      expect(penyimpan.data['ada_data'], '1');
    });

    test('galat penyimpanan tidak pernah dilempar ke aplikasi', () async {
      final p = prakiraan();
      await expectLater(
        WidgetLayar.dorong(
          _PenyimpanRusak(),
          prakiraan: p,
          bahasa: 'id',
          diperbarui: DateTime.utc(2026),
          sekarang: p.hari.first.first.waktuUtc,
        ),
        completes,
      );
    });

    test('prakiraan tanpa entri: tidak menyimpan apa pun', () async {
      final penyimpan = _PenyimpanMemori();
      final kosong = Prakiraan(lokasi: prakiraan().lokasi, hari: const []);
      await WidgetLayar.dorong(
        penyimpan,
        prakiraan: kosong,
        bahasa: 'id',
        diperbarui: DateTime.utc(2026),
      );
      expect(penyimpan.panggilan, isEmpty);
    });
  });

  group('Penyimpan bawaan per platform', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('Android memakai penyimpan nyata, platform lain diam', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(penyimpanWidgetBawaan(), isA<PenyimpanWidgetAndroid>());
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(penyimpanWidgetBawaan(), isA<PenyimpanWidgetDiam>());
    });

    test('nama provider native sesuai namespace aplikasi', () {
      expect(
        PenyimpanWidgetAndroid.namaProvider,
        'com.example.app.WidgetCuacaProvider',
      );
    });
  });

  group('Sinkronisasi dari aplikasi', () {
    testWidgets('setelah cuaca dimuat, data masuk ke penyimpan widget', (
      tester,
    ) async {
      final penyimpan = _PenyimpanMemori();
      await tester.pumpWidget(buatApp(gps: _gps, penyimpanWidget: penyimpan));
      await tester.pumpAndSettle();
      expect(penyimpan.data['ada_data'], '1');
      expect(penyimpan.data['adm4'], isNotEmpty);
      expect(penyimpan.data['suhu'], isNotEmpty);
      expect(penyimpan.data['bahasa'], 'id');
      expect(penyimpan.panggilan, contains('segarkan'));
    });

    testWidgets('tanpa data cuaca sama sekali: widget tidak diisi', (
      tester,
    ) async {
      final penyimpan = _PenyimpanMemori();
      await tester.pumpWidget(
        buatApp(gps: _gps, offline: true, penyimpanWidget: penyimpan),
      );
      await tester.pumpAndSettle();
      expect(penyimpan.data, isEmpty);
    });
  });
}
