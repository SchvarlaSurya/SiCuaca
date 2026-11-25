import 'package:flutter/material.dart';

import '../core/format.dart';

/// Suhu yang "menghitung naik" sebentar saat pertama tampil (beberapa derajat
/// di bawah nilai akhirnya), lalu menyesuaikan halus bila nilainya berubah.
/// Hanya angka yang bergerak; nilai akhir selalu sama dengan [Format.suhu].
/// Tanpa gerak (pengaturan "kurangi gerakan") langsung menampilkan nilai
/// akhir, begitu juga bila suhu kosong.
class SuhuBerhitung extends StatelessWidget {
  const SuhuBerhitung({
    super.key,
    required this.nilai,
    this.style,
    this.pendek = false,
  });

  final double? nilai;
  final TextStyle? style;

  /// Tanpa satuan ("27°" bukan "27°C"), untuk angka besar di hero.
  final bool pendek;

  /// Jarak awal hitungan dari nilai akhir.
  static const _selisihAwal = 8.0;

  @override
  Widget build(BuildContext context) {
    final akhir = nilai;
    String teks(double? v) =>
        pendek && v != null ? '${v.round()}°' : Format.suhu(v);
    if (akhir == null || MediaQuery.of(context).disableAnimations) {
      return Text(teks(akhir), style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: akhir - _selisihAwal, end: akhir),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Semantics(
        // Pembaca layar langsung membaca nilai akhir lengkap (dengan satuan).
        label: Format.suhu(akhir),
        excludeSemantics: true,
        child: Text(teks(v), style: style),
      ),
    );
  }
}
