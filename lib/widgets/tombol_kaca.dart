import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

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
  const _DalamGrup({required super.child});

  static bool ada(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_DalamGrup>() != null;

  @override
  bool updateShouldNotify(_DalamGrup lama) => false;
}

/// Tombol ikon bulat berbahan kaca cair (liquid glass) untuk baris atas
/// (AppBar): cari, lokasi, bagikan, riwayat, dan sejenisnya. Ditekan, tombol
/// memipih seperti jeli. Nama tombol tetap tersedia sebagai tooltip dan untuk
/// pembaca layar.
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

  static const ukuran = 40.0;
  static const jarak = 3.0;

  /// Lebar satu tempat tombol di baris (tombol + jarak kiri-kanan).
  static const lebarSlot = ukuran + 2 * jarak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dalamGrup = _DalamGrup.ada(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: jarak),
      child: Tooltip(
        message: tooltip,
        child: GlassIconButton(
          icon: icon,
          onPressed: onPressed,
          size: ukuran,
          iconSize: 22,
          useOwnLayer: !dalamGrup,
          semanticLabel: tooltip,
          iconColor: aktif ? scheme.primary : scheme.onSurface,
          settings: dalamGrup ? null : _kacaTombol(context),
        ),
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol;

  /// Jumlah tombol di awal animasi yang sedang berjalan.
  int _dari = 0;
  bool? _tampil;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
      value: 1,
    );
    _dari = widget.children.length;
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
      return;
    }
    _dari = dari;
    _kontrol.forward(from: 0);
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const s = TombolKaca.lebarSlot;
    final anak = widget.children;
    final n = anak.length;

    return AdaptiveLiquidGlassLayer(
      settings: _kacaTombol(context),
      blendAmount: 16,
      clipBehavior: Clip.none,
      clipExpansion: const EdgeInsets.symmetric(horizontal: 4 * s),
      child: _DalamGrup(
        child: AnimatedBuilder(
          animation: _kontrol,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_kontrol.value);
            final berjalan = _kontrol.value < 1;
            final baru = berjalan ? math.max(0, n - _dari) : 0;
            final hilang = berjalan ? math.max(0, _dari - n) : 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Tombol yang hilang: meleleh masuk ke tombol paling kiri.
                for (var g = 0; g < hilang; g++)
                  Positioned(
                    left: -(hilang - g) * s * (1 - t),
                    top: 0,
                    bottom: 0,
                    width: s,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 1 - t,
                        child: Transform.scale(
                          scale: 1 - .45 * t,
                          child: const Center(
                            child: LingkaranKaca(child: SizedBox.shrink()),
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < n; i++)
                      if (i < baru)
                        // Tombol baru: mulai menumpuk di tombol terdekat yang
                        // sudah ada, lalu membelah dan meluncur ke tempatnya.
                        Transform.translate(
                          offset: Offset((baru - i) * s * (1 - t), 0),
                          child: Transform.scale(
                            scale: .7 + .3 * t,
                            child: anak[i],
                          ),
                        )
                      else
                        anak[i],
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
