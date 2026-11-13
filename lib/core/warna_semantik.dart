import 'package:flutter/material.dart';

import 'l10n.dart';

/// Warna bermakna yang tidak ikut skema Material: kartu cuaca (kondisi ×
/// siang/malam × terang/gelap) dan tingkat magnitudo. Semua pasangan teks
/// sudah dicek WCAG ≥ 4,5:1 terhadap kedua ujung gradasi.

enum KondisiLangit {
  cerah,
  berawan,
  kabut,
  hujan,
  petir;

  /// Dicocokkan dengan kata kunci `weather_desc` BMKG (sama dengan ikon).
  static KondisiLangit dari(String deskripsi) {
    final d = deskripsi.toLowerCase();
    if (d.contains('petir')) return petir;
    if (d.contains('hujan')) return hujan;
    if (d.contains('kabut') || d.contains('asap') || d.contains('kabur')) {
      return kabut;
    }
    if (d.contains('cerah berawan')) return berawan;
    if (d.contains('berawan')) return berawan;
    if (d.contains('cerah')) return cerah;
    return berawan;
  }
}

/// Warna kartu hero cuaca.
class GayaHero {
  const GayaHero(this.atas, this.bawah, this.teks, this.redup);

  final Color atas;
  final Color bawah;

  /// Teks utama (suhu, nama tempat) dan ikon.
  final Color teks;

  /// Teks sekunder.
  final Color redup;

  static const _teksTerang = Color(0xFF0E1B2C);
  static const _redupTerang = Color(0xFF34414F);
  static const _teksGelap = Color(0xFFF2F5FA);
  static const _redupGelap = Color(0xFFC9D2DE);

  // Kontras teks utama/sekunder terendah per gradasi tercatat di komentar.
  static const Map<(KondisiLangit, bool), (int, int)> _terang = {
    (KondisiLangit.cerah, false): (0xFFFFE3A8, 0xFFFFF4DC), // 13,9 / 8,3
    (KondisiLangit.cerah, true): (0xFFD9DDF5, 0xFFEEF0FB), // 12,9 / 7,8
    (KondisiLangit.berawan, false): (0xFFD3E4FF, 0xFFEBF2FF), // 13,5 / 8,1
    (KondisiLangit.berawan, true): (0xFFCBD3E3, 0xFFE6EAF2), // 11,5 / 6,9
    (KondisiLangit.kabut, false): (0xFFE0E3E7, 0xFFF1F2F4), // 13,5 / 8,1
    (KondisiLangit.kabut, true): (0xFFD2D6DD, 0xFFE8EAEE), // 11,9 / 7,2
    (KondisiLangit.hujan, false): (0xFFC5DAEA, 0xFFE3EEF6), // 12,0 / 7,2
    (KondisiLangit.hujan, true): (0xFFBFC9DA, 0xFFDFE4EE), // 10,4 / 6,2
    (KondisiLangit.petir, false): (0xFFDAD0EE, 0xFFEEE9F7), // 11,8 / 7,1
    (KondisiLangit.petir, true): (0xFFCAC2E1, 0xFFE5E1F0), // 10,2 / 6,1
  };

  static const Map<(KondisiLangit, bool), (int, int)> _gelap = {
    (KondisiLangit.cerah, false): (0xFF4A3410, 0xFF2A2112), // 10,7 / 7,7
    (KondisiLangit.cerah, true): (0xFF1F2858, 0xFF121833), // 12,8 / 9,2
    (KondisiLangit.berawan, false): (0xFF21395A, 0xFF16243A), // 10,7 / 7,7
    (KondisiLangit.berawan, true): (0xFF1B253B, 0xFF121826), // 14,0 / 10,0
    (KondisiLangit.kabut, false): (0xFF353A42, 0xFF23272D), // 10,5 / 7,5
    (KondisiLangit.kabut, true): (0xFF292D35, 0xFF1A1D22), // 12,6 / 9,0
    (KondisiLangit.hujan, false): (0xFF173D54, 0xFF112A3A), // 10,5 / 7,5
    (KondisiLangit.hujan, true): (0xFF15283A, 0xFF0E1A26), // 13,8 / 9,9
    (KondisiLangit.petir, false): (0xFF362A5E, 0xFF221C3D), // 11,7 / 8,3
    (KondisiLangit.petir, true): (0xFF2A2050, 0xFF18142E), // 13,5 / 9,7
  };

  static GayaHero untuk(
    KondisiLangit kondisi, {
    required bool malam,
    required Brightness kecerahan,
  }) {
    final gelap = kecerahan == Brightness.dark;
    final (atas, bawah) = (gelap ? _gelap : _terang)[(kondisi, malam)]!;
    return GayaHero(
      Color(atas),
      Color(bawah),
      gelap ? _teksGelap : _teksTerang,
      gelap ? _redupGelap : _redupTerang,
    );
  }
}

/// Tingkat magnitudo dengan label teks (warna bukan satu-satunya penanda).
/// Kelas mengikuti pembagian magnitudo USGS (minor/light/moderate/strong/
/// major). Kontras teks terhadap latar tercatat di komentar.
enum TingkatMagnitudo {
  kecil(Color(0xFF2F6B3B), Colors.white), // 6,4:1
  ringan(Color(0xFFF2C14E), Color(0xFF231A00)), // 10,3:1
  sedang(Color(0xFFB54708), Colors.white), // 5,4:1
  kuat(Color(0xFFB42318), Colors.white), // 6,6:1
  besar(Color(0xFF6B0F1A), Colors.white), // 12,3:1
  takDiketahui(Color(0xFF5B636D), Colors.white); // 6,1:1

  const TingkatMagnitudo(this.latar, this.depan);

  final Color latar;
  final Color depan;

  static TingkatMagnitudo dari(double? m) {
    if (m == null) return takDiketahui;
    if (m >= 7) return besar;
    if (m >= 6) return kuat;
    if (m >= 5) return sedang;
    if (m >= 4) return ringan;
    return kecil;
  }

  String label(AppLocalizations l) => switch (this) {
    kecil => l.magKecil,
    ringan => l.magRingan,
    sedang => l.magSedang,
    kuat => l.magKuat,
    besar => l.magBesar,
    takDiketahui => l.magTakDiketahui,
  };
}
