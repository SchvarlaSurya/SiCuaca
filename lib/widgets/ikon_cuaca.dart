import 'package:flutter/material.dart';

import '../core/ikon.dart';
import '../core/warna_semantik.dart';

/// Memetakan `weather_desc` BMKG ke ikon. Gambar dari URL BMKG sengaja
/// tidak dipakai.
///
/// Dicocokkan dengan kata kunci (bukan kode angka) karena kode cuaca BMKG
/// tidak selalu konsisten dengan dokumentasinya.
IconData ikonCuaca(String deskripsi, {bool malam = false}) {
  final d = deskripsi.toLowerCase();
  if (d.contains('petir')) return IkonApp.petir;
  if (d.contains('hujan')) return IkonApp.hujan;
  if (d.contains('kabut') || d.contains('asap') || d.contains('kabur')) {
    return IkonApp.kabut;
  }
  if (d.contains('cerah berawan')) {
    return malam ? IkonApp.cerahBerawanMalam : IkonApp.cerahBerawan;
  }
  if (d.contains('berawan')) return IkonApp.berawan;
  if (d.contains('cerah')) return malam ? IkonApp.cerahMalam : IkonApp.cerah;
  return IkonApp.berawan;
}

class IkonCuaca extends StatelessWidget {
  const IkonCuaca({
    super.key,
    required this.deskripsi,
    this.malam = false,
    this.size = 24,
    this.warna,
  });

  final String deskripsi;
  final bool malam;
  final double size;

  /// Bawaan: warna primer tema.
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    return IkonDuo(
      ikonCuaca(deskripsi, malam: malam),
      size: size,
      color: warna ?? Theme.of(context).colorScheme.primary,
      duotoneSecondaryColor: aksenKondisi(
        KondisiLangit.dari(deskripsi),
        malam: malam,
      ),
      duotoneSecondaryOpacity: 0.55,
      semanticLabel: deskripsi,
    );
  }
}
