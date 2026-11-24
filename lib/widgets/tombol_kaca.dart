import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: tooltip,
        child: GlassIconButton(
          icon: icon,
          onPressed: onPressed,
          size: ukuran,
          iconSize: 22,
          useOwnLayer: true,
          semanticLabel: tooltip,
          iconColor: aktif ? scheme.primary : scheme.onSurface,
          settings: _kacaTombol(context),
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
  Widget build(BuildContext context) => GlassContainer(
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
