// Mengambil tangkapan layar seluruh halaman aplikasi (data contoh dari
// fixture, tanpa jaringan dan tanpa perangkat), disimpan di build/screenshot/.
//
// Jalankan:  flutter test tool/ambil_screenshot_test.dart
//
// Ini render dari mesin uji Flutter pada 360 x 780 dp (2x), bukan dari HP:
// tampilan kaca/blur dan font bisa sedikit beda dari perangkat sungguhan.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/core/navigasi.dart';
import 'package:app/models/gempa.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/screens/gempa_detail_screen.dart';
import 'package:app/screens/layanan_screen.dart';
import 'package:app/screens/maritim_screen.dart';
import 'package:app/screens/pencarian_screen.dart';
import 'package:app/screens/perbandingan_cuaca_screen.dart';
import 'package:app/screens/pilih_wilayah_screen.dart';
import 'package:app/screens/riwayat_gempa_screen.dart';
import 'package:app/screens/riwayat_notifikasi_screen.dart';
import 'package:app/screens/udara_uv_screen.dart';
import 'package:app/screens/urutan_beranda_screen.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/widgets/aset_bulan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers.dart';

const _gps = HasilGps(StatusGps.berhasil, lat: -6.17638, lon: 106.82671);
final _kunci = GlobalKey();
var _urut = 0;

Future<void> _muatFont(String keluarga, List<String> berkas) async {
  final f = FontLoader(keluarga);
  for (final b in berkas) {
    f.addFont(File('assets/fonts/$b').readAsBytes().then(ByteData.sublistView));
  }
  await f.load();
}

Future<void> _ambil(WidgetTester tester, String nama) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.runAsync(() async {
    final b =
        _kunci.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 1);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    _urut++;
    final nomor = _urut.toString().padLeft(2, '0');
    File(
      'build/screenshot/${nomor}_$nama.png',
    ).writeAsBytesSync(data!.buffer.asUint8List());
  });
}

NavigatorState get _nav => Navigasi.navigatorKey.currentState!;

Future<void> _buka(WidgetTester tester, WidgetBuilder b) async {
  _nav.push(MaterialPageRoute<void>(builder: b));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> _tutup(WidgetTester tester) async {
  _nav.pop();
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> _gulir(WidgetTester tester, double dy) async {
  final daftar = find.byType(Scrollable).last;
  await tester.drag(daftar, Offset(0, -dy));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> _cobaAmbil(
  WidgetTester tester,
  String nama,
  Future<void> Function() siapkan,
) async {
  try {
    await siapkan();
    await _ambil(tester, nama);
  } catch (e) {
    debugPrint('GAGAL $nama: $e');
  }
}

Widget _app({bool onboarding = false}) => RepaintBoundary(
  key: _kunci,
  child: buatApp(gps: _gps, sudahOnboarding: !onboarding),
);

void main() {
  testWidgets('tangkapan layar semua halaman', (tester) async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    Directory('build/screenshot').createSync(recursive: true);
    for (final f in Directory('build/screenshot').listSync()) {
      if (f is File) f.deleteSync();
    }
    await tester.runAsync(() async {
      await _muatFont('PlusJakartaSans', [
        'PlusJakartaSans-SemiBold.ttf',
        'PlusJakartaSans-Bold.ttf',
      ]);
      await _muatFont('Inter', [
        'Inter-Regular.ttf',
        'Inter-Medium.ttf',
        'Inter-SemiBold.ttf',
      ]);
      await _muatFont('PhosphorDuotone', ['Phosphor-Duotone.ttf']);
      await _muatFont('PhosphorFill', ['Phosphor-Fill.ttf']);
      await AsetBulan.muat();
    });
    tester.view.physicalSize = const Size(720, 1560);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    // ── Pengantar (onboarding) ──
    await tester.pumpWidget(_app(onboarding: true));
    await tester.pumpAndSettle();
    await _cobaAmbil(tester, 'onboarding_1', () async {});
    for (var i = 2; i <= 3; i++) {
      await _cobaAmbil(tester, 'onboarding_$i', () async {
        await tester.tap(find.text(l.onboardingLanjut));
        await tester.pumpAndSettle();
      });
    }

    // ── Aplikasi utama ──
    // Bongkar dulu: tanpa ini state aplikasi lama (masih di pengantar) dipakai ulang.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    await _cobaAmbil(tester, 'beranda_atas', () async {});
    await _cobaAmbil(tester, 'beranda_bawah', () => _gulir(tester, 3000));

    await _cobaAmbil(tester, 'cuaca_atas', () async {
      await tester.tap(navTab('cuaca'));
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'cuaca_tengah', () => _gulir(tester, 700));
    await _cobaAmbil(tester, 'cuaca_bawah', () => _gulir(tester, 3000));

    await _cobaAmbil(tester, 'udara_dan_uv', () async {
      final pr = Prakiraan.fromJson(fixture('prakiraan_31.71.01.1001.json'));
      await _buka(tester, (_) => UdaraUvScreen(prakiraan: pr));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
    });
    if (find.byType(UdaraUvScreen).evaluate().isNotEmpty) {
      await _tutup(tester);
    }

    await _cobaAmbil(tester, 'gempa_atas', () async {
      await tester.tap(navTab('gempa'));
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'gempa_bawah', () => _gulir(tester, 3000));

    await _cobaAmbil(tester, 'pengaturan_atas', () async {
      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'pengaturan_bawah', () => _gulir(tester, 3000));

    // ── Layar yang dibuka dari dalam ──
    await _cobaAmbil(
      tester,
      'layanan_bmkg',
      () => _buka(tester, (_) => const LayananScreen()),
    );
    await _tutup(tester);
    await _cobaAmbil(tester, 'cuaca_maritim', () async {
      await _buka(tester, (_) => const MaritimScreen());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
    });
    await _tutup(tester);
    await _cobaAmbil(tester, 'siaga_gempa', () async {
      Navigasi.bukaSiaga();
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'siaga_gempa_terbuka', () async {
      final judul = find.byType(ExpansionTile).first;
      await tester.tap(judul);
      await tester.pumpAndSettle();
    });
    await _tutup(tester);
    await _cobaAmbil(tester, 'peringatan_notifikasi', () async {
      Navigasi.bukaPeringatan();
      await tester.pumpAndSettle();
    });
    await _tutup(tester);
    await _cobaAmbil(
      tester,
      'riwayat_gempa',
      () => _buka(tester, (_) => const RiwayatGempaScreen()),
    );
    await _tutup(tester);
    await _cobaAmbil(
      tester,
      'riwayat_notifikasi',
      () => _buka(tester, (_) => const RiwayatNotifikasiScreen()),
    );
    await _tutup(tester);
    await _cobaAmbil(tester, 'pencarian_wilayah', () async {
      bukaPencarian(Navigasi.navigatorKey.currentContext!);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    });
    await _tutup(tester);
    await _cobaAmbil(tester, 'pilih_wilayah', () async {
      bukaPilihWilayah(Navigasi.navigatorKey.currentContext!);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    });
    await _tutup(tester);
    await _cobaAmbil(
      tester,
      'perbandingan_cuaca',
      () => _buka(tester, (_) => const PerbandinganCuacaScreen()),
    );
    await _tutup(tester);
    await _cobaAmbil(
      tester,
      'urutan_beranda',
      () => _buka(tester, (_) => const UrutanBerandaScreen()),
    );
    await _tutup(tester);
    await _cobaAmbil(tester, 'detail_gempa', () async {
      final gempa = Gempa.fromAutoGempaJson(fixture('autogempa.json'));
      await _buka(tester, (_) => GempaDetailScreen(gempa: gempa));
    });
    await _tutup(tester);

    // ── Tema gelap untuk halaman utama ──
    final ctx = tester.element(find.byType(MaterialApp));
    await ctx.read<PengaturanProvider>().pilihTema(PilihanTema.gelap);
    await tester.pumpAndSettle();
    await _cobaAmbil(tester, 'gelap_beranda', () async {
      await tester.tap(navTab('beranda'));
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'gelap_cuaca', () async {
      await tester.tap(navTab('cuaca'));
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'gelap_gempa', () async {
      await tester.tap(navTab('gempa'));
      await tester.pumpAndSettle();
    });
    await _cobaAmbil(tester, 'gelap_pengaturan', () async {
      await tester.tap(navTab('pengaturan'));
      await tester.pumpAndSettle();
    });
    debugPrint('SELESAI: $_urut tangkapan layar di build/screenshot/');
  });
}
