import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/logo_sicuaca.dart';
import '../core/theme.dart';

/// Layar pembuka dalam aplikasi, menutupi [child] sebentar lalu memudar.
/// [child] sudah dibangun di bawahnya sejak awal, jadi data mulai dimuat
/// selama splash tampil.
///
/// Melanjutkan splash native Android: awalnya hanya logo SiCuaca di tengah
/// (ukuran dan latar sama dengan splash native, jadi peralihannya tidak
/// terlihat). Lalu teks "SiCuaca" keluar dari samping logo (logo bergeser ke
/// kiri menjaga susunan tetap di tengah), bertahan sebentar, dan seluruhnya
/// memudar. Tanpa gerak (pengaturan "kurangi gerakan"), splash dilewati.
class SplashGerbang extends StatefulWidget {
  const SplashGerbang({super.key, required this.child, this.aktif = true});

  final Widget child;
  final bool aktif;

  /// Warna latar splash native (harus sama dengan res/values/colors.xml).
  static const warnaAwal = Color(0xFF0B2552);
  static const warnaAkhir = Color(0xFF2F7BDB);

  /// Lebar logo (dp), sama dengan splash native.
  static const lebarLogo = 128.0;

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
      duration: const Duration(milliseconds: 2400),
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

  /// 0..1 sepanjang splash: logo diam 0 sampai .12, teks keluar .12 sampai
  /// .46, bertahan, lalu memudar .82 sampai 1.
  final double t;

  static double _antara(double nilai, double a, double b) =>
      ((nilai - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final keluar = _antara(t, .12, .46);
    final teks = Curves.easeOutCubic.transform(keluar);
    final gradasi = _antara(t, 0, .4);
    final pudar = 1 - Curves.easeIn.transform(_antara(t, .82, 1));

    return Opacity(
      opacity: pudar,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Awalnya datar seperti splash native; gradasi biru menyusul.
            const ColoredBox(color: SplashGerbang.warnaAwal),
            Opacity(
              opacity: gradasi,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SplashGerbang.warnaAwal, SplashGerbang.warnaAkhir],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TampilanLogo(lebar: SplashGerbang.lebarLogo),
                      // Teks dibuka dari samping logo: lebarnya tumbuh (logo
                      // ikut bergeser ke kiri), dan teks sedikit meluncur.
                      ClipRect(
                        key: const ValueKey('splash.teks'),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: teks,
                          child: Opacity(
                            opacity: teks,
                            child: Transform.translate(
                              offset: Offset(-24 * (1 - teks), 0),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  l.appName,
                                  maxLines: 1,
                                  softWrap: false,
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.hurufJudul,
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -.5,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Opacity(
                    opacity: _antara(t, .3, .5),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                      child: Text(
                        l.bukanResmi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFCFE0FA),
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
          ],
        ),
      ),
    );
  }
}
