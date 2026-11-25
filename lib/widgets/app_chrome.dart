import 'package:flutter/material.dart';

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

/// Dulu menggambar latar langit per layar. Sekarang langit digambar sekali
/// di belakang SELURUH halaman (termasuk di belakang top bar) oleh
/// [LangitLatar], lewat transisi halaman di tema, jadi widget ini hanya
/// meneruskan [child]. Dipertahankan agar pemanggil lama tidak berubah.
class LatarAtmosfer extends StatelessWidget {
  const LatarAtmosfer({super.key, required this.child, this.gelap = true});

  final Widget child;
  final bool gelap;

  @override
  Widget build(BuildContext context) => child;
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
