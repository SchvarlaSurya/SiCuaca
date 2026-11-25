import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Latar langit "Langit Kaca" untuk satu halaman penuh: gradasi biru dari
/// atas ke bawah (siang di tema terang, langit malam di tema gelap) dengan
/// dua gumpalan awan lembut. Digambar di belakang [child] sampai ke tepi atas
/// layar, jadi top bar bisa transparan tanpa garis sambungan. Hanya hiasan:
/// tidak menangkap ketukan.
class LangitLatar extends StatelessWidget {
  const LangitLatar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [
            AppTheme.langitAtasGelap,
            AppTheme.langitTengahGelap,
            AppTheme.langitBawahGelap,
          ]
        : const [
            AppTheme.langitAtasTerang,
            AppTheme.langitTengahTerang,
            AppTheme.langitBawahTerang,
          ];
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                stops: const [0, .45, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          right: -70,
          top: 40,
          child: IgnorePointer(child: _Awan(lebar: 220, dark: dark)),
        ),
        Positioned(
          left: -90,
          top: 300,
          child: IgnorePointer(child: _Awan(lebar: 200, dark: dark)),
        ),
        child,
      ],
    );
  }
}

class _Awan extends StatelessWidget {
  const _Awan({required this.lebar, required this.dark});

  final double lebar;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    width: lebar,
    height: lebar * .55,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(lebar),
      gradient: RadialGradient(
        colors: [
          Colors.white.withValues(alpha: dark ? .06 : .55),
          Colors.white.withValues(alpha: 0),
        ],
      ),
    ),
  );
}
