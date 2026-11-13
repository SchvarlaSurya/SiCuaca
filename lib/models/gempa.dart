import '../core/constants.dart';

/// Satu kejadian gempa dari endpoint autogempa.json BMKG.
///
/// Semua field disimpan sebagai teks apa adanya dari BMKG. Field yang hilang
/// atau null menjadi string kosong, jadi parsing tidak pernah melempar error
/// karena satu field.
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
  });

  /// Membaca objek `gempa` (isi dari `Infogempa.gempa`).
  factory Gempa.fromJson(Map<String, dynamic> json) {
    return Gempa(
      tanggal: _teks(json['Tanggal']),
      jam: _teks(json['Jam']),
      koordinat: _teks(json['Coordinates']),
      lintang: _teks(json['Lintang']),
      bujur: _teks(json['Bujur']),
      magnitudo: _teks(json['Magnitude']),
      kedalaman: _teks(json['Kedalaman']),
      wilayah: _teks(json['Wilayah']),
      potensi: _teks(json['Potensi']),
      dirasakan: _teks(json['Dirasakan']),
      shakemap: _teks(json['Shakemap']),
    );
  }

  /// Membaca seluruh respons autogempa.json: `{"Infogempa": {"gempa": {...}}}`.
  ///
  /// Melempar [FormatException] bila kerangka `Infogempa.gempa` tidak ada,
  /// karena tanpa itu memang tidak ada data gempa yang bisa ditampilkan.
  factory Gempa.fromAutoGempaJson(Map<String, dynamic> json) {
    final info = json['Infogempa'];
    if (info is! Map) {
      throw const FormatException('kunci "Infogempa" tidak ditemukan');
    }
    var gempa = info['gempa'];
    // Endpoint daftar gempa BMKG memakai list; ambil item pertama bila begitu.
    if (gempa is List && gempa.isNotEmpty) gempa = gempa.first;
    if (gempa is! Map) {
      throw const FormatException('kunci "Infogempa.gempa" tidak ditemukan');
    }
    return Gempa.fromJson(Map<String, dynamic>.from(gempa));
  }

  final String tanggal;
  final String jam;
  final String koordinat;
  final String lintang;
  final String bujur;
  final String magnitudo;
  final String kedalaman;
  final String wilayah;
  final String potensi;
  final String dirasakan;

  /// Nama file shakemap, mis. `20261113021440.mmi.jpg`.
  final String shakemap;

  /// URL gambar shakemap lengkap, atau null bila BMKG tidak menyertakannya.
  String? get shakemapUrl =>
      shakemap.isEmpty ? null : '${ApiConstants.shakemapBaseUrl}$shakemap';

  static String _teks(Object? value) => value?.toString().trim() ?? '';
}
