import '../core/parsing.dart';

/// Satu wilayah tingkat desa/kelurahan (adm4).
///
/// Dipakai untuk blok `lokasi` dari BMKG, hasil pencarian dataset wilayah,
/// wilayah terakhir, dan wilayah favorit.
class Lokasi {
  const Lokasi({
    required this.adm4,
    required this.desa,
    required this.kecamatan,
    required this.kotkab,
    required this.provinsi,
    this.lat,
    this.lon,
    this.timezone = '',
  });

  /// Membaca blok `lokasi` BMKG, juga format yang disimpan [toJson].
  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      adm4: Baca.teks(json['adm4']),
      desa: Baca.teks(json['desa']),
      kecamatan: Baca.teks(json['kecamatan']),
      kotkab: Baca.teks(json['kotkab']),
      provinsi: Baca.teks(json['provinsi']),
      lat: Baca.angka(json['lat']),
      lon: Baca.angka(json['lon']),
      timezone: Baca.teks(json['timezone']),
    );
  }

  /// Kode Kepmendagri, mis. `31.71.01.1001`.
  final String adm4;
  final String desa;
  final String kecamatan;
  final String kotkab;
  final String provinsi;
  final double? lat;
  final double? lon;
  final String timezone;

  /// "desa, kecamatan, kab/kota, provinsi", bagian kosong dilewati.
  String get labelLengkap =>
      [desa, kecamatan, kotkab, provinsi].where((s) => s.isNotEmpty).join(', ');

  /// "kecamatan, kab/kota" untuk baris kedua di bawah nama desa.
  String get labelInduk =>
      [kecamatan, kotkab].where((s) => s.isNotEmpty).join(', ');

  Map<String, dynamic> toJson() => {
    'adm4': adm4,
    'desa': desa,
    'kecamatan': kecamatan,
    'kotkab': kotkab,
    'provinsi': provinsi,
    'lat': lat,
    'lon': lon,
    'timezone': timezone,
  };

  @override
  bool operator ==(Object other) => other is Lokasi && other.adm4 == adm4;

  @override
  int get hashCode => adm4.hashCode;
}
