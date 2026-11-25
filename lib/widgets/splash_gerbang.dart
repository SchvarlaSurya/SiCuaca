import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
///
/// Agar animasinya benar-benar terlihat di HP yang lambat saat memulai:
/// - Frame pertama hanya berisi splash (murah), jadi peralihan dari splash
///   native langsung mulus. [child] yang berat baru dipasang di frame
///   berikutnya.
/// - Jam animasi baru mulai setelah frame pertama, dan loncatan waktu akibat
///   frame yang tersendat dibatasi ([maksLangkah]); tanpa itu, frame lambat
///   memakan seluruh animasi dan teks tidak sempat terlihat.
class SplashGerbang extends StatefulWidget {
  const SplashGerbang({super.key, required this.child, this.aktif = true});

  final Widget child;
  final bool aktif;

  /// Warna latar splash native (harus sama dengan res/values/colors.xml).
  static const warnaAwal = Color(0xFF0B2552);
  static const warnaAkhir = Color(0xFF2F7BDB);

  /// Lebar logo (dp), sama dengan splash native.
  static const lebarLogo = 128.0;

  /// Lama splash saat semua frame mulus.
  static const durasi = Duration(milliseconds: 2000);

  /// Batas waktu yang dihitung per frame. Frame yang tersendat lebih lama dari
  /// ini hanya memajukan animasi sebesar batas ini.
  static const maksLangkah = Duration(milliseconds: 50);

  @override
  State<SplashGerbang> createState() => _SplashGerbangState();
}

class _SplashGerbangState extends State<SplashGerbang>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _t = ValueNotifier<double>(0);
  Duration _terakhir = Duration.zero;
  Duration _terkumpul = Duration.zero;
  bool _selesai = false;
  bool _anakSiap = false;

  @override
  void initState() {
    super.initState();
    _selesai = !widget.aktif;
    _anakSiap = !widget.aktif;
    _ticker = createTicker(_tik);
    if (!_selesai) {
      // Frame pertama: hanya splash. Sesudahnya pasang [child] dan mulai jam.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _anakSiap = true);
        _ticker.start();
      });
    }
  }

  void _tik(Duration elapsed) {
    final langkah = elapsed - _terakhir;
    _terakhir = elapsed;
    _terkumpul += langkah > SplashGerbang.maksLangkah
        ? SplashGerbang.maksLangkah
        : langkah;
    final nilai =
        _terkumpul.inMicroseconds / SplashGerbang.durasi.inMicroseconds;
    if (nilai >= 1) {
      _t.value = 1;
      _ticker.stop();
      setState(() => _selesai = true);
    } else {
      _t.value = nilai;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tampil = !_selesai && !MediaQuery.of(context).disableAnimations;
    // Struktur tetap sama sebelum dan sesudah splash, supaya [child] (dan
    // seluruh state-nya) tidak dibangun ulang saat splash selesai.
    return Stack(
      children: [
        _anakSiap || !tampil ? widget.child : const SizedBox.shrink(),
        if (tampil)
          // Menahan ketukan selama splash.
          Positioned.fill(
            child: AbsorbPointer(
              child: ValueListenableBuilder<double>(
                valueListenable: _t,
                builder: (context, t, _) => _Splash(t: t),
              ),
            ),
          ),
      ],
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({required this.t});

  /// 0..1 sepanjang splash: logo diam 0 sampai .10, teks keluar .10 sampai
  /// .45, bertahan, lalu memudar .80 sampai 1.
  final double t;

  static double _antara(double nilai, double a, double b) =>
      ((nilai - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final keluar = _antara(t, .10, .45);
    final teks = Curves.easeOutCubic.transform(keluar);
    final gradasi = _antara(t, 0, .4);
    final pudar = 1 - Curves.easeIn.transform(_antara(t, .80, 1));

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
