import 'package:flutter/material.dart';

import '../core/strings.dart';

/// Kotak magnitudo dengan warna sesuai tingkat:
/// < 4 hijau, 4–4.9 kuning, 5–5.9 oranye, ≥ 6 merah.
class BadgeMagnitudo extends StatelessWidget {
  const BadgeMagnitudo({
    super.key,
    required this.magnitudo,
    this.teks,
    this.besar = false,
  });

  final double? magnitudo;

  /// Teks asli dari BMKG (mis. "4.1"); dipakai bila ada.
  final String? teks;
  final bool besar;

  static (Color, Color) warna(double? m) {
    if (m == null) return (const Color(0xFF9E9E9E), Colors.white);
    if (m >= 6) return (const Color(0xFFC62828), Colors.white);
    if (m >= 5) return (const Color(0xFFEF6C00), Colors.white);
    if (m >= 4) return (const Color(0xFFF9A825), Colors.black);
    return (const Color(0xFF2E7D32), Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final (latar, depan) = warna(magnitudo);
    final theme = Theme.of(context);
    final label = (teks?.isNotEmpty ?? false)
        ? teks!
        : magnitudo?.toStringAsFixed(1) ?? Str.tandaKosong;

    return Container(
      width: besar ? 84 : 56,
      padding: EdgeInsets.symmetric(vertical: besar ? 12 : 8),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(besar ? 16 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style:
                (besar
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.titleLarge)
                    ?.copyWith(color: depan, fontWeight: FontWeight.w700),
          ),
          Text(
            besar ? Str.magnitudo : 'M',
            style: theme.textTheme.labelSmall?.copyWith(color: depan),
          ),
        ],
      ),
    );
  }
}
