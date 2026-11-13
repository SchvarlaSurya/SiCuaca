import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/format.dart';
import 'package:app/core/geo.dart';
import 'package:app/core/strings.dart';
import 'package:app/models/gempa.dart';

Map<String, dynamic> _json(String nama) =>
    jsonDecode(File('test/fixtures/$nama').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('Gempa dari respons asli BMKG', () {
    test('autogempa.json: satu objek lengkap dengan Shakemap', () {
      final g = Gempa.fromAutoGempaJson(_json('autogempa.json'));
      expect(g.magnitudo, '4.1');
      expect(g.magnitudoAngka, 4.1);
      expect(g.waktuUtc, DateTime.utc(2026, 11, 13, 7, 31, 39));
      expect(g.lat, -5.56);
      expect(g.lon, 102.24);
      expect(g.kedalaman, '24 km');
      expect(g.potensi, isNotEmpty);
      expect(g.dirasakan, 'II - III Enggano');
      expect(
        g.shakemapUrl,
        'https://data.bmkg.go.id/DataMKG/TEWS/20261113143139.mmi.jpg',
      );
    });

    test('gempaterkini.json: 15 gempa M5+, tanpa Dirasakan dan Shakemap', () {
      final daftar = Gempa.daftarDariJson(_json('gempaterkini.json'));
      expect(daftar, hasLength(15));
      expect(daftar.every((g) => g.magnitudoAngka! >= 5), isTrue);
      expect(daftar.every((g) => g.dirasakan.isEmpty), isTrue);
      expect(daftar.every((g) => g.shakemap.isEmpty), isTrue);
      expect(daftar.first.potensi, 'Tidak berpotensi tsunami');
      // Shakemap diturunkan dari Tanggal + Jam.
      expect(
        daftar.first.shakemapUrl,
        'https://data.bmkg.go.id/DataMKG/TEWS/20261110225137.mmi.jpg',
      );
      // Urut terbaru dulu.
      for (var i = 1; i < daftar.length; i++) {
        expect(
          daftar[i - 1].waktuUtc!.isAfter(daftar[i].waktuUtc!) ||
              daftar[i - 1].waktuUtc == daftar[i].waktuUtc,
          isTrue,
        );
      }
    });

    test('gempadirasakan.json: ada Dirasakan, tanpa Potensi', () {
      final daftar = Gempa.daftarDariJson(_json('gempadirasakan.json'));
      expect(daftar, hasLength(15));
      expect(daftar.every((g) => g.dirasakan.isNotEmpty), isTrue);
      expect(daftar.every((g) => g.potensi.isEmpty), isTrue);
      expect(daftar.first.wilayah, contains('Enggano'));
    });

    test('field hilang, null, atau elemen rusak tidak membuat crash', () {
      final daftar = Gempa.daftarDariJson(const {
        'Infogempa': {
          'gempa': [
            {'Magnitude': null, 'DateTime': 'bukan tanggal'},
            'bukan objek',
            {
              'Magnitude': 5,
              'Coordinates': 'rusak',
              'Lintang': '3.10 LU',
              'Bujur': '98.20 BB',
            },
          ],
        },
      });
      expect(daftar, hasLength(2));
      final rusak = daftar.firstWhere((g) => g.magnitudo.isEmpty);
      expect(rusak.waktuUtc, isNull);
      expect(rusak.lat, isNull);
      expect(rusak.shakemapUrl, isNull);
      final cadangan = daftar.firstWhere((g) => g.magnitudo == '5');
      expect(cadangan.lat, 3.10);
      expect(cadangan.lon, -98.20);
    });

    test('tanda koordinat: LS negatif, LU positif', () {
      final g = Gempa.fromJson(const {'Coordinates': '2.43,96.15'});
      expect(g.lat, 2.43);
      expect(g.lon, 96.15);
      final s = Gempa.fromJson(const {'Coordinates': '-8.22,116.77'});
      expect(s.lat, -8.22);
    });

    test('struktur tanpa Infogempa melempar FormatException', () {
      expect(() => Gempa.daftarDariJson(const {}), throwsFormatException);
      expect(
        () => Gempa.fromAutoGempaJson(const {
          'Infogempa': {'gempa': null},
        }),
        throwsFormatException,
      );
    });
  });

  group('Haversine', () {
    test('titik yang sama = 0 km', () {
      expect(jarakKmAntara(-6.2088, 106.8456, -6.2088, 106.8456), 0);
    });

    test('Jakarta ke Bandung sekitar 116 km', () {
      expect(
        jarakKmAntara(-6.2088, 106.8456, -6.9175, 107.6191),
        closeTo(116, 2),
      );
    });
  });

  group('Format', () {
    test('waktu relatif', () {
      final now = DateTime.utc(2026, 11, 13, 12);
      expect(Format.waktuRelatif(now, now), Str.baruSaja);
      expect(
        Format.waktuRelatif(now.subtract(const Duration(minutes: 12)), now),
        Str.menitLalu(12),
      );
      expect(
        Format.waktuRelatif(now.subtract(const Duration(hours: 3)), now),
        Str.jamLalu(3),
      );
      expect(
        Format.waktuRelatif(now.subtract(const Duration(days: 2)), now),
        Str.hariLalu(2),
      );
    });

    test('jarak dan zona waktu', () {
      expect(Format.jarak(8.43), '8,4');
      expect(Format.jarak(1234.4), '1.234');
      expect(Format.zonaPerangkat(const Duration(hours: 7)), 'WIB');
      expect(Format.zonaPerangkat(const Duration(hours: 9)), 'WIT');
      expect(Format.zonaPerangkat(const Duration(hours: -5)), 'UTC-5');
    });
  });
}
