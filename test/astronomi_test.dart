import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/astronomi.dart';

const _wib = Duration(hours: 7);

// Jakarta.
const _lat = -6.2088;
const _lon = 106.8456;

int _menit(DateTime? t) => t == null ? -1 : t.hour * 60 + t.minute;

void main() {
  group('Matahari', () {
    test(
      'Jakarta saat ekuinoks: terbit sekitar 06.00, terbenam sekitar 18.05',
      () {
        final a = Astronomi.hitung(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, 3, 20),
          selisih: _wib,
        );
        // Acuan: tabel waktu matahari Jakarta (±6 menit).
        expect(
          _menit(a.matahari.terbit),
          inInclusiveRange(5 * 60 + 48, 6 * 60 + 2),
        );
        expect(
          _menit(a.matahari.terbenam),
          inInclusiveRange(18 * 60 + 0, 18 * 60 + 14),
        );
        expect(
          a.lamaSiang!.inMinutes,
          inInclusiveRange(12 * 60 + 2, 12 * 60 + 14),
        );
      },
    );

    test('di dekat khatulistiwa lama siang hampir tetap sepanjang tahun', () {
      for (final bulan in [1, 4, 7, 10]) {
        final a = Astronomi.hitung(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, bulan, 15),
          selisih: _wib,
        );
        expect(
          a.lamaSiang!.inMinutes,
          inInclusiveRange(11 * 60 + 35, 12 * 60 + 35),
          reason: 'bulan $bulan',
        );
      }
    });

    test('belahan bumi selatan: siang lebih panjang saat Desember di '
        'lintang tinggi', () {
      final des = Astronomi.hitung(
        lat: -37.8,
        lon: 144.96, // Melbourne
        tanggalSetempat: DateTime.utc(2026, 12, 21),
        selisih: const Duration(hours: 11),
      );
      final jun = Astronomi.hitung(
        lat: -37.8,
        lon: 144.96,
        tanggalSetempat: DateTime.utc(2026, 6, 21),
        selisih: const Duration(hours: 10),
      );
      expect(des.lamaSiang!.inHours, greaterThanOrEqualTo(14));
      expect(jun.lamaSiang!.inHours, lessThanOrEqualTo(10));
    });

    test('terbit dan terbenam jatuh pada hari setempat yang diminta', () {
      final a = Astronomi.hitung(
        lat: _lat,
        lon: _lon,
        tanggalSetempat: DateTime.utc(2026, 3, 20, 23, 59),
        selisih: _wib,
      );
      expect(a.matahari.terbit!.day, 20);
      expect(a.matahari.terbenam!.day, 20);
    });
  });

  group('Bulan', () {
    test(
      'bulan baru (17 Feb 2026): hampir tak terang, terbit dekat matahari',
      () {
        final a = Astronomi.hitung(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, 2, 17),
          selisih: Duration.zero,
        );
        expect(a.terangBulan, lessThan(.02));
        expect(a.fase, FaseBulan.baru);
      },
    );

    test('purnama (3 Mar 2026): hampir penuh', () {
      final a = Astronomi.hitung(
        lat: _lat,
        lon: _lon,
        tanggalSetempat: DateTime.utc(2026, 3, 3),
        selisih: Duration.zero,
      );
      expect(a.terangBulan, greaterThan(.98));
      expect(a.fase, FaseBulan.purnama);
    });

    test('purnama terbit sekitar matahari terbenam, bulan baru sekitar '
        'matahari terbit (Jakarta)', () {
      final purnama = Astronomi.hitung(
        lat: _lat,
        lon: _lon,
        tanggalSetempat: DateTime.utc(2026, 3, 3),
        selisih: _wib,
      );
      final selisihPurnama =
          _menit(purnama.bulan.terbit) - _menit(purnama.matahari.terbenam);
      expect(selisihPurnama.abs(), lessThan(90));

      final baru = Astronomi.hitung(
        lat: _lat,
        lon: _lon,
        tanggalSetempat: DateTime.utc(2026, 2, 17),
        selisih: _wib,
      );
      final selisihBaru =
          _menit(baru.bulan.terbit) - _menit(baru.matahari.terbit);
      expect(selisihBaru.abs(), lessThan(90));
    });

    test('fase maju berurutan sepanjang satu bulan sinodis', () {
      final urut = <FaseBulan>[];
      for (var hari = 0; hari < 30; hari++) {
        final f = Astronomi.hitung(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, 2, 17).add(Duration(days: hari)),
          selisih: _wib,
        ).fase;
        if (urut.isEmpty || urut.last != f) urut.add(f);
      }
      // Dari baru sampai kembali ke baru, tiap fase muncul sekali berurutan.
      expect(urut.first, FaseBulan.baru);
      for (var i = 1; i < urut.length; i++) {
        expect(urut[i].index, (urut[i - 1].index + 1) % 8);
      }
      expect(urut.length, greaterThanOrEqualTo(8));
    });

    test('bulan bisa tidak terbit atau terbenam pada satu hari: nilainya '
        'null, bukan error', () {
      var adaNull = false;
      for (var hari = 0; hari < 30; hari++) {
        final a = Astronomi.hitung(
          lat: _lat,
          lon: _lon,
          tanggalSetempat: DateTime.utc(2026, 3, 1).add(Duration(days: hari)),
          selisih: _wib,
        );
        if (a.bulan.terbit == null || a.bulan.terbenam == null) adaNull = true;
      }
      expect(adaNull, isTrue);
    });
  });

  group('Titik embun', () {
    test('nilai acuan rumus Magnus', () {
      // 30 °C, 70% → sekitar 23,9 °C.
      expect(Astronomi.titikEmbun(30, 70), closeTo(23.9, .3));
      // 20 °C, 50% → sekitar 9,3 °C.
      expect(Astronomi.titikEmbun(20, 50), closeTo(9.3, .3));
    });

    test('kelembapan 100% sama dengan suhu, tidak pernah di atas suhu', () {
      expect(Astronomi.titikEmbun(27, 100), closeTo(27, .01));
      for (final rh in [10, 40, 80, 99]) {
        expect(Astronomi.titikEmbun(27, rh), lessThan(27));
      }
    });

    test('kelembapan di luar rentang dijepit, tidak menghasilkan NaN', () {
      expect(Astronomi.titikEmbun(25, 0).isFinite, isTrue);
      expect(Astronomi.titikEmbun(25, 130).isFinite, isTrue);
    });
  });
}
