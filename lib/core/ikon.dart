import 'package:flutter/widgets.dart';

/// Satu keluarga ikon untuk seluruh aplikasi: Phosphor Icons gaya Duotone
/// (MIT, font di assets/fonts). Font statis, jadi saat build release hanya
/// glyph yang dipakai yang masuk APK.
///
/// Paket phosphor_flutter 2.1.0 tidak dipakai karena tidak bisa
/// dikompilasi di Flutter 3.44 (IconData sekarang `final class`). Codepoint
/// di bawah disalin dari paket itu; jangan diubah tanpa memeriksa font.
///
/// Duotone = dua glyph bertumpuk: garis (utama) dan isian tipis (lapisan
/// kedua). Tampil utuh lewat [IkonDuo]; `Icon` biasa hanya menggambar garis.
abstract final class IkonApp {
  static const String _duo = 'PhosphorDuotone';
  static const String _isi = 'PhosphorFill';

  // Navigasi bawah.
  static const IconData beranda = IconData(0xe2c3, fontFamily: _duo); // house
  static const IconData cuaca = IconData(0xe541, fontFamily: _duo); // cloudSun
  static const IconData gempa = IconData(0xe001, fontFamily: _duo); // pulse
  static const IconData peringatan = IconData(0xe0cf, fontFamily: _duo); // bell
  static const IconData pengaturan = IconData(
    0xe273,
    fontFamily: _duo,
  ); // gearSix

  // Aksi.
  static const IconData lokasiSaya = IconData(
    0xe1d7,
    fontFamily: _duo,
  ); // crosshair
  static const IconData cari = IconData(
    0xe30d,
    fontFamily: _duo,
  ); // magnifyingGlass
  static const IconData favorit = IconData(0xe46a, fontFamily: _isi); // star
  static const IconData bukanFavorit = IconData(
    0xe46b,
    fontFamily: _duo,
  ); // star
  static const IconData selengkapnya = IconData(
    0xe13b,
    fontFamily: _duo,
  ); // caretRight
  static const IconData muatUlang = IconData(
    0xe037,
    fontFamily: _duo,
  ); // arrowClockwise
  static const IconData tutup = IconData(0xe4f7, fontFamily: _duo); // x
  static const IconData daftarWilayah = IconData(
    0xe67d,
    fontFamily: _duo,
  ); // treeStructure
  static const IconData saring = IconData(0xe267, fontFamily: _duo); // funnel
  static const IconData bandingkan = IconData(
    0xe0a1,
    fontFamily: _duo,
  ); // arrowsLeftRight
  static const IconData grafik = IconData(0xe151, fontFamily: _duo); // chartBar
  static const IconData hapus = IconData(0xe4f7, fontFamily: _duo); // x
  static const IconData setelan = IconData(
    0xe435,
    fontFamily: _duo,
  ); // slidersHorizontal
  static const IconData bagikan = IconData(
    0xe40b,
    fontFamily: _duo,
  ); // shareNetwork
  static const IconData naik = IconData(0xe08f, fontFamily: _duo); // arrowUp
  static const IconData turun = IconData(0xe03f, fontFamily: _duo); // arrowDown
  static const IconData geser = IconData(
    0xeae3,
    fontFamily: _duo,
  ); // dotsSixVertical
  static const IconData setelUlang = IconData(
    0xe039,
    fontFamily: _duo,
  ); // arrowCounterClockwise
  static const IconData hapusSemua = IconData(
    0xe4a7,
    fontFamily: _duo,
  ); // trash
  static const IconData urutan = IconData(
    0xe2f7,
    fontFamily: _duo,
  ); // listNumbers
  static const IconData riwayatNotif = IconData(
    0xe5eb,
    fontFamily: _duo,
  ); // bellSimpleRinging

  // Status.
  static const IconData offline = IconData(
    0xe1b7,
    fontFamily: _duo,
  ); // cloudSlash
  static const IconData kosong = IconData(0xe4ab, fontFamily: _duo); // tray
  static const IconData lokasiMati = IconData(
    0xedd5,
    fontFamily: _duo,
  ); // gpsSlash
  static const IconData lokasiCari = IconData(
    0xe1d9,
    fontFamily: _duo,
  ); // crosshairSimple
  static const IconData info = IconData(0xe2cf, fontFamily: _duo); // info

  // Data cuaca.
  static const IconData kelembapan = IconData(0xe211, fontFamily: _duo); // drop
  static const IconData angin = IconData(0xe5d3, fontFamily: _duo); // wind
  static const IconData cerah = IconData(0xe473, fontFamily: _duo); // sun
  static const IconData cerahMalam = IconData(0xe331, fontFamily: _duo); // moon
  static const IconData cerahBerawan = IconData(
    0xe541,
    fontFamily: _duo,
  ); // cloudSun
  static const IconData cerahBerawanMalam = IconData(
    0xe53f,
    fontFamily: _duo,
  ); // cloudMoon
  static const IconData berawan = IconData(0xe1ab, fontFamily: _duo); // cloud
  static const IconData kabut = IconData(0xe53d, fontFamily: _duo); // cloudFog
  static const IconData hujan = IconData(0xe1b5, fontFamily: _duo); // cloudRain
  static const IconData petir = IconData(
    0xe1b3,
    fontFamily: _duo,
  ); // cloudLightning

  // Data gempa.
  static const IconData waktu = IconData(0xe19b, fontFamily: _duo); // clock
  static const IconData tempat = IconData(0xe317, fontFamily: _duo); // mapPin
  static const IconData kedalaman = IconData(
    0xe05d,
    fontFamily: _duo,
  ); // arrowLineDown
  static const IconData koordinat = IconData(
    0xe1c9,
    fontFamily: _duo,
  ); // compass
  static const IconData potensi = IconData(0xe6df, fontFamily: _duo); // waves
  static const IconData dirasakan = IconData(0xe4d7, fontFamily: _duo); // users
  static const IconData jarak = IconData(
    0xeadf,
    fontFamily: _duo,
  ); // navigationArrow
  static const IconData gambarTidakAda = IconData(
    0xe7a9,
    fontFamily: _duo,
  ); // imageBroken
  static const IconData riwayat = IconData(
    0xe1a1,
    fontFamily: _duo,
  ); // clockCounterClockwise
  static const IconData siaga = IconData(0xe56f, fontFamily: _duo); // firstAid
  static const IconData panduan = IconData(
    0xe185,
    fontFamily: _duo,
  ); // checkCircle
  static const IconData salin = IconData(0xe1cb, fontFamily: _duo); // copy

  // Peringatan dan Pengaturan.
  static const IconData notifAktif = IconData(
    0xe5e9,
    fontFamily: _duo,
  ); // bellRinging
  static const IconData notifMati = IconData(
    0xe0d5,
    fontFamily: _duo,
  ); // bellSlash
  static const IconData peringatanDini = IconData(
    0xe4e1,
    fontFamily: _duo,
  ); // warning
  static const IconData bahasa = IconData(
    0xe4a3,
    fontFamily: _duo,
  ); // translate
  static const IconData tema = IconData(0xe18d, fontFamily: _duo); // circleHalf
  static const IconData peta = IconData(0xe31b, fontFamily: _duo); // mapTrifold
  static const IconData lisensi = IconData(
    0xe23b,
    fontFamily: _duo,
  ); // fileText
  static const IconData versi = IconData(0xe607, fontFamily: _duo); // sealCheck

  /// Glyph isian untuk tiap glyph garis duotone (kunci: codepoint garis).
  static const Map<int, IconData> lapisanKedua = {
    0xe001: IconData(0xe000, fontFamily: _duo),
    0xe037: IconData(0xe036, fontFamily: _duo),
    0xe039: IconData(0xe038, fontFamily: _duo),
    0xe03f: IconData(0xe03e, fontFamily: _duo),
    0xe05d: IconData(0xe05c, fontFamily: _duo),
    0xe08f: IconData(0xe08e, fontFamily: _duo),
    0xe0a1: IconData(0xe0a0, fontFamily: _duo),
    0xe0cf: IconData(0xe0ce, fontFamily: _duo),
    0xe0d5: IconData(0xe0d4, fontFamily: _duo),
    0xe13b: IconData(0xe13a, fontFamily: _duo),
    0xe151: IconData(0xe150, fontFamily: _duo),
    0xe185: IconData(0xe184, fontFamily: _duo),
    0xe18d: IconData(0xe18c, fontFamily: _duo),
    0xe19b: IconData(0xe19a, fontFamily: _duo),
    0xe1a1: IconData(0xe1a0, fontFamily: _duo),
    0xe1ab: IconData(0xe1aa, fontFamily: _duo),
    0xe1b3: IconData(0xe1b2, fontFamily: _duo),
    0xe1b5: IconData(0xe1b4, fontFamily: _duo),
    0xe1b7: IconData(0xe1b6, fontFamily: _duo),
    0xe1c9: IconData(0xe1c8, fontFamily: _duo),
    0xe1cb: IconData(0xe1ca, fontFamily: _duo),
    0xe1d7: IconData(0xe1d6, fontFamily: _duo),
    0xe1d9: IconData(0xe1d8, fontFamily: _duo),
    0xe211: IconData(0xe210, fontFamily: _duo),
    0xe23b: IconData(0xe23a, fontFamily: _duo),
    0xe267: IconData(0xe266, fontFamily: _duo),
    0xe273: IconData(0xe272, fontFamily: _duo),
    0xe2c3: IconData(0xe2c2, fontFamily: _duo),
    0xe2cf: IconData(0xe2ce, fontFamily: _duo),
    0xe2f7: IconData(0xe2f6, fontFamily: _duo),
    0xe30d: IconData(0xe30c, fontFamily: _duo),
    0xe317: IconData(0xe316, fontFamily: _duo),
    0xe31b: IconData(0xe31a, fontFamily: _duo),
    0xe331: IconData(0xe330, fontFamily: _duo),
    0xe40b: IconData(0xe408, fontFamily: _duo),
    0xe435: IconData(0xe434, fontFamily: _duo),
    0xe46b: IconData(0xe46a, fontFamily: _duo),
    0xe473: IconData(0xe472, fontFamily: _duo),
    0xe4a3: IconData(0xe4a2, fontFamily: _duo),
    0xe4a7: IconData(0xe4a6, fontFamily: _duo),
    0xe4ab: IconData(0xe4aa, fontFamily: _duo),
    0xe4d7: IconData(0xe4d6, fontFamily: _duo),
    0xe4e1: IconData(0xe4e0, fontFamily: _duo),
    0xe4f7: IconData(0xe4f6, fontFamily: _duo),
    0xe53d: IconData(0xe53c, fontFamily: _duo),
    0xe53f: IconData(0xe53e, fontFamily: _duo),
    0xe541: IconData(0xe540, fontFamily: _duo),
    0xe56f: IconData(0xe56e, fontFamily: _duo),
    0xe5d3: IconData(0xe5d2, fontFamily: _duo),
    0xe5e9: IconData(0xe5e8, fontFamily: _duo),
    0xe5eb: IconData(0xe5ea, fontFamily: _duo),
    0xe607: IconData(0xe606, fontFamily: _duo),
    0xe67d: IconData(0xe67c, fontFamily: _duo),
    0xe6df: IconData(0xe6de, fontFamily: _duo),
    0xe7a9: IconData(0xe7a8, fontFamily: _duo),
    0xeadf: IconData(0xeade, fontFamily: _duo),
    0xeae3: IconData(0xeae2, fontFamily: _duo),
    0xedd5: IconData(0xedd4, fontFamily: _duo),
  };
}

/// Ikon Phosphor duotone: lapisan isian (redup) di bawah garis. Untuk ikon
/// tanpa lapisan kedua (mis. bintang terisi) sama dengan [Icon].
class IkonDuo extends StatelessWidget {
  const IkonDuo(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.duotoneSecondaryColor,
    this.duotoneSecondaryOpacity = 0.20,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  /// Warna lapisan isian. Bawaan: sama dengan [color].
  final Color? duotoneSecondaryColor;
  final double duotoneSecondaryOpacity;

  @override
  Widget build(BuildContext context) {
    final utama = Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
    final kedua = IkonApp.lapisanKedua[icon.codePoint];
    if (kedua == null || icon.fontFamily != kedua.fontFamily) return utama;
    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeSemantics(
          child: Opacity(
            opacity: duotoneSecondaryOpacity,
            child: Icon(
              kedua,
              size: size,
              color: duotoneSecondaryColor ?? color,
            ),
          ),
        ),
        utama,
      ],
    );
  }
}
