import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'aset_bulan.dart';

/// Bagian bulan yang terang, dalam koordinat dengan pusat (0,0) dan jari-jari
/// [r], untuk bulan yang membesar (sisi kanan terang). [elongasi] 0..360:
/// 0 bulan baru, 90 perempat pertama, 180 purnama; di atas 180 bentuknya sama
/// seperti 360 - elongasi tetapi tercermin (lukisan memantulkannya).
///
/// Bentuknya: setengah lingkaran tepi di kanan, ditutup garis batas terang
/// gelap (terminator) berupa setengah elips selebar |cos(elongasi)| * r.
/// Sabit bila elips menggembung ke kanan, cembung bila ke kiri.
Path jalurTerangBulan(double elongasi, double r) {
  final e = elongasi % 360;
  final sudut = e <= 180 ? e : 360 - e; // 0..180 dari bulan baru
  final lebar = math.max(r * math.cos(sudut * math.pi / 180).abs(), r * 1e-4);
  final cembung = sudut > 90;
  return Path()
    ..moveTo(0, -r)
    ..arcToPoint(Offset(0, r), radius: Radius.circular(r), clockwise: true)
    ..arcToPoint(
      Offset(0, -r),
      radius: Radius.elliptical(lebar, r),
      clockwise: cembung,
    )
    ..close();
}

// Dataran gelap (mare) yang kasar: (x, y, jari-jari) dalam satuan jari-jari
// bulan, dilihat dari belahan bumi utara.
const _mare = <(double, double, double)>[
  (-.30, -.34, .30), // Imbrium
  (.14, -.34, .17), // Serenitatis
  (.34, -.08, .19), // Tranquillitatis
  (.62, -.22, .10), // Crisium
  (-.62, .02, .26), // Oceanus Procellarum
  (-.22, .36, .17), // Nubium
  (.56, .16, .12), // Fecunditatis
  (-.06, .08, .09), // Vapores
];

/// Melukis bulan dengan bayangan sesuai fase.
///
/// Bila foto bulan NASA dan shadernya sudah dimuat ([AsetBulan]), bulan
/// digambar dari fotonya dengan pencahayaan fisik (batas terang-gelap lembut,
/// kawah berbayang). Selain itu (belum dimuat, atau perangkat tanpa dukungan
/// shader) dipakai gambar prosedural: cakram berbintik (mare dan kawah kasar)
/// lalu sisi gelap menutupinya mengikuti [jalurTerangBulan]. Sisi gelap
/// sedikit tembus (cahaya bumi) supaya cakramnya tetap terbaca.
///
/// Dari belahan bumi selatan bulan tampak terbalik 180 derajat dibanding
/// utara, jadi sisi terangnya berpindah dan mare ikut terbalik ([selatan]).
void lukisBulan(
  Canvas canvas,
  Offset pusat,
  double r,
  double elongasi, {
  bool selatan = false,
}) {
  final dpr =
      ui.PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ?? 2.0;
  final shader = AsetBulan.shader(
    diameterPiksel: 2 * r * dpr,
    ukuranLokal: 2 * r,
    elongasi: elongasi,
  );
  if (shader != null) {
    _lukisFoto(canvas, pusat, r, elongasi, selatan, shader);
    return;
  }
  _lukisProsedural(canvas, pusat, r, elongasi, selatan);
}

/// Jalur foto: pendar di sisi terang, lalu cakram foto yang disinari shader.
/// Shader dilukis di kotak berukuran 2r yang digeser ke pojok (0,0) lokal,
/// supaya koordinatnya cocok dengan foto; belahan selatan memutar kanvas.
void _lukisFoto(
  Canvas canvas,
  Offset pusat,
  double r,
  double elongasi,
  bool selatan,
  ui.FragmentShader shader,
) {
  canvas.save();
  canvas.translate(pusat.dx, pusat.dy);
  if (selatan) canvas.rotate(math.pi);

  // Pendar lembut di sekitar sisi yang terang (bentuk sama dengan jalur
  // prosedural; bulan menyusut dicerminkan).
  canvas.save();
  if (elongasi % 360 > 180) canvas.scale(-1, 1);
  canvas.drawPath(
    jalurTerangBulan(elongasi, r),
    Paint()
      ..color = const Color(0xFFFFF3C4).withValues(alpha: .30)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, r * .22),
  );
  canvas.restore();

  canvas.translate(-r, -r);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, 2 * r, 2 * r),
    Paint()
      ..shader = shader
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _lukisProsedural(
  Canvas canvas,
  Offset pusat,
  double r,
  double elongasi,
  bool selatan,
) {
  final membesar = elongasi % 360 <= 180;
  canvas.save();
  canvas.translate(pusat.dx, pusat.dy);
  if (selatan) canvas.rotate(math.pi);
  if (!membesar) canvas.scale(-1, 1);

  final lingkaran = Path()
    ..addOval(Rect.fromCircle(center: Offset.zero, radius: r));
  final terang = jalurTerangBulan(elongasi, r);
  final gelap = Path.combine(PathOperation.difference, lingkaran, terang);

  // Pendar lembut di sekitar sisi yang terang.
  canvas.drawPath(
    terang,
    Paint()
      ..color = const Color(0xFFFFF3C4).withValues(alpha: .35)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, r * .22),
  );

  canvas.save();
  canvas.clipPath(lingkaran);
  // Cakram: abu terang dengan sedikit gradasi ke tepi.
  canvas.drawCircle(
    Offset.zero,
    r,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(-r * .25, -r * .25),
        r * 1.35,
        const [Color(0xFFF4F1E6), Color(0xFFCFCAB8), Color(0xFFA9A493)],
        const [0, .7, 1],
      ),
  );
  // Mare.
  for (final (x, y, jr) in _mare) {
    final c = Offset(x * r, y * r);
    canvas.drawCircle(
      c,
      jr * r,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          jr * r,
          [
            const Color(0xFF7D786A).withValues(alpha: .55),
            const Color(0xFF7D786A).withValues(alpha: 0),
          ],
          const [.2, 1],
        ),
    );
  }
  // Kawah kecil.
  final kawah = Paint()..color = const Color(0xFF8C8778).withValues(alpha: .35);
  for (final (x, y, jr) in const [
    (.30, .55, .05),
    (-.45, -.62, .04),
    (.05, .70, .035),
    (.72, .30, .04),
    (-.78, .38, .045),
    (.18, -.72, .035),
  ]) {
    canvas.drawCircle(Offset(x * r, y * r), jr * r, kawah);
  }
  // Sisi gelap: malam tembus sedikit, tepinya dilunakkan.
  canvas.drawPath(
    gelap,
    Paint()
      ..color = const Color(0xFF0A1226).withValues(alpha: .88)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, r * .035),
  );
  canvas.restore();

  // Garis tepi tipis supaya cakram gelap tetap terlihat.
  canvas.drawCircle(
    Offset.zero,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(.6, r * .03)
      ..color = const Color(0xFFFFFFFF).withValues(alpha: .22),
  );
  canvas.restore();
}

/// Gambar bulan berukuran [ukuran] dengan bayangan sesuai [elongasi].
class GambarBulan extends StatelessWidget {
  const GambarBulan({
    super.key,
    required this.elongasi,
    this.ukuran = 56,
    this.selatan = true,
    this.semantik,
  });

  final double elongasi;
  final double ukuran;

  /// Belahan bumi selatan (default: Indonesia sebagian besar di selatan).
  final bool selatan;
  final String? semantik;

  @override
  Widget build(BuildContext context) {
    // Mulai memuat foto bulan (sekali); selama belum siap, gambar prosedural.
    AsetBulan.muat();
    final gambar = SizedBox.square(
      dimension: ukuran,
      child: CustomPaint(
        painter: _PelukisBulan(elongasi, selatan),
        isComplex: true,
      ),
    );
    return semantik == null
        ? ExcludeSemantics(child: gambar)
        : Semantics(label: semantik, image: true, child: gambar);
  }
}

class _PelukisBulan extends CustomPainter {
  _PelukisBulan(this.elongasi, this.selatan) : super(repaint: AsetBulan.siap);

  final double elongasi;
  final bool selatan;

  @override
  void paint(Canvas canvas, Size size) {
    lukisBulan(
      canvas,
      size.center(Offset.zero),
      size.shortestSide / 2 * .86,
      elongasi,
      selatan: selatan,
    );
  }

  @override
  bool shouldRepaint(_PelukisBulan lama) =>
      lama.elongasi != elongasi || lama.selatan != selatan;
}
