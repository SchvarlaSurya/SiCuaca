import 'package:flutter/material.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';

/// Layar pembuka dalam aplikasi, menutupi [child] sebentar lalu memudar.
/// [child] sudah dibangun di bawahnya sejak awal, jadi data mulai dimuat
/// selama splash tampil.
///
/// Warna latar sama dengan splash bawaan Android (lihat styles.xml), sehingga
/// peralihan dari splash sistem ke layar ini tidak terlihat berkedip. Tidak
/// memakai logo atau nama BMKG. Tanpa gerak (pengaturan "kurangi gerakan"),
/// splash dilewati.
class SplashGerbang extends StatefulWidget {
  const SplashGerbang({super.key, required this.child, this.aktif = true});

  final Widget child;
  final bool aktif;

  static const warnaAwal = Color(0xFF17104A);
  static const warnaAkhir = Color(0xFF6756D8);

  @override
  State<SplashGerbang> createState() => _SplashGerbangState();
}

class _SplashGerbangState extends State<SplashGerbang>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol;
  bool _selesai = false;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _selesai = !widget.aktif;
    if (!_selesai) {
      _kontrol.forward().whenComplete(() {
        if (mounted) setState(() => _selesai = true);
      });
    }
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tampil = !_selesai && !MediaQuery.of(context).disableAnimations;
    // Struktur tetap sama sebelum dan sesudah splash, supaya [child] (dan
    // seluruh state-nya) tidak dibangun ulang saat splash selesai.
    return Stack(
      children: [
        widget.child,
        if (tampil)
          // Menahan ketukan selama splash.
          Positioned.fill(
            child: AbsorbPointer(
              child: AnimatedBuilder(
                animation: _kontrol,
                builder: (context, _) => _Splash(t: _kontrol.value),
              ),
            ),
          ),
      ],
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({required this.t});

  /// 0..1 sepanjang splash: masuk 0 sampai .45, tahan, lalu memudar .78 sampai 1.
  final double t;

  static double _antara(double nilai, double a, double b) =>
      ((nilai - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final masuk = Curves.easeOutBack.transform(_antara(t, 0, .45));
    final teks = Curves.easeOutCubic.transform(_antara(t, .18, .55));
    final keluar = 1 - Curves.easeIn.transform(_antara(t, .78, 1));

    return Opacity(
      opacity: keluar,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [SplashGerbang.warnaAwal, SplashGerbang.warnaAkhir],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                Transform.scale(
                  scale: .6 + .4 * masuk,
                  child: Opacity(
                    opacity: _antara(t, 0, .25),
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .28),
                          width: 1.5,
                        ),
                      ),
                      child: const IkonDuo(
                        IkonApp.cuaca,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: teks,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - teks)),
                    child: Column(
                      children: [
                        Text(
                          l.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            l.splashTagline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFE6E2FF),
                              fontSize: 15,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 6),
                Opacity(
                  opacity: teks,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                    child: Text(
                      l.bukanResmi,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFCFC9F5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
