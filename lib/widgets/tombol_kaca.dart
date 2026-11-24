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

/// Pembawa animasi "ikon masuk" dari [GrupTombolKaca] ke tombol di dalamnya.
class _DalamGrup extends InheritedWidget {
  const _DalamGrup({required super.child, this.ikonMasuk});

  /// 0..1 saat ikon-ikon grup baru saja berganti (pindah halaman dengan
  /// jumlah tombol sama); null bila tidak ada.
  final Animation<double>? ikonMasuk;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: jarak),
      child: Tooltip(
        message: tooltip,
        child: _JeliTekan(
          nyala: onPressed != null,
          child: SizedBox.square(
            dimension: ukuran,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GlassIconButton(
                  // Ikon digambar DI ATAS kaca (lapisan terpisah di bawah),
                  // bukan di dalamnya: lapisan kaca bisa menyimpan tampilan
                  // isinya, sehingga ikon yang sedang beranimasi kadang
                  // tersimpan saat masih transparan dan tidak muncul.
                  icon: const SizedBox.shrink(),
                  onPressed: onPressed,
                  size: ukuran,
                  // Efek tekan diambil alih _JeliTekan.
                  interactionScale: 1,
                  useOwnLayer: true,
                  semanticLabel: tooltip,
                  settings: _kacaTombol(context),
                ),
                IgnorePointer(
                  child: ExcludeSemantics(
                    child: IconTheme.merge(
                      data: IconThemeData(
                        size: 24,
                        color: onPressed == null
                            ? scheme.onSurface.withValues(alpha: .38)
                            : aktif
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                      child: _IkonBerganti(
                        masuk: _DalamGrup.ikonMasukDari(context),
                        child: icon,
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
      duration: const Duration(milliseconds: 220),
    );
    _goyang = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    // Ketuk cepat pun tetap memantul penuh, bukan hanya sedikit.
    _kuatGoyang = math.max(.85, Curves.easeOut.transform(_tekan.value));
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
          final tahan = Curves.easeOutBack.transform(_tekan.value);
          final t = _goyang.value;
          final redam = _goyang.isAnimating
              ? _kuatGoyang * math.exp(-3.6 * t)
              : 0.0;
          // Ditahan: gelembung kaca mengembang (22% melebar, 15% meninggi),
          // seperti tombol kaca iOS 26. Dilepas: memantul lalu bergoyang
          // teredam; sumbu tegak tertinggal fasenya, jadi terasa kenyal.
          final sx = 1 + .22 * tahan + .2 * redam * math.cos(11 * t * math.pi);
          final sy =
              1 + .15 * tahan + .16 * redam * math.cos(11 * t * math.pi + 1.4);
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

/// Baris tombol kaca di AppBar. Tiap tombol memakai lapisan kaca sendiri,
/// jadi seluruh gelembung kaca (bukan hanya ikonnya) ikut mengembang saat
/// ditekan. Saat grup tampil di halaman lain, ikon-ikonnya meletup masuk
/// (kaca tetap di tempat), dan ikon yang berubah di satu tombol berganti
/// dengan animasi. Mati bila "kurangi gerakan" aktif atau efek kaca cair
/// dimatikan di Pengaturan.
class GrupTombolKaca extends StatefulWidget {
  const GrupTombolKaca({super.key, required this.children});

  final List<Widget> children;

  /// Sudah ada grup yang tampil sebelumnya (untuk animasi antarhalaman).
  @visibleForTesting
  static bool sudahAdaSebelumnya = false;

  @override
  State<GrupTombolKaca> createState() => _GrupTombolKacaState();
}

class _GrupTombolKacaState extends State<GrupTombolKaca>
    with SingleTickerProviderStateMixin {
  /// Ikon-ikon grup "meletup" masuk saat grup tampil di halaman baru.
  late final AnimationController _ikon;
  bool? _tampil;

  @override
  void initState() {
    super.initState();
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
    if (tampil && _tampil != true) {
      if (GrupTombolKaca.sudahAdaSebelumnya &&
          _bolehGerak &&
          widget.children.isNotEmpty) {
        _ikon.forward(from: 0);
      }
      GrupTombolKaca.sudahAdaSebelumnya = true;
    }
    _tampil = tampil;
  }

  @override
  void dispose() {
    _ikon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DalamGrup(
    ikonMasuk: _ikon,
    child: Row(mainAxisSize: MainAxisSize.min, children: widget.children),
  );
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
    return GlassContainer(
      useOwnLayer: true,
      width: TombolKaca.ukuran,
      height: TombolKaca.ukuran,
      shape: const LiquidOval(),
      settings: _kacaTombol(context),
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
