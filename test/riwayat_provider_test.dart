import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/models/gempa.dart';
import 'package:app/providers/riwayat_gempa_provider.dart';
import 'package:app/services/riwayat_gempa_repository.dart';

// Pengguna di Jakarta.
const jakarta = (lat: -6.2088, lon: 106.8456);

Gempa gempa(
  DateTime waktu, {
  required double lat,
  required double lon,
  required String mag,
  String wilayah = 'Wilayah uji',
}) => Gempa(
  tanggal: '',
  jam: '',
  koordinat: '$lat,$lon',
  lintang: '',
  bujur: '',
  magnitudo: mag,
  kedalaman: '10 km',
  wilayah: wilayah,
  potensi: '',
  dirasakan: '',
  shakemap: '',
  waktuUtc: waktu.toUtc(),
  lat: lat,
  lon: lon,
);

BarisRiwayat baris(Gempa g) => BarisRiwayat(
  gempa: g,
  dicatat: DateTime(2026, 11, 20),
  diperbarui: DateTime(2026, 11, 20),
  sumber: 'bmkg',
);

/// Penyimpanan yang gagal saat dibaca.
class _StoreGagalBaca extends MemoriRiwayatStore {
  @override
  Future<List<BarisRiwayat>> semua() async => throw StateError('rusak');
}

void main() {
  // Tanggal ditulis sebagai waktu LOKAL tengah hari supaya tidak bergantung
  // pada zona waktu mesin pengujian.
  final dekat = baris(
    gempa(
      DateTime(2026, 11, 10, 12),
      lat: -6.5,
      lon: 106.9,
      mag: '4.2',
      wilayah: 'Selatan Bogor',
    ),
  ); // ± 34 km
  final sedang = baris(
    gempa(
      DateTime(2026, 11, 15, 12),
      lat: -7.8,
      lon: 110.4,
      mag: '5.4',
      wilayah: 'Yogyakarta',
    ),
  ); // ± 430 km
  final jauh = baris(
    gempa(
      DateTime(2026, 11, 18, 12),
      lat: 3.1,
      lon: 126.6,
      mag: '6.3',
      wilayah: 'Maluku Utara',
    ),
  ); // ± 2.300 km
  // Terbaru di atas, seperti keluaran penyimpanan.
  final semua = [jauh, sedang, dekat];

  group('Filter riwayat', () {
    List<double> mags(List<BarisRiwayat> b) => [
      for (final x in b) x.gempa.magnitudoAngka!,
    ];

    test('tanpa saringan: semua data', () {
      final hasil = RiwayatGempaProvider.saring(
        semua,
        const FilterRiwayat(),
        jakarta,
      );
      expect(mags(hasil), [6.3, 5.4, 4.2]);
    });

    test('magnitudo minimum', () {
      List<double> f(double m) => mags(
        RiwayatGempaProvider.saring(
          semua,
          FilterRiwayat(magnitudoMin: m),
          jakarta,
        ),
      );
      expect(f(4.0), [6.3, 5.4, 4.2]);
      expect(f(5.0), [6.3, 5.4]);
      expect(f(6.0), [6.3]);
      expect(f(7.0), isEmpty);
    });

    test('rentang tanggal (kedua ujung ikut)', () {
      List<double> f(DateTime? a, DateTime? b) => mags(
        RiwayatGempaProvider.saring(
          semua,
          FilterRiwayat(mulai: a, selesai: b),
          jakarta,
        ),
      );
      expect(f(DateTime(2026, 11, 15), DateTime(2026, 11, 18)), [6.3, 5.4]);
      expect(f(DateTime(2026, 11, 16), null), [6.3]);
      expect(f(null, DateTime(2026, 11, 10)), [4.2]);
      expect(f(DateTime(2026, 11, 11), DateTime(2026, 11, 14)), isEmpty);
    });

    test('jarak maksimum dari posisi pengguna', () {
      List<double> f(double km) => mags(
        RiwayatGempaProvider.saring(
          semua,
          FilterRiwayat(jarakMaksKm: km),
          jakarta,
        ),
      );
      expect(f(100), [4.2]);
      expect(f(500), [5.4, 4.2]);
      expect(f(5000), [6.3, 5.4, 4.2]);
      expect(f(10), isEmpty);
    });

    test('tanpa lokasi: saringan jarak diabaikan, bukan mengosongkan', () {
      final hasil = RiwayatGempaProvider.saring(
        semua,
        const FilterRiwayat(jarakMaksKm: 100),
        null,
      );
      expect(mags(hasil), [6.3, 5.4, 4.2]);
    });

    test('gabungan: magnitudo + tanggal + jarak', () {
      final hasil = RiwayatGempaProvider.saring(
        semua,
        FilterRiwayat(
          magnitudoMin: 5.0,
          mulai: DateTime(2026, 11, 12),
          jarakMaksKm: 1000,
        ),
        jakarta,
      );
      expect(mags(hasil), [5.4]);

      // Satu syarat tidak terpenuhi mengosongkan hasil.
      final kosong = RiwayatGempaProvider.saring(
        semua,
        const FilterRiwayat(magnitudoMin: 6.0, jarakMaksKm: 1000),
        jakarta,
      );
      expect(kosong, isEmpty);
    });

    test('kata kunci wilayah tidak peka huruf besar', () {
      final hasil = RiwayatGempaProvider.saring(
        semua,
        const FilterRiwayat(kataKunci: 'yogya'),
        jakarta,
      );
      expect(mags(hasil), [5.4]);
    });

    test('penanda aktif dan jumlah saringan', () {
      expect(const FilterRiwayat().aktif, isFalse);
      expect(const FilterRiwayat(kataKunci: ' ').aktif, isFalse);
      final f = FilterRiwayat(
        magnitudoMin: 5,
        jarakMaksKm: 100,
        mulai: DateTime(2026, 11, 1),
      );
      expect(f.aktif, isTrue);
      expect(f.jumlahSaringan, 3);
      expect(f.tanpa(magnitudo: true).jumlahSaringan, 2);
      expect(f.tanpa(tanggal: true, jarak: true).jumlahSaringan, 1);
    });
  });

  group('Statistik riwayat', () {
    test('jumlah, magnitudo terbesar, dan gempa terdekat', () {
      final s = RiwayatGempaProvider.hitung(semua, jakarta);
      expect(s.jumlah, 3);
      expect(s.terbesar!.magnitudoAngka, 6.3);
      expect(s.terdekat!.wilayah, 'Selatan Bogor');
      expect(s.jarakTerdekatKm, closeTo(34, 3));
      expect(s.adaLokasi, isTrue);
    });

    test('statistik dihitung dari hasil saringan, bukan seluruh data', () {
      final disaring = RiwayatGempaProvider.saring(
        semua,
        const FilterRiwayat(magnitudoMin: 5.0),
        jakarta,
      );
      final s = RiwayatGempaProvider.hitung(disaring, jakarta);
      expect(s.jumlah, 2);
      expect(s.terbesar!.magnitudoAngka, 6.3);
      expect(s.terdekat!.wilayah, 'Yogyakarta');
    });

    test('daftar kosong: jumlah 0 dan tanpa terbesar/terdekat', () {
      final s = RiwayatGempaProvider.hitung(const [], jakarta);
      expect(s.jumlah, 0);
      expect(s.terbesar, isNull);
      expect(s.terdekat, isNull);
      expect(s.jarakTerdekatKm, isNull);
    });

    test('tanpa lokasi: terdekat kosong, terbesar tetap ada', () {
      final s = RiwayatGempaProvider.hitung(semua, null);
      expect(s.adaLokasi, isFalse);
      expect(s.terdekat, isNull);
      expect(s.jarakTerdekatKm, isNull);
      expect(s.terbesar!.magnitudoAngka, 6.3);
      expect(s.jumlah, 3);
    });

    test('rentang data: tertua sampai terbaru yang benar-benar ada', () {
      final r = RiwayatGempaProvider.rentangDari(semua)!;
      expect(r.tertua, DateTime(2026, 11, 10, 12));
      expect(r.terbaru, DateTime(2026, 11, 18, 12));
      expect(RiwayatGempaProvider.rentangDari(const []), isNull);
    });
  });

  group('RiwayatGempaProvider', () {
    late RiwayatGempaRepository repo;
    late ValueNotifier<int> pemicu;
    PosisiPengguna posisi = jakarta;
    final sekarang = DateTime(2026, 11, 20, 12);

    RiwayatGempaProvider buat([RiwayatGempaRepository? r]) =>
        RiwayatGempaProvider(
          r ?? repo,
          posisi: () => posisi,
          ubahPosisi: pemicu,
        );

    setUp(() {
      posisi = jakarta;
      pemicu = ValueNotifier(0);
      repo = RiwayatGempaRepository(
        MemoriRiwayatStore(),
        sekarang: () => sekarang,
      );
    });

    test('memuat lalu siap; kosong bila belum ada data', () async {
      final p = buat();
      expect(p.status, StatusRiwayat.memuat);
      await p.muat();
      expect(p.status, StatusRiwayat.siap);
      expect(p.semua, isEmpty);
      expect(p.rentangData, isNull);
      expect(p.jumlahTersimpan, 0);
    });

    test('data yang dicatat muncul otomatis tanpa memuat ulang', () async {
      final p = buat();
      await p.muat();
      await repo.catat([jauh.gempa, dekat.gempa]);
      await pumpEventQueue();
      expect(p.jumlahTersimpan, 2);
      expect(p.statistik.jumlah, 2);
      expect(p.rentangData, isNotNull);
    });

    test('mengganti filter menghitung ulang hasil dan statistik', () async {
      await repo.catat([jauh.gempa, sedang.gempa, dekat.gempa]);
      final p = buat();
      await p.muat();
      expect(p.hasil.length, 3);

      p.aturFilter(const FilterRiwayat(magnitudoMin: 5.0));
      expect(p.hasil.length, 2);
      expect(p.statistik.jumlah, 2);
      // Jumlah tersimpan tidak ikut berubah: itu seluruh isi database.
      expect(p.jumlahTersimpan, 3);

      p.setelUlangFilter();
      expect(p.hasil.length, 3);
    });

    test(
      'posisi berubah: jarak dan saringan jarak ikut dihitung ulang',
      () async {
        await repo.catat([jauh.gempa, sedang.gempa, dekat.gempa]);
        final p = buat();
        await p.muat();
        p.aturFilter(const FilterRiwayat(jarakMaksKm: 100));
        expect(p.hasil.length, 1);
        expect(p.adaLokasi, isTrue);

        posisi = null; // lokasi hilang
        pemicu.value++;
        expect(p.adaLokasi, isFalse);
        expect(p.hasil.length, 3, reason: 'saringan jarak diabaikan');
        expect(p.statistik.adaLokasi, isFalse);
        expect(p.statistik.terdekat, isNull);
      },
    );

    test('penyimpanan gagal dibaca: status gagal, tidak crash', () async {
      final rusak = RiwayatGempaRepository(_StoreGagalBaca());
      final p = buat(rusak);
      await p.muat();
      expect(p.status, StatusRiwayat.gagal);
      expect(p.semua, isEmpty);
    });
  });
}
