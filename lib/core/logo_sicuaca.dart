import 'package:flutter/widgets.dart';

/// Logo SiCuaca (awan dan burung), digambar langsung dari data vektor aslinya
/// (assets/logo/logo_sicuaca.svg, kotak 710 x 596) supaya tajam di ukuran apa
/// pun tanpa paket SVG. Hasil buatan skrip; jangan diubah manual.
abstract final class LogoSiCuaca {
  static const double lebarAsli = 710;
  static const double tinggiAsli = 596;
  static const double rasio = lebarAsli / tinggiAsli;

  /// Path logo dalam koordinat asli.
  static Path path() => Path()
    ..moveTo(241.189, 342.373)
    ..cubicTo(249.05, 351.149, 259.516, 358.473, 271.938, 358.473)
    ..cubicTo(261.655, 374.818, 256.513, 393.574, 256.513, 414.739)
    ..cubicTo(256.513, 443.306, 266.058, 466.266, 285.146, 483.62)
    ..cubicTo(304.369, 500.974, 330.401, 514.122, 363.239, 523.066)
    ..lineTo(411.696, 536.282)
    ..cubicTo(426.38, 540.153, 439.529, 544.626, 451.143, 549.698)
    ..cubicTo(462.89, 554.771, 472.168, 561.178, 478.976, 568.921)
    ..cubicTo(485.332, 576.011, 488.776, 584.948, 489.312, 595.731)
    ..lineTo(235.755, 595.731)
    ..cubicTo(168.186, 595.731, 113.397, 543.031, 113.396, 478.019)
    ..cubicTo(113.396, 413.005, 168.186, 360.305, 235.755, 360.305)
    ..lineTo(238.396, 360.305)
    ..cubicTo(239.046, 354.237, 239.979, 348.253, 241.189, 342.373)
    ..close()
    ..moveTo(411.622, 212.299)
    ..cubicTo(516.64, 212.299, 576.2, 279.358, 584.849, 360.305)
    ..lineTo(587.49, 360.305)
    ..cubicTo(655.059, 360.305, 709.848, 413.005, 709.848, 478.019)
    ..cubicTo(709.847, 543.031, 655.059, 595.731, 587.49, 595.731)
    ..lineTo(550.61, 595.731)
    ..cubicTo(550.156, 578.852, 546.503, 564.242, 539.647, 551.901)
    ..cubicTo(538.161, 549.177, 536.578, 546.543, 534.899, 544)
    ..cubicTo(542.155, 548.4, 550.656, 539.167, 554, 534)
    ..cubicTo(542.4, 540, 530.388, 535.292, 525.831, 532.188)
    ..cubicTo(543.696, 535.537, 572.054, 510.149, 584, 497.036)
    ..cubicTo(554.308, 520.665, 502.318, 508.69, 476.667, 498.561)
    ..cubicTo(475.442, 498.038, 474.21, 497.53, 472.969, 497.036)
    ..cubicTo(459.219, 491.563, 445.803, 487.224, 432.721, 484.021)
    ..lineTo(392.674, 473.608)
    ..cubicTo(384.664, 471.606, 376.321, 469.069, 367.645, 465.999)
    ..cubicTo(358.968, 462.795, 350.825, 458.858, 343.216, 454.186)
    ..cubicTo(335.74, 449.38, 329.666, 443.439, 324.994, 436.364)
    ..cubicTo(320.455, 429.289, 318.186, 420.88, 318.186, 411.135)
    ..cubicTo(318.186, 399.521, 321.523, 389.175, 328.197, 380.098)
    ..cubicTo(335.005, 370.887, 344.55, 363.679, 356.831, 358.473)
    ..cubicTo(369.112, 353.133, 383.664, 350.463, 400.483, 350.463)
    ..cubicTo(423.978, 350.463, 443.467, 355.737, 458.952, 366.282)
    ..cubicTo(474.438, 376.695, 542.918, 391.378, 545.054, 410.334)
    ..cubicTo(544.52, 388.308, 538.112, 368.818, 525.831, 351.865)
    ..cubicTo(513.55, 334.778, 496.73, 321.362, 475.371, 311.617)
    ..cubicTo(454.146, 301.872, 429.651, 297, 401.885, 297)
    ..cubicTo(395.261, 297, 388.799, 297.286, 382.5, 297.859)
    ..cubicTo(379.072, 298.171, 375.691, 298.569, 372.359, 299.051)
    ..cubicTo(346.409, 301.178, 303.855, 298.413, 269.172, 277.909)
    ..cubicTo(297.939, 238.388, 345.847, 212.299, 411.622, 212.299)
    ..close()
    ..moveTo(49.5, 0)
    ..cubicTo(102.194, 78.2426, 194.945, 93.4804, 258.788, 89.9961)
    ..cubicTo(272.298, 86.3635, 286.32, 84.4864, 300.512, 84.4883)
    ..cubicTo(362.543, 84.4883, 416.65, 119.765, 443.362, 171.613)
    ..cubicTo(432.832, 170.316, 422.232, 169.675, 411.622, 169.695)
    ..cubicTo(309.799, 169.695, 235.584, 225.379, 209.085, 309.691)
    ..lineTo(206.443, 318.809)
    ..lineTo(204.483, 326.775)
    ..lineTo(197.454, 328.054)
    ..cubicTo(171.72, 333.28, 147.683, 344.802, 127.49, 361.589)
    ..cubicTo(107.298, 378.376, 91.5798, 399.905, 81.7422, 424.252)
    ..cubicTo(61.4463, 411.886, 45.6235, 393.37, 36.5732, 371.395)
    ..cubicTo(27.523, 349.419, 25.7165, 325.13, 31.418, 302.058)
    ..cubicTo(37.1195, 278.986, 50.0319, 258.333, 68.2764, 243.103)
    ..cubicTo(77.114, 235.725, 86.9798, 229.806, 97.5, 225.494)
    ..cubicTo(73.5083, 223.089, 22.5035, 155.523, 0, 122.04)
    ..cubicTo(38.4001, 166.471, 129.312, 160.193, 169.969, 151.5)
    ..cubicTo(102.344, 145.1, 61.4793, 47.8333, 49.5, 0)
    ..close()
    ..moveTo(256.778, 297.975)
    ..cubicTo(265.439, 315.089, 279.514, 329.343, 300.993, 327.37)
    ..cubicTo(300.988, 327.374, 300.983, 327.378, 300.978, 327.382)
    ..cubicTo(288.723, 334.116, 263.852, 342.04, 243.406, 332.896)
    ..cubicTo(246.618, 320.666, 251.081, 308.957, 256.778, 297.975)
    ..close();
}

/// Menggambar [LogoSiCuaca] berwarna [warna] memenuhi ukuran kanvas
/// (menjaga rasio, rata tengah).
class PelukisLogo extends CustomPainter {
  const PelukisLogo(this.warna);

  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final skala =
        size.width / LogoSiCuaca.lebarAsli <
            size.height / LogoSiCuaca.tinggiAsli
        ? size.width / LogoSiCuaca.lebarAsli
        : size.height / LogoSiCuaca.tinggiAsli;
    final w = LogoSiCuaca.lebarAsli * skala;
    final h = LogoSiCuaca.tinggiAsli * skala;
    canvas
      ..translate((size.width - w) / 2, (size.height - h) / 2)
      ..scale(skala);
    canvas.drawPath(
      LogoSiCuaca.path(),
      Paint()
        ..color = warna
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(PelukisLogo lama) => lama.warna != warna;
}

/// Logo siap pakai di pohon widget: lebar [lebar], tinggi mengikuti rasio.
class TampilanLogo extends StatelessWidget {
  const TampilanLogo({
    super.key,
    required this.lebar,
    this.warna = const Color(0xFFFFFFFF),
  });

  final double lebar;
  final Color warna;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: lebar,
    height: lebar / LogoSiCuaca.rasio,
    child: CustomPaint(painter: PelukisLogo(warna)),
  );
}
