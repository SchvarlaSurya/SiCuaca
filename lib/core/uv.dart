import 'dart:math' as math;

import 'astronomi.dart';

/// Kategori indeks UV menurut WHO.
enum KategoriUv { rendah, sedang, tinggi, sangatTinggi, ekstrem }

/// Perkiraan indeks UV yang dihitung di dalam aplikasi: tanpa jaringan, tanpa
/// API luar. Dasarnya ketinggian matahari (astronomi, lihat [Astronomi]) dan
/// tutupan awan dari prakiraan BMKG.
///
/// Ini perkiraan, bukan pengukuran. Rumusnya langit cerah baku
/// (UVI ~ 12,5 * cos(sudut zenit)^2,42 * (ozon / 300)^-1,23) dengan ozon
/// klimatologi per lintang, dikalikan faktor awan. Yang TIDAK diperhitungkan:
/// aerosol (kabut asap dan polusi menurunkan UV nyata sekitar 5-20%, jadi
/// hasilnya cenderung agak tinggi di hari berkabut), ketinggian tempat
/// (UV naik sekitar 6-8% tiap 1000 m), dan efek awan tipis/pecah. Karena itu
/// UI hanya menampilkan kategori dan melabelinya "perkiraan".
abstract final class Uv {
  /// Kategori dari angka UVI (dibulatkan ke bilangan bulat seperti laporan UV).
  static KategoriUv kategori(double uvi) {
    final n = uvi.round();
    if (n <= 2) return KategoriUv.rendah;
    if (n <= 5) return KategoriUv.sedang;
    if (n <= 7) return KategoriUv.tinggi;
    if (n <= 10) return KategoriUv.sangatTinggi;
    return KategoriUv.ekstrem;
  }

  /// Total ozon kolom (Dobson) kasar menurut lintang: sekitar 260 di daerah
  /// tropis, naik ke 300 di lintang menengah.
  static double ozon(double lat) {
    final a = lat.abs();
    return (260 + (a - 15) / 30 * 40).clamp(260.0, 320.0);
  }

  /// UVI langit cerah pada [utc]; 0 saat matahari di bawah cakrawala.
  static double langitCerah({
    required double lat,
    required double lon,
    required DateTime utc,
  }) {
    final tinggi = Astronomi.tinggiMatahari(lat: lat, lon: lon, utc: utc);
    if (tinggi <= 0) return 0;
    final mu0 = math.sin(tinggi * math.pi / 180);
    return 12.5 * math.pow(mu0, 2.42) * math.pow(ozon(lat) / 300, -1.23);
  }

  /// Faktor pelemahan oleh awan (1 = cerah) dari tutupan awan 0..100 persen:
  /// 1 - 0,75 * N^3,4 (bentuk umum faktor awan UV). Tanpa data awan, 1.
  static double faktorAwan(int? tutupanAwanPersen) {
    if (tutupanAwanPersen == null) return 1;
    final n = (tutupanAwanPersen.clamp(0, 100)) / 100;
    return 1 - 0.75 * math.pow(n, 3.4);
  }

  /// Perkiraan UVI pada [utc] dengan tutupan awan [tutupanAwanPersen].
  static double perkiraan({
    required double lat,
    required double lon,
    required DateTime utc,
    int? tutupanAwanPersen,
  }) =>
      langitCerah(lat: lat, lon: lon, utc: utc) * faktorAwan(tutupanAwanPersen);

  /// Puncak UV pada hari setempat dari [titikAwan] (waktu UTC + tutupan awan
  /// prakiraan, urut waktu): dihitung tiap jam dari 06.00 sampai 18.00 jam
  /// setempat memakai awan titik prakiraan terdekat. Null bila tidak ada
  /// titik.
  static ({double uvi, DateTime waktuSetempat})? puncak({
    required double lat,
    required double lon,
    required DateTime tanggalSetempat,
    required Duration selisih,
    required List<({DateTime utc, int? awan})> titikAwan,
  }) {
    if (titikAwan.isEmpty) return null;
    final awal = DateTime.utc(
      tanggalSetempat.year,
      tanggalSetempat.month,
      tanggalSetempat.day,
    );
    double? terbaik;
    DateTime? saatTerbaik;
    for (var jam = 6; jam <= 18; jam++) {
      final lokal = awal.add(Duration(hours: jam));
      final utc = lokal.subtract(selisih);
      var dekat = titikAwan.first;
      for (final t in titikAwan) {
        if (t.utc.difference(utc).abs() < dekat.utc.difference(utc).abs()) {
          dekat = t;
        }
      }
      final v = perkiraan(
        lat: lat,
        lon: lon,
        utc: utc,
        tutupanAwanPersen: dekat.awan,
      );
      if (terbaik == null || v > terbaik) {
        terbaik = v;
        saatTerbaik = lokal;
      }
    }
    return (uvi: terbaik!, waktuSetempat: saatTerbaik!);
  }
}
