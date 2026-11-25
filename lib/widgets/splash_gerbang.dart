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
///   native langsung mulus dan tidak menunggu inisialisasi berat.
/// - [child] yang berat baru dipasang setelah [siapkan] selesai. Selama itu
///   hanya logo yang diam; animasi teks ditahan di ujung fase logo dan baru
///   jalan setelah [child] selesai dibangun, supaya geseran teks tidak
///   tersendat oleh pembangunan aplikasi.
/// - Loncatan waktu akibat frame tersendat dibatasi ([maksLangkah]), supaya
///   frame lambat tidak memakan seluruh animasi.
class SplashGerbang extends StatefulWidget {
  const SplashGerbang({
    super.key,
    required this.child,
    this.aktif = true,
    this.siapkan,
  });

  final Widget child;
  final bool aktif;

  /// Pekerjaan awal yang harus selesai sebelum [child] dipasang (mis. muat
  /// shader kaca). Berjalan selagi splash tampil.
  final Future<void>? siapkan;

  /// Warna latar splash native (harus sama dengan res/values/colors.xml).
  static const warnaAwal = Color(0xFF0B2552);
  static const warnaAkhir = Color(0xFF2F7BDB);

  /// Lebar logo (dp), sama dengan splash native.
  static const lebarLogo = 128.0;

  /// Lama splash saat semua frame mulus.
  static const durasi = Duration(milliseconds: 1600);

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
  bool _anakDibangun = false;

  // Animasi ditahan di sini (akhir fase logo) sampai [child] selesai dibangun.
  static const _titikTahan = .10;

  @override
  void initState() {
    super.initState();
    _selesai = !widget.aktif;
    _anakSiap = !widget.aktif;
    _ticker = createTicker(_tik);
    if (!_selesai) {
      // Frame pertama: hanya splash. Sesudahnya jam mulai, dan [child]
      // dipasang begitu pekerjaan awal selesai.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ticker.start();
        (widget.siapkan ?? Future<void>.value()).whenComplete(() {
          if (!mounted) return;
          setState(() => _anakSiap = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _anakDibangun = true;
          });
        });
      });
    }
  }

  void _tik(Duration elapsed) {
    final langkah = elapsed - _terakhir;
    _terakhir = elapsed;
    final titikTahan = SplashGerbang.durasi * _titikTahan;
    if (!_anakDibangun && _terkumpul >= titikTahan) return;
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
    // StackFit.expand: sebelum [child] dipasang, tidak ada anak tanpa posisi
    // yang memberi ukuran, jadi tanpa ini Stack mengecil jadi 0x0 di bawah
    // batas longgar dan splash tidak terlihat (yang tampak hanya latar langit
    // halaman).
    return Stack(
      fit: StackFit.expand,
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

  static const _jarak = 16.0;
  static const _gayaTeks = TextStyle(
    fontFamily: AppTheme.hurufJudul,
    color: Colors.white,
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -.5,
    decoration: TextDecoration.none,
  );

  /// Lebar teks, diukur sekali per teks supaya susunan akhir (logo + teks)
  /// bisa diletakkan tetap dan hanya digeser dengan transform.
  static final _lebarTeks = <String, double>{};
  static double _ukur(String teks) => _lebarTeks.putIfAbsent(teks, () {
    final p = TextPainter(
      text: TextSpan(text: teks, style: _gayaTeks),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxLines: 1,
    )..layout();
    final w = p.width;
    p.dispose();
    return w;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final teks = Curves.easeOutCubic.transform(_antara(t, .10, .45));
    final gradasi = _antara(t, 0, .4);
    final pudar = 1 - Curves.easeIn.transform(_antara(t, .80, 1));
    final lebarTeks = _ukur(l.appName);

    return Opacity(
      opacity: pudar,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Awalnya datar seperti splash native; gradasi biru menyusul.
            // Gradasinya digambar sekali (RepaintBoundary), lalu hanya
            // dipudarkan.
            const ColoredBox(color: SplashGerbang.warnaAwal),
            Opacity(
              opacity: gradasi,
              child: const RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SplashGerbang.warnaAwal,
                        SplashGerbang.warnaAkhir,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),
            ),
            // Susunan akhir (logo di kiri, teks di kanan) diletakkan tetap di
            // tengah. Gerakannya murni transform dan opacity pada lapisan
            // yang sudah digambar, tanpa menyusun ulang tata letak tiap frame:
            // logo mulai dari tengah layar (sama dengan splash native) lalu
            // bergeser ke kiri, teks muncul dari sisinya.
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset((_jarak + lebarTeks) / 2 * (1 - teks), 0),
                    child: const RepaintBoundary(
                      child: TampilanLogo(lebar: SplashGerbang.lebarLogo),
                    ),
                  ),
                  const SizedBox(width: _jarak),
                  Opacity(
                    opacity: teks,
                    child: Transform.translate(
                      offset: Offset(-36 * (1 - teks), 0),
                      child: RepaintBoundary(
                        child: Text(
                          l.appName,
                          key: const ValueKey('splash.teks'),
                          maxLines: 1,
                          softWrap: false,
                          textScaler: TextScaler.noScaling,
                          style: _gayaTeks,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: RepaintBoundary(
                  child: Opacity(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
