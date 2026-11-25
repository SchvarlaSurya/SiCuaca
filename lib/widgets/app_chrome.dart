import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Small motion primitives shared by the redesigned screens.  Motion is kept
/// deliberately short, and honours the operating system's reduced-motion
/// preference.
class MasukLembut extends StatefulWidget {
  const MasukLembut({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<MasukLembut> createState() => _MasukLembutState();
}

class _MasukLembutState extends State<MasukLembut>
    with SingleTickerProviderStateMixin {
  static const _durasi = Duration(milliseconds: 420);

  // Dibuat di initState (bukan lazy): kalau pengguna memilih "kurangi gerakan"
  // controller tidak pernah dipakai, dan membuatnya baru saat dispose()
  // melanggar aturan ticker.
  late final AnimationController _controller;
  late final Animation<double> _kurva;

  @override
  void initState() {
    super.initState();
    // Jeda awal ikut dalam durasi controller (lewat Interval), jadi tidak ada
    // Timer terpisah yang bisa tertinggal setelah widget dilepas.
    final total = _durasi + widget.delay;
    _controller = AnimationController(vsync: this, duration: total);
    _kurva = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _kurva,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .035),
          end: Offset.zero,
        ).animate(_kurva),
        child: widget.child,
      ),
    );
  }
}

/// A quiet hover/press treatment that also works as a normal mobile InkWell.
class TekanLembut extends StatefulWidget {
  const TekanLembut({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  State<TekanLembut> createState() => _TekanLembutState();
}

/// Latar langit "Langit Kaca": gradasi biru dari atas ke bawah (siang di
/// tema terang, langit malam di tema gelap) dengan dua gumpalan awan lembut.
/// Hanya hiasan: tidak menangkap ketukan. Ujung atasnya sama dengan warna
/// AppBar sehingga menyambung. [gelap] dipertahankan untuk kompatibilitas
/// pemanggil lama; tema yang menentukan.
class LatarAtmosfer extends StatelessWidget {
  const LatarAtmosfer({super.key, required this.child, this.gelap = true});

  final Widget child;
  final bool gelap;

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

class _TekanLembutState extends State<TekanLembut> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final scale = _down ? .985 : (_hover && !disabled ? 1.008 : 1.0);
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: MediaQuery.of(context).disableAnimations ? 1 : scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _down = value),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
