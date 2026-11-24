import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../providers/pengaturan_provider.dart';

/// Pengaturan kaca untuk tombol bulat di AppBar, mengikuti terang/gelap tema.
/// Refraksi dibuat rendah (kaca tipis) supaya ikon tetap tajam.
LiquidGlassSettings _kacaTombol(BuildContext context) {
  final dasar = Theme.of(context).brightness == Brightness.dark
      ? LiquidGlassSettings.ios27Dark.copyWith(
          glassColor: const Color(0x29FFFFFF),
        )
      : LiquidGlassSettings.ios27Light;
  return dasar.copyWith(thickness: 16, refractiveIndex: 1.1);
}

/// Tanda bahwa widget berada di dalam [GrupTombolKaca]: kaca tombol memakai
/// lapisan bersama milik grup (supaya bisa melebur satu sama lain), bukan
/// lapisan sendiri.
class _DalamGrup extends InheritedWidget {
  const _DalamGrup({required super.child, this.ikonMasuk});

  /// 0..1 saat ikon-ikon grup baru saja berganti (pindah halaman dengan
  /// jumlah tombol sama); null bila tidak ada.
  final Animation<double>? ikonMasuk;

  static bool ada(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_DalamGrup>() != null;

  static Animation<double>? ikonMasukDari(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_DalamGrup>()?.ikonMasuk;

  @override
  bool updateShouldNotify(_DalamGrup lama) => false;
}

/// Tombol ikon bulat berbahan kaca cair (liquid glass) untuk baris atas
/// (AppBar): cari, lokasi, bagikan, riwayat, dan sejenisnya. Ditekan, tombol
/// mengembang seperti jeli (gaya iOS 26), lalu memantul-goyang saat dilepas.
/// Nama tombol tetap tersedia sebagai tooltip dan untuk pembaca layar.
class TombolKaca extends StatelessWidget {
  const TombolKaca({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.aktif = false,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;

  /// Keadaan "menyala" (mis. sudah difavoritkan): ikon memakai warna utama.
  final bool aktif;

  /// 44 = ukuran sentuh standar iOS.
  static const ukuran = 44.0;
  static const jarak = 2.0;

  /// Lebar satu tempat tombol di baris (tombol + jarak kiri-kanan).
  static const lebarSlot = ukuran + 2 * jarak;

  /// Batas tombol yang tampil di satu AppBar; sisanya masuk [TombolLainnya].
  static const maksPerBaris = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dalamGrup = _DalamGrup.ada(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: jarak),
      child: Tooltip(
        message: tooltip,
        child: _JeliTekan(
          nyala: onPressed != null,
          child: GlassIconButton(
            icon: _IkonBerganti(
              masuk: _DalamGrup.ikonMasukDari(context),
              child: icon,
            ),
            onPressed: onPressed,
            size: ukuran,
            iconSize: 24,
            // Efek tekan diambil alih _JeliTekan.
            interactionScale: 1,
            useOwnLayer: !dalamGrup,
            semanticLabel: tooltip,
            iconColor: aktif ? scheme.primary : scheme.onSurface,
            settings: dalamGrup ? null : _kacaTombol(context),
          ),
        ),
      ),
    );
  }
}

/// Ikon di dalam tombol kaca yang berganti dengan animasi, bukan diam-diam:
/// ikon lama mengecil sambil berputar sedikit dan memudar, ikon baru meletup
/// masuk (sedikit kebablasan lalu pas). Dipakai saat ikon satu tombol
/// berubah (mis. bintang favorit, putaran lokasi) dan saat seluruh ikon grup
/// berganti karena pindah halaman ([masuk] dari [GrupTombolKaca]).
/// Tanpa gerak bila "kurangi gerakan" aktif atau kaca cair dimatikan.
class _IkonBerganti extends StatelessWidget {
  const _IkonBerganti({required this.child, this.masuk});

  final Widget child;
  final Animation<double>? masuk;

  /// Identitas ikon untuk memicu pergantian.
  static Object _identitas(Widget w) => switch (w) {
    IkonDuo(:final icon) => icon,
    Icon(:final icon) => icon ?? w.runtimeType,
    _ => w.runtimeType,
  };

  bool _boleh(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return false;
    try {
      return Provider.of<PengaturanProvider>(context, listen: false).kacaCair;
    } on ProviderNotFoundException {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final boleh = _boleh(context);
    Widget hasil = AnimatedSwitcher(
      duration: boleh ? const Duration(milliseconds: 340) : Duration.zero,
      reverseDuration: boleh
          ? const Duration(milliseconds: 180)
          : Duration.zero,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (anak, animasi) => FadeTransition(
        opacity: animasi,
        child: ScaleTransition(
          scale: Tween<double>(begin: .35, end: 1).animate(animasi),
          child: RotationTransition(
            turns: Tween<double>(begin: -.08, end: 0).animate(animasi),
            child: anak,
          ),
        ),
      ),
      child: KeyedSubtree(key: ValueKey(_identitas(child)), child: child),
    );
    final m = masuk;
    if (m != null && boleh) {
      hasil = AnimatedBuilder(
        animation: m,
        builder: (context, anak) {
          final t = Curves.easeOutBack.transform(m.value);
          return Opacity(
            opacity: m.value.clamp(0.0, 1.0),
            child: Transform.scale(scale: .4 + .6 * t, child: anak),
          );
        },
        child: hasil,
      );
    }
    return hasil;
  }
}

/// Satu pilihan di menu [TombolLainnya].
class ItemLainnya {
  const ItemLainnya({
    required this.ikon,
    required this.label,
    required this.onTap,
  });

  final IconData ikon;
  final String label;
  final VoidCallback? onTap;
}

/// Tombol kaca "⋯ Lainnya": aksi yang jarang dipakai dikumpulkan di menu
/// supaya AppBar tidak penuh tombol kecil.
class TombolLainnya extends StatelessWidget {
  const TombolLainnya({super.key, required this.tooltip, required this.item});

  final String tooltip;
  final List<ItemLainnya> item;

  Future<void> _buka(BuildContext tombol) async {
    final kotak = tombol.findRenderObject()! as RenderBox;
    final layar =
        Navigator.of(tombol).overlay!.context.findRenderObject()! as RenderBox;
    final kiriAtas = kotak.localToGlobal(
      Offset(0, kotak.size.height),
      ancestor: layar,
    );
    final dipilih = await showMenu<int>(
      context: tombol,
      position: RelativeRect.fromRect(
        kiriAtas & kotak.size,
        Offset.zero & layar.size,
      ),
      items: [
        for (final (i, it) in item.indexed)
          PopupMenuItem<int>(
            value: i,
            enabled: it.onTap != null,
            child: Row(
              children: [
                IkonDuo(it.ikon, size: 22),
                const SizedBox(width: 12),
                Flexible(child: Text(it.label)),
              ],
            ),
          ),
      ],
    );
    if (dipilih != null) item[dipilih].onTap?.call();
  }

  @override
  Widget build(BuildContext context) => Builder(
    builder: (tombol) => TombolKaca(
      tooltip: tooltip,
      icon: const IkonDuo(IkonApp.lainnya),
      onPressed: () => _buka(tombol),
    ),
  );
}

/// Membungkus tombol supaya terasa seperti jeli: ditahan, tombol mengembang
/// (lebih lebar daripada tinggi); dilepas, tombol memantul dan bergoyang
/// teredam sebelum diam. Tidak ikut berebut gestur (memakai [Listener]).
/// Mati bila "kurangi gerakan" aktif atau efek kaca cair dimatikan.
class _JeliTekan extends StatefulWidget {
  const _JeliTekan({required this.child, required this.nyala});

  final Widget child;
  final bool nyala;

  @override
  State<_JeliTekan> createState() => _JeliTekanState();
}

class _JeliTekanState extends State<_JeliTekan> with TickerProviderStateMixin {
  late final AnimationController _tekan;
  late final AnimationController _goyang;
  double _kuatGoyang = 0;

  @override
  void initState() {
    super.initState();
    _tekan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170),
    );
    _goyang = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 1,
    );
  }

  @override
  void dispose() {
    _tekan.dispose();
    _goyang.dispose();
    super.dispose();
  }

  bool get _boleh {
    if (!widget.nyala || MediaQuery.of(context).disableAnimations) {
      return false;
    }
    try {
      return Provider.of<PengaturanProvider>(context, listen: false).kacaCair;
    } on ProviderNotFoundException {
      return true;
    }
  }

  void _turun() {
    if (!_boleh) return;
    _goyang.value = 1;
    _tekan.forward();
  }

  void _naik() {
    if (_tekan.value == 0 && !_tekan.isAnimating) return;
    _kuatGoyang = Curves.easeOut.transform(_tekan.value);
    _tekan.value = 0;
    _goyang.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _turun(),
      onPointerUp: (_) => _naik(),
      onPointerCancel: (_) => _naik(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_tekan, _goyang]),
        builder: (context, anak) {
          final tahan = Curves.easeOut.transform(_tekan.value);
          final t = _goyang.value;
          final redam = _goyang.isAnimating
              ? _kuatGoyang * math.exp(-4.5 * t)
              : 0.0;
          // Ditahan: mengembang 14% melebar, 9% meninggi. Dilepas: pantulan
          // teredam dengan fase sumbu tegak tertinggal, jadi bergoyang.
          final sx = 1 + .14 * tahan + .14 * redam * math.cos(16 * t);
          final sy = 1 + .09 * tahan + .11 * redam * math.cos(16 * t + 1.3);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(sx, sy, 1),
            child: anak,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Baris tombol kaca di AppBar yang "hidup" saat jumlah tombolnya berubah,
/// mis. pindah dari halaman bertombol dua ke halaman bertombol tiga:
///
/// * bertambah: tombol baru keluar membelah diri dari tombol terdekat
///   (tombol paling kiri yang sudah ada) lalu meluncur ke tempatnya;
/// * berkurang: tombol yang hilang meleleh masuk ke tombol terdekat.
///
/// Di Android (Impeller) kaca tombol yang berdekatan melebur seperti cairan
/// (lapisan kaca bersama dengan blend), jadi belahannya tampak memisah. Grup
/// mengingat jumlah tombol grup terakhir yang tampil, jadi animasi juga jalan
/// saat berpindah tab atau halaman. Mati bila "kurangi gerakan" aktif atau
/// efek kaca cair dimatikan di Pengaturan.
class GrupTombolKaca extends StatefulWidget {
  const GrupTombolKaca({super.key, required this.children});

  final List<Widget> children;

  /// Jumlah tombol grup terakhir yang tampil (untuk animasi antarhalaman).
  @visibleForTesting
  static int? jumlahTerakhir;

  @override
  State<GrupTombolKaca> createState() => _GrupTombolKacaState();
}

class _GrupTombolKacaState extends State<GrupTombolKaca>
    with TickerProviderStateMixin {
  late final AnimationController _kontrol;

  /// Ikon-ikon grup "meletup" masuk saat grup tampil di halaman baru dengan
  /// jumlah tombol yang sama (kaca tetap di tempat, ikonnya yang berganti).
  late final AnimationController _ikon;

  /// Jumlah tombol di awal animasi yang sedang berjalan.
  int _dari = 0;
  bool? _tampil;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: 1,
    );
    _dari = widget.children.length;
    _ikon = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
  }

  bool get _bolehGerak {
    if (MediaQuery.of(context).disableAnimations) return false;
    try {
      return Provider.of<PengaturanProvider>(context, listen: false).kacaCair;
    } on ProviderNotFoundException {
      return true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tab dan halaman yang tertutup dimatikan tickernya; menyala lagi berarti
    // grup ini baru saja tampil.
    final tampil = TickerMode.valuesOf(context).enabled;
    if (tampil && _tampil != true) _mulai(GrupTombolKaca.jumlahTerakhir);
    _tampil = tampil;
  }

  @override
  void didUpdateWidget(GrupTombolKaca lama) {
    super.didUpdateWidget(lama);
    if (lama.children.length != widget.children.length && _tampil == true) {
      _mulai(lama.children.length);
    }
  }

  void _mulai(int? dari) {
    final n = widget.children.length;
    GrupTombolKaca.jumlahTerakhir = n;
    if (dari == null || dari == n || !_bolehGerak) {
      _dari = n;
      _kontrol.value = 1;
      // Jumlah sama tapi halaman lain: ikonnya berganti dengan letupan.
      if (dari == n && _bolehGerak && n > 0) _ikon.forward(from: 0);
      return;
    }
    _dari = dari;
    _kontrol.forward(from: 0);
  }

  @override
  void dispose() {
    _ikon.dispose();
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anak = widget.children;
    final n = anak.length;
    final gelap = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveLiquidGlassLayer(
      settings: _kacaTombol(context),
      blendAmount: 16,
      clipBehavior: Clip.none,
      clipExpansion: const EdgeInsets.symmetric(
        horizontal: 4 * TombolKaca.lebarSlot,
      ),
      child: _DalamGrup(
        ikonMasuk: _ikon,
        child: AnimatedBuilder(
          animation: _kontrol,
          builder: (context, _) {
            final berjalan = _kontrol.value < 1;
            final gerak = _GerakJeli.hitung(
              t: _kontrol.value,
              n: n,
              dari: berjalan ? _dari : n,
            );
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Leher cairan di antara tombol yang sedang membelah/menyatu.
                if (berjalan)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _LeherJeli(gumpal: gerak.gumpal, gelap: gelap),
                      ),
                    ),
                  ),
                // Tombol yang hilang: ditarik masuk ke tombol paling kiri.
                for (final h in gerak.hantu)
                  Positioned(
                    left: h.x - TombolKaca.lebarSlot / 2,
                    top: 0,
                    bottom: 0,
                    width: TombolKaca.lebarSlot,
                    child: IgnorePointer(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(h.sx, h.sy, 1),
                        child: const Center(
                          child: LingkaranKaca(child: SizedBox.shrink()),
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < n; i++)
                      Transform.translate(
                        offset: Offset(gerak.geser[i], 0),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                            gerak.skalaX[i],
                            gerak.skalaY[i],
                            1,
                          ),
                          child: anak[i],
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Satu gumpal kaca (tombol) untuk digambar lehernya: pusat x di dalam grup
/// dan jari-jari saat ini.
class _Gumpal {
  const _Gumpal(this.x, this.r);
  final double x;
  final double r;
}

/// Tombol hantu (yang sedang ditarik masuk) beserta skalanya.
class _Hantu {
  const _Hantu(this.x, this.sx, this.sy);
  final double x;
  final double sx;
  final double sy;
}

/// Hitungan gerak jeli untuk satu titik waktu [t] (0..1).
///
/// Membelah (n > dari): tombol baru mulai menumpuk di tetangga terdekat,
/// ditarik keluar dengan pegas (sedikit kebablasan lalu kembali). Selama
/// masih tersambung, kedua tombol melar searah tarikan dan memipih; begitu
/// leher putus keduanya bergoyang seperti jeli lalu diam. Menyatu (n < dari)
/// kebalikannya: tombol hantu ditarik masuk, leher terbentuk lalu tertelan.
class _GerakJeli {
  _GerakJeli._(this.geser, this.skalaX, this.skalaY, this.hantu, this.gumpal);

  final List<double> geser;
  final List<double> skalaX;
  final List<double> skalaY;
  final List<_Hantu> hantu;
  final List<_Gumpal> gumpal;

  static const _r = TombolKaca.ukuran / 2;
  static const _s = TombolKaca.lebarSlot;

  /// Pegas teredam: 0 di awal, kebablasan sedikit, lalu diam di 1.
  static double _pegas(double t) => 1 - math.exp(-6.5 * t) * math.cos(8.5 * t);

  /// Goyangan jeli setelah leher putus (teredam).
  static double _goyang(double t) => math.exp(-5 * t) * math.sin(22 * t);

  factory _GerakJeli.hitung({
    required double t,
    required int n,
    required int dari,
  }) {
    final geser = List<double>.filled(n, 0);
    final sx = List<double>.filled(n, 1);
    final sy = List<double>.filled(n, 1);
    final hantu = <_Hantu>[];
    final gumpal = <_Gumpal>[];
    double pusat(int i) => _s * i + _s / 2;

    if (n > dari) {
      // ---- Membelah: tombol 0..baru-1 baru, tetangga = tombol ke-`baru`.
      final baru = n - dari;
      final p = _pegas(t);
      for (var i = 0; i < baru; i++) {
        geser[i] = (baru - i) * _s * (1 - p);
      }
      // Melar selama tersambung, goyang setelah putus.
      for (var i = 0; i <= math.min(baru, n - 1); i++) {
        final kanan = i < n - 1 ? pusat(i + 1) + geser[i + 1] : null;
        final jarakTetangga = kanan == null
            ? 2 * _r
            : (kanan - (pusat(i) + geser[i])).abs();
        final tegang = ((jarakTetangga - 0.4 * _r) / (2.2 * _r)).clamp(
          0.0,
          1.0,
        );
        final putus = jarakTetangga > 2.9 * _r;
        final melar = putus
            ? .12 * _goyang(t)
            : .22 * math.sin(math.pi * tegang);
        sx[i] = 1 + melar;
        sy[i] = 1 - melar * .6;
      }
      // Tombol baru tumbuh dari kecil saat keluar.
      for (var i = 0; i < baru; i++) {
        final tumbuh = .72 + .28 * Curves.easeOut.transform(t.clamp(0.0, 1.0));
        sx[i] *= tumbuh;
        sy[i] *= tumbuh;
      }
    } else if (n < dari) {
      // ---- Menyatu: hantu ditarik masuk ke tombol 0.
      final hilang = dari - n;
      final p = _pegas(t);
      for (var g = 0; g < hilang; g++) {
        final x = pusat(0) - (hilang - g) * _s * (1 - p);
        final sisa = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
        final jarak = (pusat(0) - x).abs();
        final melar = jarak > 2.9 * _r
            ? 0.0
            : .2 * math.sin(math.pi * (jarak / (2.9 * _r)).clamp(0.0, 1.0));
        final skala = .45 + .55 * sisa;
        hantu.add(_Hantu(x, skala * (1 + melar), skala * (1 - melar * .6)));
        gumpal.add(_Gumpal(x, _r * skala));
      }
      if (n > 0) {
        final telan = .1 * _goyang((t - .45).clamp(0.0, 1.0));
        sx[0] = 1 + telan;
        sy[0] = 1 - telan * .6;
      }
    }

    for (var i = 0; i < n; i++) {
      gumpal.add(_Gumpal(pusat(i) + geser[i], _r * math.min(sx[i], sy[i])));
    }
    gumpal.sort((a, b) => a.x.compareTo(b.x));
    return _GerakJeli._(geser, sx, sy, hantu, gumpal);
  }
}

/// Melukis "leher" cairan di antara gumpal kaca yang berdekatan (metaball):
/// makin jauh, makin tipis, lalu putus. Warnanya kaca tipis bertepi terang
/// supaya menyatu dengan tombol kaca di atasnya. Digambar sendiri sehingga
/// terlihat di semua platform, tidak hanya di Impeller.
class _LeherJeli extends CustomPainter {
  _LeherJeli({required this.gumpal, required this.gelap});

  final List<_Gumpal> gumpal;
  final bool gelap;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final isi = Paint()
      ..color = gelap ? const Color(0x47FFFFFF) : const Color(0x8CFFFFFF);
    final tepi = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gelap ? const Color(0x59FFFFFF) : const Color(0xB3FFFFFF);
    for (var i = 0; i < gumpal.length - 1; i++) {
      final a = gumpal[i];
      final b = gumpal[i + 1];
      final leher = _metaball(
        Offset(a.x, cy),
        a.r,
        Offset(b.x, cy),
        b.r,
        maks: (a.r + b.r) * 1.45,
      );
      if (leher == null) continue;
      canvas.drawPath(leher, isi);
      canvas.drawPath(leher, tepi);
    }
  }

  /// Jembatan metaball dua lingkaran (algoritme klasik "gooey"): titik singgung
  /// di kedua lingkaran disambung kurva Bezier yang menyempit seiring jarak.
  static Path? _metaball(
    Offset c1,
    double r1,
    Offset c2,
    double r2, {
    required double maks,
    double v = .5,
    double gagang = 2.4,
  }) {
    final d = (c2 - c1).distance;
    if (d > maks || d <= (r1 - r2).abs() || d < 1) return null;
    var u1 = 0.0;
    var u2 = 0.0;
    if (d < r1 + r2) {
      u1 = math.acos(((r1 * r1 + d * d - r2 * r2) / (2 * r1 * d)).clamp(-1, 1));
      u2 = math.acos(((r2 * r2 + d * d - r1 * r1) / (2 * r2 * d)).clamp(-1, 1));
    }
    final sudut = math.atan2(c2.dy - c1.dy, c2.dx - c1.dx);
    final buka = math.acos(((r1 - r2) / d).clamp(-1, 1));
    final a1a = sudut + u1 + (buka - u1) * v;
    final a1b = sudut - u1 - (buka - u1) * v;
    final a2a = sudut + math.pi - u2 - (math.pi - u2 - buka) * v;
    final a2b = sudut - math.pi + u2 + (math.pi - u2 - buka) * v;
    Offset kutub(double a, double r) =>
        Offset(math.cos(a) * r, math.sin(a) * r);
    final p1a = c1 + kutub(a1a, r1);
    final p1b = c1 + kutub(a1b, r1);
    final p2a = c2 + kutub(a2a, r2);
    final p2b = c2 + kutub(a2b, r2);
    final total = r1 + r2;
    final d2 =
        math.min(v * gagang, (p1a - p2a).distance / total) *
        math.min(1.0, d * 2 / total);
    final h1 = r1 * d2;
    final h2 = r2 * d2;
    final g1a = p1a + kutub(a1a - math.pi / 2, h1);
    final g2a = p2a + kutub(a2a + math.pi / 2, h2);
    final g2b = p2b + kutub(a2b - math.pi / 2, h2);
    final g1b = p1b + kutub(a1b + math.pi / 2, h1);
    return Path()
      ..moveTo(p1a.dx, p1a.dy)
      ..cubicTo(g1a.dx, g1a.dy, g2a.dx, g2a.dy, p2a.dx, p2a.dy)
      ..lineTo(p2b.dx, p2b.dy)
      ..cubicTo(g2b.dx, g2b.dy, g1b.dx, g1b.dy, p1b.dx, p1b.dy)
      ..close();
  }

  @override
  bool shouldRepaint(_LeherJeli lama) => true;
}

/// Lingkaran kaca dekoratif (tanpa aksi) untuk ikon tombol kembali/tutup
/// bawaan AppBar, dipasang lewat `ActionIconThemeData` di tema, jadi semua
/// layar ikut tanpa mengubah tiap AppBar. Ketukan tetap ditangani tombol
/// bawaan Flutter.
class LingkaranKaca extends StatelessWidget {
  const LingkaranKaca({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dalamGrup = _DalamGrup.ada(context);
    return GlassContainer(
      useOwnLayer: !dalamGrup,
      width: TombolKaca.ukuran,
      height: TombolKaca.ukuran,
      shape: const LiquidOval(),
      settings: dalamGrup ? null : _kacaTombol(context),
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(
            size: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          child: child,
        ),
      ),
    );
  }
}
