import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/warna_semantik.dart';

/// Widget pembungkus untuk menambahkan partikel animasi halus di latar belakang
/// kartu cuaca (HeroCuaca), disesuaikan dengan kondisi langit dan waktu (siang/malam).
///
/// Bila pengguna mengaktifkan "kurangi gerakan/animasi" di pengaturan sistem,
/// animasi otomatis dimatikan demi aksesibilitas dan performa baterai.
class AnimasiCuaca extends StatefulWidget {
  const AnimasiCuaca({
    super.key,
    required this.kondisi,
    required this.malam,
    required this.child,
  });

  final KondisiLangit kondisi;
  final bool malam;
  final Widget child;

  @override
  State<AnimasiCuaca> createState() => _AnimasiCuacaState();
}

class _AnimasiCuacaState extends State<AnimasiCuaca>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nonaktifAnimasi = MediaQuery.of(context).disableAnimations;

    if (nonaktifAnimasi) {
      return widget.child;
    }

    final kecerahan = Theme.of(context).brightness;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusHero),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _CuacaPartikelPainter(
                  progress: _controller,
                  kondisi: widget.kondisi,
                  malam: widget.malam,
                  kecerahan: kecerahan,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _CuacaPartikelPainter extends CustomPainter {
  _CuacaPartikelPainter({
    required this.progress,
    required this.kondisi,
    required this.malam,
    required this.kecerahan,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final KondisiLangit kondisi;
  final bool malam;
  final Brightness kecerahan;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final t = progress.value;

    switch (kondisi) {
      case KondisiLangit.cerah:
        if (malam) {
          _gambarBintangMalam(canvas, size, t);
        } else {
          _gambarSinarMatahari(canvas, size, t);
        }
      case KondisiLangit.berawan:
        _gambarAwanBergerak(canvas, size, t);
      case KondisiLangit.kabut:
        _gambarKabutBergerak(canvas, size, t);
      case KondisiLangit.hujan:
        _gambarHujan(canvas, size, t);
      case KondisiLangit.petir:
        _gambarPetir(canvas, size, t);
    }
  }

  /// Cerah Siang: Lingkaran cahaya lembut dan garis sinar berputar perlahan.
  void _gambarSinarMatahari(Canvas canvas, Size size, double t) {
    final pusat = Offset(size.width * 0.85, size.height * 0.25);
    final warnaSinar = Colors.white.withValues(
      alpha: kecerahan == Brightness.dark ? 0.08 : 0.15,
    );

    // Cahaya lingkaran tengah (halo)
    final haloPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.10 + 0.05 * math.sin(t * 2 * math.pi),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pusat, 42, haloPaint);

    // 8 Sinar halus berputar perlahan
    final rayPaint = Paint()
      ..color = warnaSinar
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final sudutDasar = t * 2 * math.pi;
    const jumlahSinar = 8;
    for (var i = 0; i < jumlahSinar; i++) {
      final sudut = sudutDasar + (i * 2 * math.pi / jumlahSinar);
      final awal = Offset(
        pusat.dx + math.cos(sudut) * 46,
        pusat.dy + math.sin(sudut) * 46,
      );
      final akhir = Offset(
        pusat.dx + math.cos(sudut) * 82,
        pusat.dy + math.sin(sudut) * 82,
      );
      canvas.drawLine(awal, akhir, rayPaint);
    }
  }

  /// Cerah Malam: Bintang berkedip halus pada posisi tetap.
  void _gambarBintangMalam(Canvas canvas, Size size, double t) {
    // 20 Bintang dengan koordinat proporsional dan kecepatan kedip berbeda
    const bintang = <(double, double, double, double)>[
      (0.10, 0.20, 1.5, 1.0),
      (0.22, 0.12, 2.0, 1.5),
      (0.35, 0.28, 1.2, 0.8),
      (0.48, 0.15, 2.2, 2.0),
      (0.60, 0.32, 1.5, 1.2),
      (0.72, 0.18, 1.8, 1.7),
      (0.85, 0.35, 1.4, 0.9),
      (0.92, 0.12, 2.0, 2.2),
      (0.15, 0.60, 1.3, 1.4),
      (0.28, 0.75, 1.6, 0.7),
      (0.42, 0.65, 2.0, 1.9),
      (0.55, 0.80, 1.2, 1.1),
      (0.68, 0.58, 1.8, 1.6),
      (0.80, 0.72, 2.2, 1.3),
      (0.08, 0.85, 1.5, 2.1),
      (0.30, 0.42, 1.2, 1.0),
      (0.50, 0.48, 1.6, 1.8),
      (0.75, 0.45, 1.4, 0.8),
      (0.88, 0.88, 2.0, 1.5),
      (0.65, 0.90, 1.3, 1.2),
    ];

    for (final (xNorm, yNorm, radius, speed) in bintang) {
      final kedip = (math.sin(t * 2 * math.pi * speed + xNorm * 10) + 1) / 2;
      final alpha = 0.10 + (kedip * 0.55);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(xNorm * size.width, yNorm * size.height),
        radius,
        paint,
      );
    }
  }

  /// Berawan: Bentuk awan lembut melayang dari kiri ke kanan.
  void _gambarAwanBergerak(Canvas canvas, Size size, double t) {
    const awanList = <(double, double, double, double)>[
      (0.1, 0.20, 48.0, 0.8),
      (0.5, 0.35, 60.0, 0.6),
      (0.85, 0.18, 42.0, 1.0),
      (0.3, 0.65, 52.0, 0.7),
    ];

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (final (initX, yNorm, lebar, speed) in awanList) {
      final x = ((initX + t * speed * 0.4) % 1.4 - 0.2) * size.width;
      final y = yNorm * size.height;

      // Bentuk awan dari 3 lingkaran yang menyatu
      canvas.drawCircle(Offset(x, y), lebar * 0.35, paint);
      canvas.drawCircle(Offset(x + lebar * 0.25, y - 6), lebar * 0.45, paint);
      canvas.drawCircle(Offset(x + lebar * 0.50, y), lebar * 0.35, paint);
    }
  }

  /// Kabut: Garis gelombang kabut horizontal mengambang santai.
  void _gambarKabutBergerak(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.25 + i * 0.22);
      final offset = math.sin((t * 2 * math.pi) + (i * 1.5)) * 18;
      canvas.drawLine(
        Offset(size.width * 0.05 + offset, y),
        Offset(size.width * 0.95 + offset, y),
        paint,
      );
    }
  }

  /// Hujan: Garis tetesan air miring jatuh ke bawah.
  void _gambarHujan(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: kecerahan == Brightness.dark ? 0.28 : 0.38,
      )
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const tetes = <(double, double, double, double)>[
      (0.08, 0.10, 14, 2.0),
      (0.18, 0.50, 18, 2.4),
      (0.28, 0.25, 12, 1.8),
      (0.38, 0.80, 16, 2.2),
      (0.48, 0.05, 15, 2.5),
      (0.58, 0.65, 13, 2.1),
      (0.68, 0.35, 17, 2.3),
      (0.78, 0.90, 14, 2.0),
      (0.88, 0.15, 19, 2.6),
      (0.95, 0.45, 12, 1.9),
      (0.12, 0.85, 16, 2.2),
      (0.32, 0.55, 14, 2.0),
      (0.52, 0.30, 18, 2.4),
      (0.72, 0.75, 13, 2.1),
      (0.84, 0.60, 15, 2.3),
      (0.04, 0.40, 14, 1.8),
      (0.24, 0.02, 17, 2.5),
      (0.44, 0.48, 12, 2.0),
      (0.64, 0.12, 15, 2.2),
      (0.92, 0.78, 16, 2.4),
    ];

    for (final (xNorm, yNorm, len, speed) in tetes) {
      final yCurr = ((yNorm + t * speed * 3.0) % 1.0) * size.height;
      final xCurr = xNorm * size.width;

      canvas.drawLine(
        Offset(xCurr, yCurr),
        Offset(xCurr - 3.0, yCurr + len),
        paint,
      );
    }
  }

  /// Petir: Hujan lebat disertai kilatan cahaya singkat.
  void _gambarPetir(Canvas canvas, Size size, double t) {
    // Gambar hujan dasar terlebih dahulu
    _gambarHujan(canvas, size, t);

    // Kilatan petir di dua titik waktu (t ~ 0.38 dan t ~ 0.82)
    var alphaFlash = 0.0;
    if (t >= 0.36 && t <= 0.42) {
      final fase = (t - 0.36) / 0.06;
      alphaFlash = math.sin(fase * math.pi) * 0.22;
    } else if (t >= 0.80 && t <= 0.84) {
      final fase = (t - 0.80) / 0.04;
      alphaFlash = math.sin(fase * math.pi) * 0.18;
    }

    if (alphaFlash > 0.01) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: alphaFlash)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CuacaPartikelPainter oldDelegate) {
    return oldDelegate.kondisi != kondisi ||
        oldDelegate.malam != malam ||
        oldDelegate.kecerahan != kecerahan ||
        oldDelegate.progress != progress;
  }
}
