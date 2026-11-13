import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/l10n.dart';
import 'package:app/core/theme.dart';
import 'package:app/core/warna_semantik.dart';
import 'package:app/models/ambang_gempa.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/wilayah_service.dart';
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

        for (final ikon in [
          IkonApp.cuaca,
          IkonApp.gempa,
          IkonApp.peringatan,
          IkonApp.pengaturan,
          IkonApp.beranda,
        ]) {
          await tester.tap(find.byIcon(ikon).last);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byIcon(IkonApp.gempa).last);
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
    expect(tautan, findsNWidgets(3));
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
      await tester.tap(find.byIcon(IkonApp.pengaturan).last);
      await tester.pumpAndSettle();
      expect(find.text(l.pengaturanTampilan), findsOneWidget);
      expect(find.text(l.tentangJudul), findsOneWidget);

      await tester.tap(find.text(l.notifJudul).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.notifM5).last);
      await tester.pumpAndSettle();
      expect(notif.langgananDipanggil, [AmbangGempa.m5]);
      expect(find.text(l.notifM5), findsOneWidget);

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
}
