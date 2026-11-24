import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/l10n.dart';
import 'package:app/models/gempa.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/riwayat_gempa_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/riwayat_gempa_repository.dart';

import 'helpers.dart';

const _gpsJakarta = HasilGps(StatusGps.berhasil, lat: -6.2088, lon: 106.8456);

Gempa _g(DateTime waktu, double lat, double lon, String mag, String wilayah) =>
    Gempa(
      tanggal: '',
      jam: '',
      koordinat: '$lat,$lon',
      lintang: '',
      bujur: '',
      magnitudo: mag,
      kedalaman: '10 km',
      wilayah: wilayah,
      potensi: 'Tidak berpotensi tsunami',
      dirasakan: '',
      shakemap: '',
      waktuUtc: waktu.toUtc(),
      lat: lat,
      lon: lon,
    );

class _StoreGagalBaca extends MemoriRiwayatStore {
  @override
  Future<List<BarisRiwayat>> semua() async => throw StateError('rusak');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final sekarang = DateTime.now();
  final terbaru = sekarang.subtract(const Duration(hours: 3));
  final tengah = sekarang.subtract(const Duration(days: 2));
  final tertua = sekarang.subtract(const Duration(days: 5));

  Future<RiwayatGempaRepository> repoIsi(WidgetTester tester) async {
    final repo = RiwayatGempaRepository(MemoriRiwayatStore());
    await tester.runAsync(
      () => repo.catat([
        _g(terbaru, -0.93, 128.60, '6.3', 'Maluku Utara'),
        _g(tengah, -6.5, 106.9, '5.4', 'Selatan Bogor'),
        _g(tertua, -7.8, 110.4, '4.1', 'Yogyakarta'),
      ]),
    );
    return repo;
  }

  /// Menggulir daftar layar riwayat sampai [finder] terbangun dan terlihat.
  Future<void> gulirKe(
    WidgetTester tester,
    Finder finder, {
    double delta = 150,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find
          .descendant(
            of: find.byType(RiwayatGempaScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }

  void layar360(WidgetTester tester, {double skala = 1.3}) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = skala;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> bukaRiwayat(
    WidgetTester tester, {
    required RiwayatGempaRepository repo,
    required PilihanBahasa bahasa,
    HasilGps gps = _gpsJakarta,
  }) async {
    await tester.pumpWidget(
      buatApp(
        gps: gps,
        offline: true,
        riwayatGempa: repo,
        pengaturan: PengaturanProvider(PreferencesService(), bahasa: bahasa),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(navTab('gempa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(IkonApp.riwayat));
    await tester.pumpAndSettle();
  }

  for (final bahasa in [PilihanBahasa.indonesia, PilihanBahasa.inggris]) {
    final t = lookupAppLocalizations(bahasa.locale!);

    group('Layar riwayat (${bahasa.name})', () {
      testWidgets('label bias, rentang data, statistik, dan filter di 360 dp '
          'dengan huruf 1,3x', (tester) async {
        layar360(tester);
        final repo = await repoIsi(tester);
        await bukaRiwayat(tester, repo: repo, bahasa: bahasa);

        // Label bias dan rentang data yang benar-benar ada.
        expect(find.text(t.riwayatBiasLabel), findsOneWidget);
        final fmt = DateFormat('d MMM yyyy', t.localeName);
        expect(
          find.text(
            t.riwayatRentangData(fmt.format(tertua), fmt.format(terbaru)),
          ),
          findsOneWidget,
        );
        expect(find.text(t.riwayatBiasCatatan), findsOneWidget);
        // Setiap kartu statistik berlabel asal datanya.
        await gulirKe(tester, find.text(t.statLabelBias));
        expect(find.text(t.statLabelBias), findsOneWidget);
        await gulirKe(tester, find.text(t.riwayatDariTotal('3', '3')));
        expect(find.text(t.riwayatDariTotal('3', '3')), findsOneWidget);

        // Filter magnitudo minimum 6.0 lewat lembar filter.
        await tester.tap(find.byIcon(IkonApp.saring));
        await tester.pumpAndSettle();
        expect(find.text(t.filterJudul), findsOneWidget);
        // Lembar bisa digulir; pada huruf besar chip ada di bawah layar.
        await tester.ensureVisible(find.text(t.minimalMagnitudo('6.0')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.minimalMagnitudo('6.0')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(t.filterTerapkan));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.filterTerapkan));
        await tester.pumpAndSettle();
        // Chip saringan aktif ada di bagian atas daftar.
        await gulirKe(
          tester,
          find.text(t.minimalMagnitudo('6.0')),
          delta: -150,
        );
        expect(find.text(t.minimalMagnitudo('6.0')), findsOneWidget);
        await gulirKe(tester, find.text(t.riwayatDariTotal('1', '3')));
        expect(find.text(t.riwayatDariTotal('1', '3')), findsOneWidget);

        // Setel ulang mengembalikan semua data.
        final setelUlang = find.widgetWithText(TextButton, t.filterSetelUlang);
        await gulirKe(tester, setelUlang, delta: -150);
        await tester.tap(setelUlang);
        await tester.pumpAndSettle();
        await gulirKe(tester, find.text(t.riwayatDariTotal('3', '3')));
        expect(find.text(t.riwayatDariTotal('3', '3')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('tanpa lokasi: kartu jarak berpesan, filter jarak nonaktif', (
        tester,
      ) async {
        layar360(tester);
        final repo = await repoIsi(tester);
        await bukaRiwayat(
          tester,
          repo: repo,
          bahasa: bahasa,
          gps: const HasilGps(StatusGps.ditolak),
        );

        await gulirKe(tester, find.text(t.statLokasiTidakAda));
        expect(find.text(t.statLokasiTidakAda), findsOneWidget);

        await tester.tap(find.byIcon(IkonApp.saring));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(t.filterJarakNonaktif));
        expect(find.text(t.filterJarakNonaktif), findsOneWidget);
        final chip = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, t.filterJarakKm('100')),
        );
        expect(chip.onSelected, isNull, reason: 'filter jarak dinonaktifkan');
        expect(tester.takeException(), isNull);
      });

      testWidgets('belum ada data: keadaan kosong dengan label bias', (
        tester,
      ) async {
        layar360(tester, skala: 1.0);
        await bukaRiwayat(
          tester,
          repo: RiwayatGempaRepository(MemoriRiwayatStore()),
          bahasa: bahasa,
        );
        expect(find.text(t.riwayatKosong), findsOneWidget);
        expect(find.text(t.riwayatBiasLabel), findsOneWidget);
        expect(find.text(t.bukanResmi), findsOneWidget);
      });

      testWidgets('penyimpanan gagal: pesan galat dan tombol coba lagi', (
        tester,
      ) async {
        layar360(tester, skala: 1.0);
        await bukaRiwayat(
          tester,
          repo: RiwayatGempaRepository(_StoreGagalBaca()),
          bahasa: bahasa,
        );
        expect(find.text(t.riwayatGagalMuat), findsOneWidget);
        expect(find.text(t.cobaLagi), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
