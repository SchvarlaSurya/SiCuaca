import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:app/models/gempa.dart';
import 'package:app/services/riwayat_gempa_repository.dart';
import 'package:app/services/riwayat_gempa_sqflite.dart';

/// Gempa uji. [waktu] dalam UTC.
Gempa gempaUji(
  DateTime waktu, {
  double lat = -5.56,
  double lon = 102.24,
  String mag = '5.0',
  String kedalaman = '10 km',
  String dirasakan = '',
  String wilayah = 'Pusat gempa uji',
  String? koordinat,
}) => Gempa(
  tanggal: '1 Jan 2026',
  jam: '10:00:00 WIB',
  koordinat: koordinat ?? '$lat,$lon',
  lintang: '',
  bujur: '',
  magnitudo: mag,
  kedalaman: kedalaman,
  wilayah: wilayah,
  potensi: 'Tidak berpotensi tsunami',
  dirasakan: dirasakan,
  shakemap: '',
  waktuUtc: waktu,
  lat: lat,
  lon: lon,
);

/// Penyimpanan yang selalu gagal, untuk menguji "tidak crash".
class _StoreRusak implements RiwayatGempaStore {
  @override
  Future<BarisRiwayat?> ambil(String kunci) async => throw StateError('rusak');
  @override
  Future<void> simpan(String kunci, BarisRiwayat baris) async =>
      throw StateError('rusak');
  @override
  Future<List<BarisRiwayat>> semua() async => throw StateError('rusak');
  @override
  Future<int> hapusSebelum(DateTime batas) async => throw StateError('rusak');
  @override
  Future<int> hapusLebihDari(int maks) async => throw StateError('rusak');
  @override
  Future<void> hapusSemua() async => throw StateError('rusak');
  @override
  Future<String?> meta(String kunci) async => throw StateError('rusak');
  @override
  Future<void> setMeta(String kunci, String nilai) async =>
      throw StateError('rusak');
}

void main() {
  sqfliteFfiInit();
  late Directory tmp;
  final sqlitePenutup = <SqfliteRiwayatStore>[];

  setUpAll(() => tmp = Directory.systemTemp.createTempSync('riwayat_gempa_'));
  tearDownAll(() async {
    for (final s in sqlitePenutup) {
      await s.tutup();
    }
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });

  var nomor = 0;
  SqfliteRiwayatStore sqlite({String? berkas}) {
    final s = SqfliteRiwayatStore(
      pabrik: databaseFactoryFfi,
      lokasi: berkas ?? '${tmp.path}/uji_${nomor++}.db',
    );
    sqlitePenutup.add(s);
    return s;
  }

  // Semua aturan dijalankan pada kedua penyimpanan: hasilnya harus sama.
  final penyimpanan = <String, RiwayatGempaStore Function()>{
    'memori': MemoriRiwayatStore.new,
    'sqlite': sqlite,
  };

  for (final nama in penyimpanan.keys) {
    group('Riwayat gempa [$nama]', () {
      var jam = DateTime.utc(2026, 11, 20, 12);
      late RiwayatGempaRepository repo;

      setUp(() {
        jam = DateTime.utc(2026, 11, 20, 12);
        repo = RiwayatGempaRepository(
          penyimpanan[nama]!(),
          sekarang: () => jam,
        );
      });

      DateTime lalu(Duration d) => jam.subtract(d);

      test('simpan satu data lalu baca kembali', () async {
        final g = gempaUji(
          lalu(const Duration(hours: 2)),
          mag: '5.4',
          dirasakan: 'II Tahuna',
        );
        final hasil = await repo.catat([g]);
        expect(hasil.baru, 1);

        final baris = await repo.baris();
        expect(baris.length, 1);
        final a = baris.single.gempa;
        expect(a.magnitudo, '5.4');
        expect(a.magnitudoAngka, 5.4);
        expect(a.dirasakan, 'II Tahuna');
        expect(a.wilayah, 'Pusat gempa uji');
        expect(a.waktuUtc, g.waktuUtc);
        expect(a.lat, -5.56);
        expect(a.lon, 102.24);
        expect(baris.single.sumber, 'bmkg');
      });

      test('duplikasi: data sama dicatat dua kali tetap satu baris', () async {
        final g = gempaUji(lalu(const Duration(hours: 1)));
        expect((await repo.catat([g])).baru, 1);
        final lagi = await repo.catat([g, g]);
        expect(lagi.baru, 0);
        expect(lagi.diperbarui, 0);
        expect((await repo.baris()).length, 1);
      });

      test(
        'kunci: format koordinat yang sedikit beda tetap satu gempa',
        () async {
          final waktu = lalu(const Duration(hours: 1));
          await repo.catat([gempaUji(waktu, koordinat: '-5.56,102.24')]);
          await repo.catat([
            gempaUji(
              waktu,
              lat: -5.5600001,
              lon: 102.2400004,
              koordinat: '-5.5600,102.2400',
            ),
          ]);
          expect((await repo.baris()).length, 1);
        },
      );

      test('revisi magnitudo: baris di-UPDATE, bukan baris baru', () async {
        final waktu = lalu(const Duration(hours: 3));
        await repo.catat([gempaUji(waktu, mag: '5.0', kedalaman: '10 km')]);
        final pertama = (await repo.baris()).single;

        jam = jam.add(const Duration(minutes: 20));
        final hasil = await repo.catat([
          gempaUji(waktu, mag: '5.3', kedalaman: '12 km'),
        ]);
        expect(hasil.baru, 0);
        expect(hasil.diperbarui, 1);

        final baris = await repo.baris();
        expect(baris.length, 1, reason: 'tidak boleh ada baris baru');
        expect(baris.single.gempa.magnitudo, '5.3');
        expect(baris.single.gempa.magnitudoAngka, 5.3);
        expect(baris.single.gempa.kedalaman, '12 km');
        expect(baris.single.dicatat, pertama.dicatat);
        expect(baris.single.diperbarui.isAfter(pertama.diperbarui), isTrue);
      });

      test('isi baru yang kosong tidak menimpa isi lama', () async {
        final waktu = lalu(const Duration(hours: 1));
        await repo.catat([gempaUji(waktu, dirasakan: 'IV Tiakur')]);
        // Notifikasi tidak membawa "dirasakan".
        final hasil = await repo.catat([gempaUji(waktu)], sumber: 'notifikasi');
        expect(hasil.diperbarui, 0);
        final baris = await repo.baris();
        expect(baris.single.gempa.dirasakan, 'IV Tiakur');
        expect(baris.single.sumber, 'bmkg');
      });

      test('tanpa waktu atau koordinat yang terbaca tidak disimpan', () async {
        const tanpaWaktu = Gempa(
          tanggal: 'x',
          jam: 'y',
          koordinat: '-5,100',
          lintang: '',
          bujur: '',
          magnitudo: '5.0',
          kedalaman: '',
          wilayah: '',
          potensi: '',
          dirasakan: '',
          shakemap: '',
          lat: -5,
          lon: 100,
        );
        final tanpaKoordinat = Gempa(
          tanggal: 'x',
          jam: 'y',
          koordinat: '',
          lintang: '',
          bujur: '',
          magnitudo: '5.0',
          kedalaman: '',
          wilayah: '',
          potensi: '',
          dirasakan: '',
          shakemap: '',
          waktuUtc: lalu(const Duration(hours: 1)),
        );
        final hasil = await repo.catat([tanpaWaktu, tanpaKoordinat]);
        expect(hasil.baru, 0);
        expect(hasil.diabaikan, 2);
        expect(await repo.baris(), isEmpty);
      });

      test('gempa lebih tua dari 30 hari tidak disimpan', () async {
        final hasil = await repo.catat([
          gempaUji(lalu(const Duration(days: 31)), lat: -1),
          gempaUji(lalu(const Duration(days: 29)), lat: -2),
        ]);
        expect(hasil.baru, 1);
        expect(hasil.diabaikan, 1);
      });

      test('pembersihan: data yang melewati 30 hari dibuang', () async {
        await repo.catat([
          gempaUji(lalu(const Duration(days: 29)), lat: -1),
          gempaUji(lalu(const Duration(days: 10)), lat: -2),
          gempaUji(lalu(const Duration(hours: 5)), lat: -3),
        ]);
        expect((await repo.baris()).length, 3);

        jam = jam.add(const Duration(days: 2)); // yang 29 hari jadi 31 hari
        final dibuang = await repo.bersihkan();
        expect(dibuang, 1);
        final sisa = await repo.baris();
        expect(sisa.length, 2);
        expect(sisa.every((b) => b.gempa.lat != -1), isTrue);
      });

      test('pembatasan: lebih dari 100 data menyisakan 100 terbaru', () async {
        final banyak = [
          for (var i = 0; i < 120; i++)
            gempaUji(
              lalu(Duration(minutes: 10 * (i + 1))),
              lat: -10 + i * 0.05,
              mag: '5.${i % 10}',
            ),
        ];
        final hasil = await repo.catat(banyak);
        expect(hasil.baru, 120);

        final baris = await repo.baris();
        expect(baris.length, RiwayatGempaRepository.maksBaris);
        // Terbaru di atas; 20 yang terlama sudah dibuang.
        expect(baris.first.gempa.waktuUtc, banyak.first.waktuUtc);
        expect(baris.last.gempa.waktuUtc, banyak[99].waktuUtc);
      });

      test(
        'pembersihan saat mulai menerapkan batas yang lebih ketat',
        () async {
          await repo.catat([
            for (var i = 0; i < 100; i++)
              gempaUji(lalu(Duration(hours: i + 1)), lat: -10 + i * 0.05),
          ]);
          expect((await repo.baris()).length, 100);

          jam = jam.add(const Duration(days: 28));
          // Batas usia (30 hari) yang lebih ketat daripada batas 100 baris.
          final dibuang = await repo.bersihkan();
          expect(dibuang, greaterThan(0));
          final sisa = await repo.baris();
          expect(sisa.length, lessThan(100));
          final batas = jam.subtract(const Duration(days: 30));
          expect(sisa.every((b) => !b.gempa.waktuUtc!.isBefore(batas)), isTrue);
        },
      );

      test('impor data lama: satu kali, lalu dianggap selesai', () async {
        final lama = [
          gempaUji(lalu(const Duration(days: 3)), lat: -1),
          gempaUji(lalu(const Duration(days: 4)), lat: -2),
        ];
        expect(await repo.imporDariLama(lama), isTrue);
        expect((await repo.baris()).length, 2);
        expect((await repo.baris()).first.sumber, 'impor');

        // Panggilan kedua tidak mengimpor ulang.
        await repo.hapusSemua();
        expect(await repo.imporDariLama(lama), isTrue);
        expect(await repo.baris(), isEmpty);
      });

      test('pendengar diberi tahu hanya saat isi berubah', () async {
        var n = 0;
        repo.addListener(() => n++);
        final g = gempaUji(lalu(const Duration(hours: 1)));
        await repo.catat([g]);
        expect(n, 1);
        await repo.catat([g]); // tidak ada perubahan
        expect(n, 1);
        await repo.catat([gempaUji(g.waktuUtc!, mag: '6.0')]);
        expect(n, 2);
      });
    });
  }

  group('Riwayat gempa: penyimpanan gagal tidak membuat crash', () {
    test('semua operasi aman, hasilnya kosong', () async {
      final repo = RiwayatGempaRepository(_StoreRusak());
      final g = gempaUji(DateTime.now().toUtc());
      expect((await repo.catat([g])).adaPerubahan, isFalse);
      expect(await repo.baris(), isEmpty);
      expect(await repo.bersihkan(), 0);
      await repo.hapusSemua();
      await expectLater(repo.barisAtauGalat(), throwsStateError);
    });

    test(
      'impor lama yang gagal mengembalikan false (data lama dibiarkan)',
      () async {
        final repo = RiwayatGempaRepository(_StoreRusak());
        expect(
          await repo.imporDariLama([gempaUji(DateTime.now().toUtc())]),
          isFalse,
        );
      },
    );
  });

  group('Riwayat gempa: SQLite', () {
    test(
      'skema versi 1 dan data bertahan setelah ditutup dan dibuka lagi',
      () async {
        final berkas = '${tmp.path}/bertahan.db';
        final sekarang = DateTime.utc(2026, 11, 20, 12);
        final a = RiwayatGempaRepository(
          sqlite(berkas: berkas),
          sekarang: () => sekarang,
        );
        await a.catat([
          gempaUji(sekarang.subtract(const Duration(hours: 4)), mag: '5.8'),
        ]);
        for (final s in List.of(sqlitePenutup)) {
          await s.tutup();
        }

        final b = RiwayatGempaRepository(
          sqlite(berkas: berkas),
          sekarang: () => sekarang,
        );
        final baris = await b.baris();
        expect(baris.single.gempa.magnitudo, '5.8');

        final db = await databaseFactoryFfi.openDatabase(berkas);
        final versi = await db.rawQuery('PRAGMA user_version');
        expect(versi.single.values.single, SqfliteRiwayatStore.versi);
        await db.close();
      },
    );

    test('baris yang rusak dilewati, baris lain tetap terbaca', () async {
      final berkas = '${tmp.path}/rusak.db';
      final sekarang = DateTime.utc(2026, 11, 20, 12);
      final repo = RiwayatGempaRepository(
        sqlite(berkas: berkas),
        sekarang: () => sekarang,
      );
      await repo.catat([gempaUji(sekarang.subtract(const Duration(hours: 1)))]);

      // Koneksi terpisah (bukan instance bersama) agar penutupannya tidak
      // memutus koneksi penyimpanan yang sedang dipakai.
      final db = await databaseFactoryFfi.openDatabase(
        berkas,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await db.insert('riwayat_gempa', {
        'kunci': 'rusak',
        'waktu_utc': 1,
        'lat': 'bukan-angka',
        'lon': 'bukan-angka',
        'dicatat_at': 1,
        'diperbarui_at': 1,
      });
      await db.close();

      final baris = await repo.baris();
      expect(baris.length, 1);
    });

    test('database tidak bisa dibuka: dianggap kosong, tidak crash', () async {
      final repo = RiwayatGempaRepository(
        SqfliteRiwayatStore(
          pabrik: databaseFactoryFfi,
          lokasi: tmp.path, // sebuah folder, bukan berkas database
        ),
      );
      expect(await repo.baris(), isEmpty);
      expect((await repo.catat([gempaUji(DateTime.now().toUtc())])).baru, 0);
    });
  });
}
