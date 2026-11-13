import 'package:flutter/material.dart';

/// Memetakan `weather_desc` BMKG ke ikon Material. Gambar dari URL BMKG
/// sengaja tidak dipakai.
///
/// Dicocokkan dengan kata kunci (bukan kode angka) karena kode cuaca BMKG
/// tidak selalu konsisten dengan dokumentasinya.
IconData ikonCuaca(String deskripsi, {bool malam = false}) {
  final d = deskripsi.toLowerCase();
  if (d.contains('petir')) return Icons.thunderstorm;
  if (d.contains('hujan')) return Icons.water_drop;
  if (d.contains('kabut') || d.contains('asap') || d.contains('kabur')) {
    return Icons.foggy;
  }
  if (d.contains('cerah berawan')) {
    return malam ? Icons.nights_stay : Icons.cloud_queue;
  }
  if (d.contains('berawan')) return Icons.cloud;
  if (d.contains('cerah')) return malam ? Icons.bedtime : Icons.wb_sunny;
  return Icons.cloud_outlined;
}

class IkonCuaca extends StatelessWidget {
  const IkonCuaca({
    super.key,
    required this.deskripsi,
    this.malam = false,
    this.size = 24,
  });

  final String deskripsi;
  final bool malam;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      ikonCuaca(deskripsi, malam: malam),
      size: size,
      color: Theme.of(context).colorScheme.primary,
      semanticLabel: deskripsi,
    );
  }
}
