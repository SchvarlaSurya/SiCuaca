import 'package:flutter/material.dart';

/// Efek tekan untuk tombol atau kartu apa pun: mengecil sedikit selama jari
/// menekan. Memakai [Listener], jadi tidak ikut berebut gestur dan tidak
/// mengubah perilaku ketuk milik [child]. Mati saat "kurangi gerakan".
class PencetLembut extends StatefulWidget {
  const PencetLembut({super.key, required this.child, this.skala = .96});

  final Widget child;
  final double skala;

  @override
  State<PencetLembut> createState() => _PencetLembutState();
}

class _PencetLembutState extends State<PencetLembut> {
  bool _turun = false;

  void _setel(bool nilai) {
    if (_turun != nilai) setState(() => _turun = nilai);
  }

  @override
  Widget build(BuildContext context) {
    final diam = MediaQuery.of(context).disableAnimations;
    return Listener(
      onPointerDown: (_) => _setel(true),
      onPointerUp: (_) => _setel(false),
      onPointerCancel: (_) => _setel(false),
      child: AnimatedScale(
        scale: diam || !_turun ? 1 : widget.skala,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
