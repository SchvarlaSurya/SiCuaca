import 'package:flutter/material.dart';

import '../core/format.dart';

/// Suhu yang "menghitung naik" sebentar saat pertama tampil (beberapa derajat
/// di bawah nilai akhirnya), lalu menyesuaikan halus bila nilainya berubah.
/// Hanya angka yang bergerak; nilai akhir selalu sama dengan [Format.suhu].
/// Tanpa gerak (pengaturan "kurangi gerakan") langsung menampilkan nilai
/// akhir, begitu juga bila suhu kosong.
class SuhuBerhitung extends StatelessWidget {
  const SuhuBerhitung({super.key, required this.nilai, this.style});

  final double? nilai;
  final TextStyle? style;

  /// Jarak awal hitungan dari nilai akhir.
  static const _selisihAwal = 8.0;

  @override
  Widget build(BuildContext context) {
    final akhir = nilai;
    if (akhir == null || MediaQuery.of(context).disableAnimations) {
      return Text(Format.suhu(akhir), style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: akhir - _selisihAwal, end: akhir),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Semantics(
        // Pembaca layar langsung membaca nilai akhir, bukan angka di tengah.
        label: Format.suhu(akhir),
        excludeSemantics: true,
        child: Text(Format.suhu(v), style: style),
      ),
    );
  }
}
