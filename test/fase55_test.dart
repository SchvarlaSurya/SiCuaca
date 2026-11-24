import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/l10n.dart';
import 'package:app/core/theme.dart';
import 'package:app/core/warna_semantik.dart';
import 'package:app/models/ambang_gempa.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/riwayat_notifikasi_screen.dart';
import 'package:app/services/riwayat_notifikasi_service.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/wilayah_service.dart';
import 'package:app/widgets/grafik_suhu.dart';
import 'package:app/widgets/status_data.dart';

import 'helpers.dart';

const _gpsJakarta = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

/// Rasio kontras WCAG 2.x.
double kontras(Color a, Color b) {
  double kanal(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double lum(Color c) =>
      0.2126 * kanal(c.r) + 0.7152 * kanal(c.g) + 0.0722 * kanal(c.b);
  final la = lum(a);
  final lb = lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Kontras warna semantik', () {
    test('kartu hero: 5 kondisi x siang/malam x terang/gelap >= 4,5:1', () {
      var jumlah = 0;
      for (final kondisi in KondisiLangit.values) {
        for (final malam in [false, true]) {
          for (final kecerahan in Brightness.values) {
            final g = GayaHero.untuk(
              kondisi,
              malam: malam,
              kecerahan: kecerahan,
            );
            for (final latar in [g.atas, g.bawah]) {
              for (final teks in [g.teks, g.redup]) {
                expect(
                  kontras(teks, latar),
                  greaterThanOrEqualTo(4.5),
                  reason: '$kondisi malam=$malam $kecerahan',
                );
              }
            }
            jumlah++;
          }
        }
      }
      expect(jumlah, 20);
    });

    test('kartu hero ungu: teks terang lulus di semua titik gradasi', () {
      for (final kondisi in KondisiLangit.values) {
        for (final malam in [false, true]) {
          final g = GayaHero.untuk(
            kondisi,
            malam: malam,
            kecerahan: Brightness.dark,
          );
          for (final latar in [
            const Color(0xFF302080),
            const Color(0xFF6250DB),
            g.bawah,
          ]) {
            expect(kontras(Colors.white, latar), greaterThanOrEqualTo(4.5));
            expect(kontras(g.teks, latar), greaterThanOrEqualTo(4.5));
          }
        }
      }
    });

    test('kartu hero tanpa gradasi (kurangi gerakan) tetap lulus', () {
      for (final s in [AppTheme.skemaTerang, AppTheme.skemaGelap]) {
        expect(
          kontras(s.onPrimaryContainer, s.primaryContainer),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('tingkat magnitudo: label teks di atas warna >= 4,5:1', () {
      for (final t in TingkatMagnitudo.values) {
        expect(
          kontras(t.depan, t.latar),
          greaterThanOrEqualTo(4.5),
          reason: t.name,
        );
      }
      expect(TingkatMagnitudo.dari(3.9), TingkatMagnitudo.kecil);
      expect(TingkatMagnitudo.dari(4.0), TingkatMagnitudo.ringan);
      expect(TingkatMagnitudo.dari(5.1), TingkatMagnitudo.sedang);
      expect(TingkatMagnitudo.dari(6.0), TingkatMagnitudo.kuat);
      expect(TingkatMagnitudo.dari(7.2), TingkatMagnitudo.besar);
      expect(TingkatMagnitudo.dari(null), TingkatMagnitudo.takDiketahui);
    });

    test('token teks tema terang/gelap >= 4,5:1', () {
      for (final s in [AppTheme.skemaTerang, AppTheme.skemaGelap]) {
        for (final latar in [
          s.surface,
          s.surfaceContainerLowest,
          s.surfaceContainer,
          s.surfaceContainerHighest,
        ]) {
          expect(kontras(s.onSurface, latar), greaterThanOrEqualTo(4.5));
          expect(kontras(s.onSurfaceVariant, latar), greaterThanOrEqualTo(4.5));
          expect(kontras(s.primary, latar), greaterThanOrEqualTo(4.5));
        }
        expect(
          kontras(s.onTertiaryContainer, s.tertiaryContainer),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  });

  group('Kisi tile', () {
    test('360 dp: 2 kolom di huruf 1,0, 1 kolom di huruf 1,3', () {
      // Lebar isi = 360 - 2 x 16 padding.
      expect(KisiTile.kolom(328, 1.0), 2);
      expect(KisiTile.kolom(328, 1.3), 1);
      // Layar besar tetap 2 kolom di 1,3.
      expect(KisiTile.kolom(600, 1.3), 2);
    });
  });

  for (final tema in [PilihanTema.terang, PilihanTema.gelap]) {
    testWidgets(
      '360 dp + huruf 1,3x: semua tab tanpa overflow (${tema.name})',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3; // 360 x 640 dp
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          buatApp(
            gps: _gpsJakarta,
            pengaturan: PengaturanProvider(
              PreferencesService(),
              bahasa: PilihanBahasa.inggris,
              tema: tema,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Kisi tile Beranda turun ke 1 kolom.
        final l = lookupAppLocalizations(const Locale('en'));
        final kelembapan = tester.getTopLeft(find.text(l.kelembapan).first);
        final angin = tester.getTopLeft(find.text(l.angin).first);
        expect(angin.dy, greaterThan(kelembapan.dy));

        for (final tab in ['cuaca', 'gempa', 'pengaturan', 'beranda']) {
          await tester.tap(navTab(tab));
          await tester.pumpAndSettle();
        }
        await bukaPeringatan(tester);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(navTab('gempa'));
        await tester.pumpAndSettle();
        for (final tab in [l.gempaTabTerkini, l.gempaTabDirasakan]) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('II - III Enggano').first);
        await tester.pumpAndSettle();
        expect(find.text(l.gempaDetailJudul), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Selengkapnya di Beranda pindah ke tab Gempa', (tester) async {
    await tester.pumpWidget(buatApp(gps: _gpsJakarta));
    await tester.pumpAndSettle();
    final l = lookupAppLocalizations(const Locale('id'));
    final tautan = find.text(l.selengkapnya);
    expect(tautan, findsNWidgets(SeksiBeranda.values.length));
    await tester.ensureVisible(tautan.at(1));
    await tester.tap(tautan.at(1));
    await tester.pumpAndSettle();
    expect(find.text(l.gempaTerbaruKeterangan), findsOneWidget);
  });

  group('P2', () {
    test('dataset wilayah: anak per tingkat dan desa dari kode', () {
      final indeks = parseWilayah(tsvUji);
      expect(
        [for (final s in indeks.anak('')) s.nama],
        ['DKI Jakarta', 'Jawa Timur'],
      );
      expect([for (final s in indeks.anak('35')) s.nama], ['Kab. Malang']);
      expect(
        [for (final s in indeks.anak('35.07.10')) s.nama],
        ['Putat Kidul', "Suka'maju"],
      );
      expect(indeks.anak('35.07.10').first.desa, isTrue);
      expect(indeks.desaDenganKode('31.71.01.1002')?.kecamatan, 'Gambir');
    });

    Future<void> pilihLewatDaftar(
      WidgetTester tester,
      List<String> jalur,
    ) async {
      await tester.tap(find.byIcon(IkonApp.cari).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.pilihDariDaftar));
      await tester.pumpAndSettle();
      for (final nama in jalur) {
        await tester.tap(find.widgetWithText(ListTile, nama).last);
        await tester.pumpAndSettle();
      }
    }

    testWidgets(
      'pemilih bertingkat: desa cocok tampil, tidak cocok "Data tidak tersedia"',
      (tester) async {
        await tester.pumpWidget(
          buatApp(gps: const HasilGps(StatusGps.ditolak)),
        );
        await tester.pumpAndSettle();

        // FakeApi selalu membalas prakiraan Gambir: Putat Kidul tidak cocok.
        await pilihLewatDaftar(tester, [
          'Jawa Timur',
          'Kab. Malang',
          'Gondanglegi',
          'Putat Kidul',
        ]);
        expect(find.text(l.dataTidakTersedia), findsOneWidget);
        expect(find.text(l.cuacaSaatIni), findsOneWidget);

        await pilihLewatDaftar(tester, [
          'DKI Jakarta',
          'Kota Adm. Jakarta Pusat',
          'Gambir',
          'Gambir',
        ]);
        expect(find.text(l.dataTidakTersedia), findsNothing);
        expect(find.text('Gambir'), findsWidgets);
        expect(find.text(l.kelembapan), findsOneWidget);
      },
    );

    testWidgets('pemilih bertingkat: kembali naik satu tingkat', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: const HasilGps(StatusGps.ditolak)));
      await tester.pumpAndSettle();
      await pilihLewatDaftar(tester, ['Jawa Timur', 'Kab. Malang']);
      expect(find.text(l.pilihKecamatan), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(l.pilihKabKota), findsOneWidget);
      // Remah roti kembali ke akar.
      await tester.tap(find.widgetWithText(TextButton, l.semuaWilayah));
      await tester.pumpAndSettle();
      expect(find.text(l.pilihProvinsi), findsOneWidget);
    });

    testWidgets('Pengaturan: tema, bahasa, dan ambang notifikasi', (
      tester,
    ) async {
      final notif = FakeNotif();
      await tester.pumpWidget(
        buatApp(gps: const HasilGps(StatusGps.ditolak), notif: notif),
      );
      await tester.pumpAndSettle();
      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
      expect(find.text(l.pengaturanTampilan), findsOneWidget);
      expect(find.text(l.tentangJudul), findsOneWidget);

      await tester.ensureVisible(find.text(l.notifJudul).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.notifJudul).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.notifM5).last);
      await tester.pumpAndSettle();
      expect(notif.langgananDipanggil, [AmbangGempa.m5]);
      expect(find.text(l.notifM5), findsOneWidget);

      await tester.dragUntilVisible(
        find.text(l.tentangTema),
        find.byType(ListView).last,
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.tentangTema));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.temaGelap).last);
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tema'), 'gelap');
    });
  });

  group('Onboarding', () {
    for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
      testWidgets('pertama dibuka, 360 dp + huruf 1,3x (${bahasa.name})', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final t = lookupAppLocalizations(bahasa.locale!);

        await tester.pumpWidget(
          buatApp(
            gps: _gpsJakarta,
            sudahOnboarding: false,
            pengaturan: PengaturanProvider(
              PreferencesService(),
              bahasa: bahasa,
              tema: PilihanTema.gelap,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(t.onboardingCuacaJudul), findsOneWidget);

        await tester.tap(find.text(t.onboardingLanjut));
        await tester.pumpAndSettle();
        expect(find.text(t.onboardingGempaJudul), findsOneWidget);
        await tester.tap(find.text(t.onboardingLanjut));
        await tester.pumpAndSettle();
        expect(find.text(t.onboardingSiagaJudul), findsOneWidget);
        await tester.tap(find.text(t.onboardingLanjut));
        await tester.pumpAndSettle();
        expect(find.text(t.onboardingWilayahJudul), findsOneWidget);
        expect(find.text(t.onboardingLewati), findsNothing);
        // Halaman terakhir menegaskan sumber BMKG dan bukan aplikasi resmi.
        expect(find.text(t.onboardingSumber), findsOneWidget);

        await tester.tap(find.text(t.onboardingMulai));
        await tester.pumpAndSettle();
        expect(navTab('beranda'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('sudah_onboarding'), isTrue);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Lewati langsung ke aplikasi', (tester) async {
      await tester.pumpWidget(
        buatApp(gps: _gpsJakarta, sudahOnboarding: false),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.onboardingLewati));
      await tester.pumpAndSettle();
      expect(find.text(l.cuacaSaatIni), findsOneWidget);
    });
  });

  testWidgets('navbar: 4 tab, suhu dan magnitudo tampil sebagai data', (
    tester,
  ) async {
    final semantik = tester.ensureSemantics();
    await tester.pumpWidget(buatApp(gps: _gpsJakarta));
    await tester.pumpAndSettle();

    for (final tab in ['beranda', 'cuaca', 'gempa', 'pengaturan']) {
      expect(navTab(tab), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('nav.peringatan')), findsNothing);

    final suhu = find.descendant(
      of: navTab('cuaca'),
      matching: find.textContaining('°'),
    );
    expect(suhu, findsOneWidget);
    final magnitudo = find.descendant(
      of: navTab('gempa'),
      matching: find.textContaining(RegExp(r'^M\d')),
    );
    expect(magnitudo, findsOneWidget);
    // Nilai data dibacakan bersama nama tab oleh node semantik navbar.
    final gempa = tester.getSemantics(navTab('gempa'));
    expect(gempa.label, startsWith(l.navGempa));
    expect(gempa.label, contains(l.magnitudo));
    expect(gempa.flagsCollection.isButton, isTrue);
    semantik.dispose();
  });

  group('Grafik suhu dan sapaan', () {
    Prakiraan prakiraan() =>
        Prakiraan.fromJson(fixture('prakiraan_31.71.01.1001.json'));

    test('entri24Jam: dari jam sekarang sampai 24 jam, urut, 9 titik', () {
      final p = prakiraan();
      final awal = p.semuaEntri.first;
      final titik = entri24Jam(p, awal);
      expect(titik.length, 9);
      expect(identical(titik.first, awal), isTrue);
      for (var i = 1; i < titik.length; i++) {
        expect(titik[i].waktuUtc!.isAfter(titik[i - 1].waktuUtc!), isTrue);
      }
      expect(
        titik.last.waktuUtc!.difference(awal.waktuUtc!),
        const Duration(hours: 24),
      );
    });

    test('entri24Jam: di ujung prakiraan titiknya sedikit', () {
      final p = prakiraan();
      expect(entri24Jam(p, p.semuaEntri.last).length, 1);
    });

    test('sapaan menurut jam setempat, dua bahasa', () {
      expect(l.sapaan(3, 'Gambir'), 'Selamat malam, Gambir');
      expect(l.sapaan(4, 'Gambir'), 'Selamat pagi, Gambir');
      expect(l.sapaan(10, 'Gambir'), 'Selamat pagi, Gambir');
      expect(l.sapaan(11, 'Gambir'), 'Selamat siang, Gambir');
      expect(l.sapaan(14, 'Gambir'), 'Selamat siang, Gambir');
      expect(l.sapaan(15, 'Gambir'), 'Selamat sore, Gambir');
      expect(l.sapaan(17, 'Gambir'), 'Selamat sore, Gambir');
      expect(l.sapaan(18, 'Gambir'), 'Selamat malam, Gambir');
      expect(en.sapaan(9, 'Gambir'), 'Good morning, Gambir');
      expect(en.sapaan(20, 'Gambir'), 'Good night, Gambir');
    });

    for (final skala in [1.0, 1.3]) {
      testWidgets('grafik suhu tanpa overflow di 360 dp, huruf $skala', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = skala;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final p = prakiraan();
        final titik = entri24Jam(p, p.semuaEntri.first);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: bahasaDidukung,
            locale: const Locale('id'),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: GrafikSuhu(
                  entri: titik,
                  warna: Colors.black,
                  warnaRedup: Colors.black54,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining(l.grafikSuhuJudul), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('kurang dari 3 titik: grafik tidak ditampilkan', (
      tester,
    ) async {
      final p = prakiraan();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: bahasaDidukung,
          locale: const Locale('id'),
          home: Scaffold(
            body: GrafikSuhu(
              entri: [p.semuaEntri.first, p.semuaEntri.last],
              warna: Colors.black,
              warnaRedup: Colors.black54,
            ),
          ),
        ),
      );
      expect(find.textContaining(l.grafikSuhuJudul), findsNothing);
    });
  });

  group('P3: riwayat notifikasi', () {
    Map<String, dynamic> payload(int menit, {String mag = '5.1'}) {
      final waktu = DateTime.utc(
        2026,
        11,
        20,
        3,
        menit % 60,
        0,
      ).add(Duration(hours: menit ~/ 60));
      return {
        'jenis': 'gempa',
        'gempa_key': 'k$menit',
        'tanggal': '20 Nov 2026',
        'jam': '10:00:00 WIB',
        'waktu': waktu.toIso8601String(),
        'koordinat': '-5.56,102.24',
        'magnitudo': mag,
        'kedalaman': '10 km',
        'wilayah': 'Pusat gempa uji $menit',
        'potensi': 'Tidak berpotensi tsunami',
        'dirasakan': '',
        'shakemap': '',
      };
    }

    test(
      'catat lalu baca: terbaru di atas, duplikat dan bukan gempa dilewati',
      () async {
        final r = RiwayatNotifikasiService();
        expect(await r.baca(), isEmpty);
        expect(await r.catat(payload(1)), isTrue);
        expect(await r.catat(payload(2)), isTrue);
        expect(await r.catat(payload(2)), isFalse); // gempa yang sama
        expect(await r.catat({'jenis': 'uji'}), isFalse);
        expect(await r.catat(null), isFalse);

        final daftar = await r.baca();
        expect(daftar.length, 2);
        expect(daftar.first.gempa.wilayah, 'Pusat gempa uji 2');
        expect(daftar.last.gempa.magnitudoAngka, 5.1);
      },
    );

    test('maksimal 50 entri, yang terlama dibuang', () async {
      final r = RiwayatNotifikasiService();
      for (var i = 1; i <= 55; i++) {
        await r.catat(payload(i));
      }
      final daftar = await r.baca();
      expect(daftar.length, RiwayatNotifikasiService.batas);
      expect(daftar.first.gempa.wilayah, 'Pusat gempa uji 55');
      expect(daftar.last.gempa.wilayah, 'Pusat gempa uji 6');
    });

    test('hapusSemua mengosongkan riwayat', () async {
      final r = RiwayatNotifikasiService();
      await r.catat(payload(1));
      await r.hapusSemua();
      expect(await r.baca(), isEmpty);
    });

    test('data tersimpan rusak tidak membuat crash', () async {
      SharedPreferences.setMockInitialValues({'riwayat_notifikasi': '{rusak'});
      expect(await RiwayatNotifikasiService().baca(), isEmpty);
      SharedPreferences.setMockInitialValues({
        'riwayat_notifikasi': '[1, {"gempa": 5}, null]',
      });
      expect(await RiwayatNotifikasiService().baca(), isEmpty);
    });

    for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
      testWidgets('layar riwayat 360 dp + huruf 1,3x (${bahasa.name})', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final t = lookupAppLocalizations(bahasa.locale!);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: bahasaDidukung,
            locale: bahasa.locale,
            home: const RiwayatNotifikasiScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(t.riwayatNotifKosong), findsOneWidget);
        expect(find.byIcon(IkonApp.hapusSemua), findsNothing);

        await tester.runAsync(() async {
          final r = RiwayatNotifikasiService();
          await r.catat(payload(1));
          await r.catat(payload(2, mag: '6.3'));
        });
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: bahasaDidukung,
            locale: bahasa.locale,
            home: const RiwayatNotifikasiScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Pusat gempa uji 2'), findsOneWidget);
        expect(find.text('Pusat gempa uji 1'), findsOneWidget);
        expect(find.textContaining(t.diterimaWaktu('')), findsWidgets);

        // Hapus lewat dialog konfirmasi: batal tidak menghapus, hapus menghapus.
        await tester.tap(find.byIcon(IkonApp.hapusSemua));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.aksiBatal));
        await tester.pumpAndSettle();
        expect(find.text('Pusat gempa uji 2'), findsOneWidget);
        await tester.tap(find.byIcon(IkonApp.hapusSemua));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.aksiHapus));
        await tester.pumpAndSettle();
        expect(find.text(t.riwayatNotifKosong), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('P3: urutan bagian Beranda', () {
    test('normalkanUrutan: lengkap, tanpa duplikat, nama asing dibuang', () {
      expect(PengaturanProvider.normalkanUrutan(null), SeksiBeranda.values);
      expect(PengaturanProvider.normalkanUrutan(['peringatan', 'cuaca']), [
        SeksiBeranda.peringatan,
        SeksiBeranda.cuaca,
        SeksiBeranda.gempa,
        SeksiBeranda.siaga,
      ]);
      expect(
        PengaturanProvider.normalkanUrutan(['gempa', 'gempa', 'x', 'cuaca']),
        [
          SeksiBeranda.gempa,
          SeksiBeranda.cuaca,
          SeksiBeranda.peringatan,
          SeksiBeranda.siaga,
        ],
      );
      // Urutan lama (tiga bagian) dari versi sebelumnya tetap valid: bagian
      // baru ditaruh di akhir.
      expect(
        PengaturanProvider.normalkanUrutan(['gempa', 'peringatan', 'cuaca']),
        [
          SeksiBeranda.gempa,
          SeksiBeranda.peringatan,
          SeksiBeranda.cuaca,
          SeksiBeranda.siaga,
        ],
      );
    });

    test('atur, tersimpan, dimuat ulang, dan disetel ulang', () async {
      final prefs = PreferencesService();
      final a = PengaturanProvider(prefs);
      expect(a.urutanBerandaBawaan, isTrue);
      await a.aturUrutanBeranda([
        SeksiBeranda.gempa,
        SeksiBeranda.peringatan,
        SeksiBeranda.cuaca,
        SeksiBeranda.siaga,
      ]);
      expect(a.urutanBerandaBawaan, isFalse);

      final b = PengaturanProvider(prefs);
      await b.muat();
      expect(b.urutanBeranda, [
        SeksiBeranda.gempa,
        SeksiBeranda.peringatan,
        SeksiBeranda.cuaca,
        SeksiBeranda.siaga,
      ]);

      await b.setelUlangUrutanBeranda();
      final c = PengaturanProvider(prefs);
      await c.muat();
      expect(c.urutanBeranda, SeksiBeranda.values);
    });

    testWidgets('Beranda mengikuti urutan, atur lewat tombol panah', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(gps: _gpsJakarta));
      await tester.pumpAndSettle();

      double y(String teks) => tester.getTopLeft(find.text(teks).first).dy;
      expect(y(l.cuacaSaatIni), lessThan(y(l.gempaTerbaruJudul)));

      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.urutanBerandaJudul));
      await tester.pumpAndSettle();
      expect(find.text(l.urutanBerandaKeterangan), findsOneWidget);

      // Turunkan "Cuaca": urutan jadi Gempa, Cuaca, Peringatan.
      await tester.tap(find.byTooltip(l.turunkanBagian(l.cuacaSaatIni)));
      await tester.pumpAndSettle();
      // Tombol naik pada bagian pertama dinonaktifkan.
      final naikPertama = tester.widget<IconButton>(
        find
            .ancestor(
              of: find.byTooltip(l.naikkanBagian(l.gempaTerbaruJudul)),
              matching: find.byType(IconButton),
            )
            .first,
      );
      expect(naikPertama.onPressed, isNull);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(navTab('beranda'));
      await tester.pumpAndSettle();
      expect(y(l.gempaTerbaruJudul), lessThan(y(l.cuacaSaatIni)));

      // Setel ulang mengembalikan urutan bawaan.
      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.urutanBerandaJudul));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.setelUlangUrutan));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(navTab('beranda'));
      await tester.pumpAndSettle();
      expect(y(l.cuacaSaatIni), lessThan(y(l.gempaTerbaruJudul)));
    });
  });
}
