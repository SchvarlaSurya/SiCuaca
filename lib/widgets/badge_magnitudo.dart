import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/l10n.dart';
import '../core/warna_semantik.dart';

String _angka(double? magnitudo, String? teks) => (teks?.isNotEmpty ?? false)
    ? teks!
    : magnitudo?.toStringAsFixed(1) ?? Format.tandaKosong;

/// Kotak magnitudo untuk daftar: angka + label tingkat (Kecil, Ringan,
/// Sedang, Kuat, Besar). Warna hanya penguat, label teks selalu ada.
class BadgeMagnitudo extends StatelessWidget {
  const BadgeMagnitudo({super.key, required this.magnitudo, this.teks});

  final double? magnitudo;

  /// Teks asli dari BMKG (mis. "4.1"); dipakai bila ada.
  final String? teks;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tingkat = TingkatMagnitudo.dari(magnitudo);
    final angka = _angka(magnitudo, teks);
    return Semantics(
      label: l.magnitudoSemantik(angka, tingkat.label(l)),
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minWidth: 92),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: tingkat.latar,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: tingkat.depan.withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                angka,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: tingkat.depan,
                ),
              ),
              Text(
                tingkat.label(l).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tingkat.depan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label tingkat berbentuk pil, untuk ditaruh di samping angka besar.
class LabelTingkat extends StatelessWidget {
  const LabelTingkat({super.key, required this.magnitudo});

  final double? magnitudo;

  @override
  Widget build(BuildContext context) {
    final tingkat = TingkatMagnitudo.dari(magnitudo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tingkat.latar,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        tingkat.label(context.l10n).toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: tingkat.depan),
      ),
    );
  }
}

/// Magnitudo sebagai informasi utama layar: angka 64 sp + "M" + label
/// tingkat.
class MagnitudoBesar extends StatelessWidget {
  const MagnitudoBesar({
    super.key,
    required this.magnitudo,
    this.teks,
    this.warna,
  });

  final double? magnitudo;
  final String? teks;

  /// Warna angka dan kata "Magnitudo" bila diletakkan di atas latar gelap
  /// (mis. kartu ungu di detail gempa). Bawaan: warna teks tema.
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final angka = _angka(magnitudo, teks);
    final tingkat = TingkatMagnitudo.dari(magnitudo);
    return Semantics(
      label: l.magnitudoSemantik(angka, tingkat.label(l)),
      child: ExcludeSemantics(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              angka,
              style: theme.textTheme.displayLarge?.copyWith(
                letterSpacing: -3,
                color: warna,
              ),
            ),
            Text(
              l.magnitudo,
              style: theme.textTheme.labelMedium?.copyWith(color: warna),
            ),
            LabelTingkat(magnitudo: magnitudo),
          ],
        ),
      ),
    );
  }
}
