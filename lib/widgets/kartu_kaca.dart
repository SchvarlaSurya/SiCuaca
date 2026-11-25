import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/theme.dart';

/// Kartu kaca cair untuk blok utama Beranda/Cuaca (gaya "Langit Kaca").
///
/// Kacanya digambar sebagai lapisan latar terpisah di BAWAH isi, bukan
/// membungkus isi: lapisan kaca bisa menyimpan tampilan isinya, sehingga isi
/// yang beranimasi bisa tersimpan setengah jadi. Isi di atasnya digambar
/// biasa. Bila efek kaca cair dimatikan, kaca otomatis jadi kaca sederhana
/// (GlassTheme minimal di main.dart).
class KartuKaca extends StatelessWidget {
  const KartuKaca({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final kaca =
        (b == Brightness.dark
                ? LiquidGlassSettings.ios27Dark
                : LiquidGlassSettings.ios27Light)
            .copyWith(
              glassColor: AppTheme.kacaIsi(b),
              thickness: 14,
              refractiveIndex: 1.08,
            );
    return Stack(
      children: [
        Positioned.fill(
          child: GlassContainer(
            useOwnLayer: true,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: AppTheme.radiusKartu,
            ),
            settings: kaca,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
                border: Border.all(color: AppTheme.kacaTepi(b)),
              ),
            ),
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}
