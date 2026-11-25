import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/l10n.dart';
import 'package:app/core/panduan_siaga.dart';
import 'package:app/core/ringkasan_gempa.dart';
import 'package:app/models/gempa.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/providers/siaga_provider.dart';
import 'package:app/screens/siaga_gempa_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';

import 'helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Checklist tas siaga (provider)', () {
    test('centang tersimpan setelah provider dibuat ulang (restart)', () async {
      final a = SiagaProvider(PreferencesService());
      await a.muat();
      expect(a.jumlahSelesai, 0);
      expect(a.total, 11);

      await a.toggle('air');
      await a.toggle('p3k');
      expect(a.jumlahSelesai, 2);
      expect(a.progres, closeTo(2 / 11, 1e-9));

      final b = SiagaProvider(PreferencesService());
      await b.muat();
      expect(b.selesai, {'air', 'p3k'});
      expect(b.jumlahSelesai, 2);
      expect(b.sudah('air'), isTrue);
      expect(b.sudah('uang'), isFalse);
    });

    test('mencentang dua kali melepas centang; id asing diabaikan', () async {
      final p = SiagaProvider(PreferencesService());
      await p.muat();
      await p.toggle('uang');
      await p.toggle('uang');
      await p.toggle('bukan-butir');
      expect(p.selesai, isEmpty);
    });

    test('id yang sudah tidak ada di daftar dibuang saat memuat', () async {
      SharedPreferences.setMockInitialValues({
        SiagaProvider.kunci: ['air', 'dihapus-dari-daftar'],
      });
      final p = SiagaProvider(PreferencesService());
      await p.muat();
      expect(p.selesai, {'air'});
    });

    test(
      'data versi lama (nomor urut) dipindah satu kali ke id butir',
      () async {
        SharedPreferences.setMockInitialValues({
          SiagaProvider.kunciLama: ['0', '4', '7', '99', 'x'],
        });
        final p = SiagaProvider(PreferencesService());
        await p.muat();
        expect(p.selesai, {'air', 'dokumen', 'radio'});

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList(SiagaProvider.kunciLama), isNull);
        expect(prefs.getStringList(SiagaProvider.kunci), isNotNull);
      },
    );

    test('setel ulang mengosongkan dan menghapus data tersimpan', () async {
      final p = SiagaProvider(PreferencesService());
      await p.muat();
      await p.toggle('air');
      await p.setelUlang();
      expect(p.selesai, isEmpty);
      final q = SiagaProvider(PreferencesService());
      await q.muat();
      expect(q.selesai, isEmpty);
    });
  });

  group('Konten edukasi bersumber', () {
    for (final bahasa in ['id', 'en']) {
      final l = lookupAppLocalizations(Locale(bahasa));

      test('tiga bagian panduan lengkap dengan sumber ($bahasa)', () {
        final panduan = panduanSiaga(l);
        expect(panduan.map((b) => b.id), ['sebelum', 'saat', 'setelah']);
        for (final b in panduan) {
          expect(b.judul, isNotEmpty);
          expect(b.sumber.nama, isNotEmpty);
          expect(b.sumber.url, startsWith('https://'));
          expect(b.kelompok, isNotEmpty);
          for (final k in b.kelompok) {
            expect(k.judul.trim(), isNotEmpty);
            expect(k.butir, isNotEmpty);
            for (final butir in k.butir) {
              expect(butir.trim(), isNotEmpty);
            }
          }
        }
      });

      test('tas siaga: 11 butir BNPB dengan id tetap ($bahasa)', () {
        final tas = tasSiaga(l);
        expect(tas.map((t) => t.id).toList(), idTasSiaga);
        expect(tas.length, 11);
        expect(tas.every((t) => t.teks.trim().isNotEmpty), isTrue);
      });

      test('istilah gempa lengkap ($bahasa)', () {
        final istilah = istilahGempa(l);
        expect(istilah.map((i) => i.id), [
          'magnitudo',
          'richter',
          'kedalaman',
          'mmi',
          'waktu',
        ]);
        expect(
          istilah.every((i) => i.nama.isNotEmpty && i.isi.isNotEmpty),
          isTrue,
        );
      });
    }

    test('teks Indonesia sama dengan halaman BMKG (cuplikan)', () {
      final l = lookupAppLocalizations(const Locale('id'));
      final saat = panduanSiaga(l)[1];
      expect(
        saat.kelompok.first.butir.first,
        'Lindungi kepala dan badan Anda dari reruntuhan bangunan '
        '(dengan bersembunyi di bawah meja, dll.);',
      );
      expect(
        saat.kelompok[3].butir.single,
        'Jauhi pantai untuk menghindari terjadinya tsunami.',
      );
      expect(
        tasSiaga(l).last.teks,
        startsWith('Alat penerangan: senter, lampu kepala'),
      );
      expect(
        istilahGempa(l).firstWhere((i) => i.id == 'mmi').isi,
        'Ukuran kekuatan gempa bumi berdasarkan kerusakan yang diakibatkan '
        'oleh gempa tersebut.',
      );
    });

    test('alamat sumber adalah halaman resmi BMKG dan BNPB', () {
      expect(sumberBmkgAntisipasi.url, contains('bmkg.go.id'));
      expect(sumberBmkgIstilah.url, contains('bmkg.go.id'));
      expect(sumberBnpbTas.url, contains('bnpb.go.id'));
    });
  });

  group('Jarak kartu panduan Siaga', () {
    testWidgets('tiga kartu buka-tutup tidak menempel: ada jarak vertikal '
        'antar kartu', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buatApp(gps: _gps, offline: true));
      await tester.pumpAndSettle();
      await tester.tap(navTab('gempa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.gempaSiagaJudul));
      await tester.pumpAndSettle();

      final bagian = panduanSiaga(l).map((b) => b.id).toList();
      expect(bagian.length, greaterThanOrEqualTo(3));
      final kartu = [
        for (final id in bagian) find.byKey(ValueKey('siaga.$id')),
      ];
      for (var i = 0; i + 1 < kartu.length; i++) {
        if (kartu[i].evaluate().isEmpty || kartu[i + 1].evaluate().isEmpty) {
          break;
        }
        final bawah = tester.getBottomLeft(kartu[i]).dy;
        final atas = tester.getTopLeft(kartu[i + 1]).dy;
        expect(atas - bawah, greaterThanOrEqualTo(12), reason: 'kartu $i');
      }
    });
  });

  group('Layar Siaga', () {
    Future<void> gulirKe(WidgetTester tester, Finder finder) =>
        tester.scrollUntilVisible(
          finder,
          200,
          scrollable: find
              .descendant(
                of: find.byType(SiagaGempaScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );

    for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
      final t = lookupAppLocalizations(bahasa.locale!);

      testWidgets('di 360 dp + huruf 1,3x: sumber terlihat, centang bertahan '
          '(${bahasa.name})', (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        Widget app() => buatApp(
          gps: _gps,
          offline: true,
          pengaturan: PengaturanProvider(PreferencesService(), bahasa: bahasa),
        );

        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        await tester.tap(navTab('gempa'));
        await tester.pumpAndSettle();
        // Siap Siaga dibuka lewat kartu pengantar di tab Gempa.
        await tester.tap(find.text(t.gempaSiagaJudul));
        await tester.pumpAndSettle();
        expect(find.text(t.siagaJudul), findsOneWidget);

        // Buka "Sebelum gempa": isi dan baris sumber (nama + URL) terlihat.
        await tester.tap(find.text(t.siagaSebelum));
        await tester.pumpAndSettle();
        await gulirKe(tester, find.text(sumberBmkgAntisipasi.url).first);
        expect(
          find.text(t.siagaSumber(sumberBmkgAntisipasi.nama)),
          findsWidgets,
        );
        expect(find.text(sumberBmkgAntisipasi.url), findsWidgets);

        // Centang satu butir tas siaga: progres "1 dari 11".
        final dokumen = find.byKey(const ValueKey('tas.dokumen'));
        await gulirKe(tester, dokumen);
        await tester.tap(dokumen);
        await tester.pumpAndSettle();
        expect(find.text(t.tasProgres('1', '11')), findsOneWidget);

        // Restart aplikasi: centang tetap ada.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        await tester.tap(navTab('gempa'));
        await tester.pumpAndSettle();
        // Siap Siaga dibuka lewat kartu pengantar di tab Gempa.
        await tester.tap(find.text(t.gempaSiagaJudul));
        await tester.pumpAndSettle();
        await gulirKe(tester, find.byKey(const ValueKey('tas.dokumen')));
        expect(
          tester
              .widget<CheckboxListTile>(
                find.byKey(const ValueKey('tas.dokumen')),
              )
              .value,
          isTrue,
        );
        expect(find.text(t.tasProgres('1', '11')), findsOneWidget);

        // Istilah, sumber istilah, dan catatan bukan pengganti arahan resmi.
        await gulirKe(tester, find.text(t.siagaIstilahJudul));
        await tester.tap(find.text(t.siagaIstilahJudul));
        await tester.pumpAndSettle();
        await gulirKe(tester, find.text(sumberBmkgIstilah.url));
        expect(find.text(sumberBmkgIstilah.url), findsOneWidget);
        await gulirKe(tester, find.text(t.siagaCatatan));
        expect(find.text(t.siagaCatatan), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Ringkasan gempa untuk dibagikan', () {
    final l = lookupAppLocalizations(const Locale('id'));
    final en = lookupAppLocalizations(const Locale('en'));
    final lengkap = Gempa(
      tanggal: '22 Nov 2026',
      jam: '14:54:39 WIB',
      koordinat: '3.12,126.57',
      lintang: '',
      bujur: '',
      magnitudo: '5.4',
      kedalaman: '10 km',
      wilayah: '98 km BaratDaya MELONGUANE-SULUT',
      potensi: 'Tidak berpotensi tsunami',
      dirasakan: 'II Tahuna',
      shakemap: '',
      waktuUtc: DateTime.utc(2026, 11, 22, 7, 54, 39),
      lat: 3.12,
      lon: 126.57,
    );
    const kosong = Gempa(
      tanggal: '',
      jam: '',
      koordinat: '',
      lintang: '',
      bujur: '',
      magnitudo: '',
      kedalaman: '',
      wilayah: '',
      potensi: '',
      dirasakan: '',
      shakemap: '',
    );

    test('data lengkap memuat waktu, magnitudo, lokasi, kedalaman, sumber', () {
      final teks = susunRingkasanGempa(l, lengkap, jarakKm: 2423);
      expect(teks, contains('Magnitudo: 5.4'));
      expect(teks, contains('Pusat gempa: 98 km BaratDaya MELONGUANE-SULUT'));
      expect(teks, contains('Waktu: '));
      expect(teks, contains('Kedalaman: 10 km'));
      expect(teks, contains('Potensi: Tidak berpotensi tsunami'));
      expect(teks, contains('Dirasakan di: II Tahuna'));
      expect(teks, contains('2.423'));
      expect(teks, contains('Sumber: BMKG'));
      expect(teks, contains(l.bukanResmi));
    });

    test('tanpa jarak: baris jarak tidak ada', () {
      expect(susunRingkasanGempa(l, lengkap), isNot(contains('km dari Anda')));
    });

    test('data kosong: tidak ada baris berlabel kosong, sumber tetap ada', () {
      final teks = susunRingkasanGempa(l, kosong);
      expect(teks, isNot(contains('Magnitudo:')));
      expect(teks, isNot(contains('Pusat gempa:')));
      expect(teks, isNot(contains('Waktu:')));
      expect(teks, isNot(contains('Kedalaman:')));
      expect(teks, contains(l.bagikanGempaJudul));
      expect(teks, contains('Sumber: BMKG'));
      expect(teks, contains(l.bukanResmi));
    });

    test('hanya sebagian data: baris yang ada saja yang tampil', () {
      const sebagian = Gempa(
        tanggal: '1 Jan 2026',
        jam: '10:00 WIB',
        koordinat: '',
        lintang: '',
        bujur: '',
        magnitudo: '4.9',
        kedalaman: '',
        wilayah: '',
        potensi: '',
        dirasakan: '',
        shakemap: '',
      );
      final teks = susunRingkasanGempa(l, sebagian);
      expect(teks, contains('Magnitudo: 4.9'));
      expect(teks, contains('Waktu: 1 Jan 2026 10:00 WIB'));
      expect(teks, isNot(contains('Kedalaman:')));
    });

    test('bahasa Inggris memakai label Inggris', () {
      final teks = susunRingkasanGempa(en, lengkap);
      expect(teks, contains('Magnitude: 5.4'));
      expect(teks, contains('Depth: 10 km'));
      expect(teks, contains('Source: BMKG'));
      expect(teks, contains('not an official BMKG app'));
    });
  });

  group('Kartu Siap Siaga', () {
    for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
      final t = lookupAppLocalizations(bahasa.locale!);
      testWidgets(
        'Beranda dan tab Gempa membuka layar Siaga (${bahasa.name})',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 1920);
          tester.view.devicePixelRatio = 3;
          tester.platformDispatcher.textScaleFactorTestValue = 1.3;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(
            buatApp(
              gps: _gps,
              offline: true,
              pengaturan: PengaturanProvider(
                PreferencesService(),
                bahasa: bahasa,
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Beranda: bagian keempat "Siap Siaga".
          final kartu = find.text(t.siagaHeroJudul);
          await tester.dragUntilVisible(
            kartu,
            find.byType(SingleChildScrollView).first,
            const Offset(0, -200),
          );
          await tester.tap(kartu);
          await tester.pumpAndSettle();
          expect(find.byType(SiagaGempaScreen), findsOneWidget);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();

          // Tab Gempa: kartu pengantar bisa diketuk.
          await tester.tap(navTab('gempa'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(t.gempaSiagaJudul));
          await tester.pumpAndSettle();
          expect(find.byType(SiagaGempaScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
