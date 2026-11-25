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

/// Ikon kondisi cuaca.
///
/// Tanpa [warna]: ikon berwarna bertumpuk gaya "Langit Kaca" (matahari
/// kuning, awan putih berbayang, hujan biru). Dengan [warna]: ikon duotone
/// satu warna (mis. di navbar, agar seragam dengan ikon lain). Kondisi
/// selalu juga ditulis sebagai teks di layar; ikon hanya penguat.
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

  /// Null = berwarna; diisi = duotone satu warna.
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final w = warna;
    if (w != null) {
      return IkonDuo(
        ikonCuaca(deskripsi, malam: malam),
        size: size,
        color: w,
        duotoneSecondaryColor: aksenKondisi(
          KondisiLangit.dari(deskripsi),
          malam: malam,
        ),
        duotoneSecondaryOpacity: 0.55,
        semanticLabel: deskripsi,
      );
    }
    return Semantics(
      label: deskripsi,
      child: ExcludeSemantics(
        child: _IkonCuacaWarna(deskripsi: deskripsi, malam: malam, size: size),
      ),
    );
  }
}

class _IkonCuacaWarna extends StatelessWidget {
  const _IkonCuacaWarna({
    required this.deskripsi,
    required this.malam,
    required this.size,
  });

  final String deskripsi;
  final bool malam;
  final double size;

  static const _matahari = Color(0xFFFFC533);
  static const _bulan = Color(0xFFF4D98A);
  static const _awan = Color(0xFFF8FBFF);
  static const _awanBelakang = Color(0xFFB9CBE2);
  static const _hujan = Color(0xFF4C8FE6);
  static const _petir = Color(0xFF7D5CF2);
  static const _kabut = Color(0xFFA2AEBE);

  @override
  Widget build(BuildContext context) {
    final bayang = [
      Shadow(
        color: Colors.black.withValues(alpha: .22),
        blurRadius: size * .1,
        offset: Offset(0, size * .04),
      ),
    ];
    final cahaya = [
      Shadow(color: _matahari.withValues(alpha: .55), blurRadius: size * .22),
    ];
    Widget ikon(
      IconData data,
      Color warna,
      double skala, {
      Alignment posisi = Alignment.center,
      List<Shadow>? bayangan,
    }) => Align(
      alignment: posisi,
      child: Icon(data, size: size * skala, color: warna, shadows: bayangan),
    );

    final d = deskripsi.toLowerCase();
    final List<Widget> lapis;
    if (d.contains('petir')) {
      lapis = [ikon(IkonApp.isiAwanPetir, _petir, 1, bayangan: bayang)];
    } else if (d.contains('hujan')) {
      lapis = [ikon(IkonApp.isiAwanHujan, _hujan, 1, bayangan: bayang)];
    } else if (d.contains('kabut') ||
        d.contains('asap') ||
        d.contains('kabur')) {
      lapis = [ikon(IkonApp.isiAwanKabut, _kabut, 1, bayangan: bayang)];
    } else if (d.contains('cerah berawan')) {
      lapis = [
        malam
            ? ikon(IkonApp.isiBulan, _bulan, .66, posisi: Alignment.topLeft)
            : ikon(
                IkonApp.isiMatahari,
                _matahari,
                .7,
                posisi: Alignment.topLeft,
                bayangan: cahaya,
              ),
        ikon(
          IkonApp.isiAwan,
          _awan,
          .78,
          posisi: Alignment.bottomRight,
          bayangan: bayang,
        ),
      ];
    } else if (d.contains('berawan')) {
      lapis = [
        ikon(IkonApp.isiAwan, _awanBelakang, .7, posisi: Alignment.topRight),
        ikon(
          IkonApp.isiAwan,
          _awan,
          .82,
          posisi: Alignment.bottomLeft,
          bayangan: bayang,
        ),
      ];
    } else if (d.contains('cerah')) {
      lapis = [
        malam
            ? ikon(IkonApp.isiBulan, _bulan, .9)
            : ikon(IkonApp.isiMatahari, _matahari, .95, bayangan: cahaya),
      ];
    } else {
      lapis = [ikon(IkonApp.isiAwan, _awan, .9, bayangan: bayang)];
    }
    return SizedBox.square(
      dimension: size,
      child: Stack(clipBehavior: Clip.none, children: lapis),
    );
  }
}
