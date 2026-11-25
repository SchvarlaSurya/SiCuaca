import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/uv.dart';

// Jakarta.
const _lat = -6.2088;
const _lon = 106.8456;
const _wib = Duration(hours: 7);

DateTime _utc(int tahun, int bulan, int hari, int jamWib, [int menit = 0]) =>
    DateTime.utc(tahun, bulan, hari, jamWib, menit).subtract(_wib);

void main() {
  group('Kategori', () {
    test('batas WHO dengan pembulatan ke bilangan bulat', () {
      expect(Uv.kategori(0), KategoriUv.rendah);
      expect(Uv.kategori(2.4), KategoriUv.rendah);
      expect(Uv.kategori(2.6), KategoriUv.sedang);
      expect(Uv.kategori(5.4), KategoriUv.sedang);
      expect(Uv.kategori(5.6), KategoriUv.tinggi);
      expect(Uv.kategori(7.4), KategoriUv.tinggi);
      expect(Uv.kategori(7.6), KategoriUv.sangatTinggi);
      expect(Uv.kategori(10.4), KategoriUv.sangatTinggi);
      expect(Uv.kategori(10.6), KategoriUv.ekstrem);
      expect(Uv.kategori(14), KategoriUv.ekstrem);
    });
  });

  group('Langit cerah', () {
    test('malam hari nol, tidak negatif', () {
      expect(
        Uv.langitCerah(lat: _lat, lon: _lon, utc: _utc(2026, 3, 20, 22)),
        0,
      );
      expect(
        Uv.langitCerah(lat: _lat, lon: _lon, utc: _utc(2026, 3, 20, 3)),
        0,
      );
    });

    test(
      'tengah hari di khatulistiwa: kategori sangat tinggi sampai ekstrem',
      () {
        final uvi = Uv.langitCerah(
          lat: _lat,
          lon: _lon,
          utc: _utc(2026, 3, 20, 11, 50),
        );
        expect(uvi, inInclusiveRange(10, 16));
        expect(
          Uv.kategori(uvi),
          anyOf(KategoriUv.sangatTinggi, KategoriUv.ekstrem),
        );
      },
    );

    test(
      'naik menuju siang lalu turun, simetris di sekitar siang matahari',
      () {
        double di(int jam, [int m = 0]) => Uv.langitCerah(
          lat: _lat,
          lon: _lon,
          utc: _utc(2026, 3, 20, jam, m),
        );
        expect(di(8), lessThan(di(10)));
        expect(di(10), lessThan(di(11, 50)));
        expect(di(11, 50), greaterThan(di(14)));
        expect(di(14), greaterThan(di(16)));
      },
    );

    test('lintang tinggi di musim dingin jauh lebih rendah', () {
      final tropis = Uv.langitCerah(
        lat: -6.2,
        lon: 107,
        utc: DateTime.utc(2026, 6, 21, 5),
      );
      final dingin = Uv.langitCerah(
        lat: 55,
        lon: 12,
        utc: DateTime.utc(2026, 12, 21, 11),
      );
      expect(dingin, lessThan(1));
      expect(tropis, greaterThan(5));
    });
  });

  group('Ozon dan awan', () {
    test('ozon klimatologi: tropis 260, naik ke lintang menengah', () {
      expect(Uv.ozon(0), 260);
      expect(Uv.ozon(-10), 260);
      expect(Uv.ozon(45), closeTo(300, 1));
      expect(Uv.ozon(80), lessThanOrEqualTo(320));
    });

    test(
      'faktor awan: 1 saat cerah, melemah mulai awan tebal, tanpa data 1',
      () {
        expect(Uv.faktorAwan(null), 1);
        expect(Uv.faktorAwan(0), 1);
        expect(Uv.faktorAwan(30), greaterThan(.97));
        expect(Uv.faktorAwan(60), greaterThan(.8));
        expect(Uv.faktorAwan(100), closeTo(.25, .001));
        var terakhir = 2.0;
        for (var n = 0; n <= 100; n += 10) {
          expect(Uv.faktorAwan(n), lessThanOrEqualTo(terakhir));
          terakhir = Uv.faktorAwan(n);
        }
        // Nilai di luar rentang dijepit.
        expect(Uv.faktorAwan(150), closeTo(.25, .001));
        expect(Uv.faktorAwan(-5), 1);
      },
    );

    test('mendung menurunkan perkiraan dibanding cerah', () {
      final t = _utc(2026, 3, 20, 12);
      final cerah = Uv.perkiraan(
        lat: _lat,
        lon: _lon,
        utc: t,
        tutupanAwanPersen: 0,
      );
      final mendung = Uv.perkiraan(
        lat: _lat,
        lon: _lon,
        utc: t,
        tutupanAwanPersen: 100,
      );
      expect(mendung, lessThan(cerah * .3));
      expect(Uv.perkiraan(lat: _lat, lon: _lon, utc: t), closeTo(cerah, .0001));
    });
  });

  group('Puncak hari', () {
    test('cerah: puncak sekitar tengah hari setempat', () {
      final titik = [
        for (final jam in [0, 3, 6, 9, 12, 15, 18, 21])
          (utc: _utc(2026, 3, 20, jam), awan: 0 as int?),
      ];
      final p = Uv.puncak(
        lat: _lat,
        lon: _lon,
        tanggalSetempat: DateTime.utc(2026, 3, 20, 9),
        selisih: _wib,
        titikAwan: titik,
      )!;
      expect(p.waktuSetempat.hour, inInclusiveRange(11, 13));
      expect(p.waktuSetempat.day, 20);
      expect(p.uvi, greaterThan(10));
    });

    test(
      'mendung di siang hari menggeser puncak ke waktu yang lebih cerah',
      () {
        // Awan penuh pukul 12, cerah pukul 9 dan 15: puncak tidak jatuh di 12.
        final titik = [
          (utc: _utc(2026, 3, 20, 9), awan: 0 as int?),
          (utc: _utc(2026, 3, 20, 12), awan: 100 as int?),
          (utc: _utc(2026, 3, 20, 15), awan: 0 as int?),
        ];
        final p = Uv.puncak(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, 3, 20),
          selisih: _wib,
          titikAwan: titik,
        )!;
        expect(p.waktuSetempat.hour, isNot(12));
      },
    );

    test('tanpa titik prakiraan: null', () {
      expect(
        Uv.puncak(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, 3, 20),
          selisih: _wib,
          titikAwan: const [],
        ),
        isNull,
      );
    });
  });
}
