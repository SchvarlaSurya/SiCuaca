import '../core/constants.dart';
import '../core/parsing.dart';

/// Satu kejadian gempa dari BMKG. Dipakai untuk ketiga berkas:
/// autogempa.json (satu objek), gempaterkini.json (M 5.0+, daftar), dan
/// gempadirasakan.json (daftar).
///
/// Field teks disimpan apa adanya dari BMKG; yang hilang atau null menjadi
/// string kosong. Field turunan (waktu, koordinat, magnitudo angka) bernilai
/// null bila tidak bisa dibaca. Parsing tidak pernah melempar error karena
/// satu field.
class Gempa {
  const Gempa({
    required this.tanggal,
    required this.jam,
    required this.koordinat,
    required this.lintang,
    required this.bujur,
    required this.magnitudo,
    required this.kedalaman,
    required this.wilayah,
    required this.potensi,
    required this.dirasakan,
    required this.shakemap,
    this.waktuUtc,
    this.lat,
    this.lon,
  });

  /// Membaca satu objek gempa (isi `Infogempa.gempa` atau elemennya).
  factory Gempa.fromJson(Map<String, dynamic> json) {
    final koordinat = Baca.teks(json['Coordinates']);
    final lintang = Baca.teks(json['Lintang']);
    final bujur = Baca.teks(json['Bujur']);
    final (lat, lon) = _bacaKoordinat(koordinat, lintang, bujur);

    return Gempa(
      tanggal: Baca.teks(json['Tanggal']),
      jam: Baca.teks(json['Jam']),
      koordinat: koordinat,
      lintang: lintang,
      bujur: bujur,
      magnitudo: Baca.teks(json['Magnitude']),
      kedalaman: Baca.teks(json['Kedalaman']),
      wilayah: Baca.teks(json['Wilayah']),
      potensi: Baca.teks(json['Potensi']),
      dirasakan: Baca.teks(json['Dirasakan']),
      shakemap: Baca.teks(json['Shakemap']),
      waktuUtc: Baca.waktuUtc(json['DateTime']),
      lat: lat,
      lon: lon,
    );
  }

  /// Bentuk ringkas untuk penyimpanan riwayat lokal. Data ini tetap memakai
  /// nama field BMKG agar dibaca kembali melalui jalur parser yang sama.
  Map<String, dynamic> toJson() => {
    'Tanggal': tanggal,
    'Jam': jam,
    'Coordinates': koordinat,
    'Lintang': lintang,
    'Bujur': bujur,
    'Magnitude': magnitudo,
    'Kedalaman': kedalaman,
    'Wilayah': wilayah,
    'Potensi': potensi,
    'Dirasakan': dirasakan,
    'Shakemap': shakemap,
    'DateTime': waktuUtc?.toIso8601String(),
  };

  /// Membaca data FCM dari backend SiCuaca (lihat sicuaca-backend/README.md).
  /// Mengembalikan null bila bukan pesan gempa atau datanya tidak cukup
  /// (tanpa kunci, waktu, atau koordinat).
  static Gempa? dariPayload(Map<String, dynamic>? data) {
    if (data == null || Baca.teks(data['jenis']) != 'gempa') return null;
    if (Baca.teks(data['gempa_key']).isEmpty) return null;

    final gempa = Gempa.fromJson({
      'Tanggal': data['tanggal'],
      'Jam': data['jam'],
      'DateTime': data['waktu'],
      'Coordinates': data['koordinat'],
      'Magnitude': data['magnitudo'],
      'Kedalaman': data['kedalaman'],
      'Wilayah': data['wilayah'],
      'Potensi': data['potensi'],
      'Dirasakan': data['dirasakan'],
      'Shakemap': data['shakemap'],
    });
    if (gempa.waktuUtc == null || !gempa.punyaKoordinat) return null;
    return gempa;
  }

  /// Membaca respons autogempa.json: `{"Infogempa": {"gempa": {...}}}`.
  ///
  /// Melempar [FormatException] bila kerangka `Infogempa.gempa` tidak ada.
  factory Gempa.fromAutoGempaJson(Map<String, dynamic> json) {
    final daftar = daftarDariJson(json);
    if (daftar.isEmpty) {
      throw const FormatException('kunci "Infogempa.gempa" tidak ditemukan');
    }
    return daftar.first;
  }

  /// Membaca respons gempaterkini.json / gempadirasakan.json:
  /// `{"Infogempa": {"gempa": [ {...}, ... ]}}`. Juga menerima satu objek.
  /// Hasil diurutkan dari yang terbaru.
  ///
  /// Melempar [FormatException] bila kunci `Infogempa` tidak ada.
  static List<Gempa> daftarDariJson(Map<String, dynamic> json) {
    final info = Baca.peta(json['Infogempa']);
    if (info == null) {
      throw const FormatException('kunci "Infogempa" tidak ditemukan');
    }
    final isi = info['gempa'];
    final mentah = isi is List ? isi : [isi];
    final hasil = <Gempa>[
      for (final e in mentah)
        if (Baca.peta(e) case final peta?) Gempa.fromJson(peta),
    ];
    hasil.sort((a, b) {
      final wa = a.waktuUtc;
      final wb = b.waktuUtc;
      if (wa == null && wb == null) return 0;
      if (wa == null) return 1;
      if (wb == null) return -1;
      return wb.compareTo(wa);
    });
    return hasil;
  }

  final String tanggal;
  final String jam;

  /// Teks asli `Coordinates`, mis. "-5.56,102.24" (lintang,bujur).
  final String koordinat;
  final String lintang;
  final String bujur;
  final String magnitudo;
  final String kedalaman;
  final String wilayah;

  /// Hanya ada di autogempa dan gempaterkini.
  final String potensi;

  /// Hanya ada di autogempa dan gempadirasakan.
  final String dirasakan;

  /// Nama berkas shakemap. Hanya ada di autogempa.
  final String shakemap;

  /// Waktu kejadian dari `DateTime` (ISO 8601, UTC).
  final DateTime? waktuUtc;

  /// Lintang dan bujur desimal; negatif = LS / BB.
  final double? lat;
  final double? lon;

  double? get magnitudoAngka => Baca.angka(magnitudo);

  bool get punyaKoordinat => lat != null && lon != null;

  /// URL gambar shakemap.
  ///
  /// Bila field `Shakemap` tidak ada (gempaterkini/gempadirasakan), nama
  /// berkas diturunkan dari Tanggal + Jam dengan pola yang sama
  /// (`yyyyMMddHHmmss.mmi.jpg`). Pola ini tidak didokumentasikan BMKG dan
  /// tidak semua gempa punya shakemap, jadi tampilan wajib punya fallback.
  String? get shakemapUrl {
    final nama = shakemap.isNotEmpty ? shakemap : _namaShakemapTurunan();
    return nama == null ? null : '${ApiConstants.shakemapBaseUrl}$nama';
  }

  /// Kunci unik kejadian (sama dengan gempa_key di backend).
  String get kunci =>
      '${waktuUtc?.toIso8601String() ?? '$tanggal $jam'}|$koordinat';

  @override
  bool operator ==(Object other) => other is Gempa && other.kunci == kunci;

  @override
  int get hashCode => kunci.hashCode;

  String? _namaShakemapTurunan() {
    final t = tanggal.split(' ');
    final j = RegExp(r'^(\d{2}):(\d{2}):(\d{2})').firstMatch(jam);
    if (t.length != 3 || j == null) return null;
    final hari = int.tryParse(t[0]);
    final bulan = _bulan[t[1].toLowerCase()];
    final tahun = int.tryParse(t[2]);
    if (hari == null || bulan == null || tahun == null) return null;
    String dua(int n) => n.toString().padLeft(2, '0');
    return '$tahun${dua(bulan)}${dua(hari)}${j[1]}${j[2]}${j[3]}.mmi.jpg';
  }

  static const Map<String, int> _bulan = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'mei': 5, 'may': 5, 'jun': 6, //
    'jul': 7, 'agu': 8, 'agt': 8, 'aug': 8, 'sep': 9, 'okt': 10, 'oct': 10,
    'nov': 11, 'des': 12, 'dec': 12,
  };

  /// `Coordinates` berisi "lintang,bujur" bertanda (mis. "-5.56,102.24").
  /// Bila tidak terbaca, dicoba dari Lintang ("5.56 LS") dan Bujur
  /// ("102.24 BT"): LS dan BB berarti negatif.
  static (double?, double?) _bacaKoordinat(
    String koordinat,
    String lintang,
    String bujur,
  ) {
    final bagian = koordinat.split(',');
    if (bagian.length == 2) {
      final lat = double.tryParse(bagian[0].trim());
      final lon = double.tryParse(bagian[1].trim());
      if (lat != null && lon != null && _wajar(lat, lon)) return (lat, lon);
    }
    final lat = _bertanda(lintang, negatif: 'LS', positif: 'LU');
    final lon = _bertanda(bujur, negatif: 'BB', positif: 'BT');
    if (lat != null && lon != null && _wajar(lat, lon)) return (lat, lon);
    return (null, null);
  }

  static double? _bertanda(
    String teks, {
    required String negatif,
    required String positif,
  }) {
    final m = RegExp(r'^(-?[\d.]+)\s*([A-Za-z]*)').firstMatch(teks.trim());
    if (m == null) return null;
    final nilai = double.tryParse(m[1]!);
    if (nilai == null) return null;
    final arah = m[2]!.toUpperCase();
    if (arah == negatif) return -nilai.abs();
    if (arah == positif) return nilai.abs();
    return nilai;
  }

  static bool _wajar(double lat, double lon) =>
      lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
}
