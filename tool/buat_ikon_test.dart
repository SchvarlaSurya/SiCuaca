// Generator ikon aplikasi dan gambar splash dari logo vektor SiCuaca.
//
// Jalankan dari akar proyek:
//   flutter test tool/buat_ikon_test.dart
//
// Menulis ulang berkas PNG di android/app/src/main/res dan web/. Berada di
// tool/ (bukan test/) sehingga tidak ikut `flutter test` biasa.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/logo_sicuaca.dart';

const _atas = Color(0xFF0B2552);
const _bawah = Color(0xFF2F7BDB);

Future<void> _tulis(
  WidgetTester tester,
  String berkas, {
  required int lebar,
  required int tinggi,
  required double bagianLogo,
  required bool latar,
}) async {
  await tester.runAsync(() async {
    final rekam = ui.PictureRecorder();
    final c = Canvas(rekam);
    final w = lebar.toDouble();
    final h = tinggi.toDouble();
    if (latar) {
      c.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0, h),
            const [_atas, _bawah],
          ),
      );
    }
    // Logo selebar bagianLogo dari lebar kanvas, rata tengah.
    final lw = w * bagianLogo;
    final lh = lw / LogoSiCuaca.rasio;
    c.save();
    c.translate((w - lw) / 2, (h - lh) / 2);
    const PelukisLogo(Color(0xFFFFFFFF)).paint(c, Size(lw, lh));
    c.restore();
    final gambar = await rekam.endRecording().toImage(lebar, tinggi);
    final data = await gambar.toByteData(format: ui.ImageByteFormat.png);
    final file = File(berkas);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  const res = 'android/app/src/main/res';
  const kepadatan = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0};

  testWidgets('buat ikon dan gambar splash', (tester) async {
    for (final e in kepadatan.entries) {
      final d = e.value;
      // Ikon lama (pra-Android 8): persegi penuh dengan latar gradasi.
      final ikon = (48 * d).round();
      await _tulis(
        tester,
        '$res/mipmap-${e.key}/ic_launcher.png',
        lebar: ikon,
        tinggi: ikon,
        bagianLogo: .62,
        latar: true,
      );
      // Latar depan ikon adaptif (108 dp), logo di zona aman (48 dp).
      final adaptif = (108 * d).round();
      await _tulis(
        tester,
        '$res/drawable-${e.key}/ic_launcher_foreground.png',
        lebar: adaptif,
        tinggi: adaptif,
        bagianLogo: 48 / 108,
        latar: false,
      );
      // Logo splash pra-Android 12 (selebar 128 dp, sama dengan splash dalam
      // aplikasi).
      final lebar = (128 * d).round();
      await _tulis(
        tester,
        '$res/drawable-${e.key}/logo_splash.png',
        lebar: lebar,
        tinggi: (lebar / LogoSiCuaca.rasio).round(),
        bagianLogo: 1,
        latar: false,
      );
    }
    // Web.
    for (final px in [192, 512]) {
      await _tulis(tester, 'web/icons/Icon-$px.png',
          lebar: px, tinggi: px, bagianLogo: .62, latar: true);
      await _tulis(tester, 'web/icons/Icon-maskable-$px.png',
          lebar: px, tinggi: px, bagianLogo: .5, latar: true);
    }
    await _tulis(tester, 'web/favicon.png',
        lebar: 32, tinggi: 32, bagianLogo: .7, latar: true);
  });
}
