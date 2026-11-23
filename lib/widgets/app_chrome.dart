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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .035),
          end: Offset.zero,
        ).animate(curve),
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

/// Atmospheric layer for the earthquake experience. It is decorative only,
/// so it never captures gestures or compromises the data surface above it.
class LatarAtmosfer extends StatelessWidget {
  const LatarAtmosfer({super.key, required this.child, this.gelap = true});

  final Widget child;
  final bool gelap;

  @override
  Widget build(BuildContext context) {
    // Theme mode always takes precedence, so no screen can get stuck in the
    // wrong palette when the user switches light/dark mode.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [Color(0xFF17104A), Color(0xFF34218B), Color(0xFF6756D8)]
        : const [Color(0xFFF8F7FF), Color(0xFFECE8FF), Color(0xFFDCD5FF)];
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          right: -80,
          top: 30,
          child: IgnorePointer(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: dark ? .08 : .34),
              ),
            ),
          ),
        ),
        Positioned(
          left: -90,
          top: 230,
          child: IgnorePointer(
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: dark ? .05 : .22),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
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
