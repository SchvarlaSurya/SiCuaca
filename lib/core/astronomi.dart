import 'dart:math' as math;

/// Fase bulan dalam delapan bagian, berurutan dari bulan baru.
enum FaseBulan {
  baru,
  sabitAwal,
  perempatPertama,
  cembungAwal,
  purnama,
  cembungAkhir,
  perempatAkhir,
  sabitAkhir,
}

/// Jam terbit dan terbenam sebuah benda langit pada satu hari setempat. Null
/// bila tidak terjadi pada hari itu (bulan bisa melewati satu hari tanpa
/// terbit atau terbenam).
///
/// Waktunya jam dinding setempat yang disimpan sebagai DateTime UTC, sama
/// dengan `EntriPrakiraan.waktuLokal`.
class PeristiwaLangit {
  const PeristiwaLangit({this.terbit, this.terbenam});

  final DateTime? terbit;
  final DateTime? terbenam;
}

/// Hasil hitungan matahari dan bulan untuk satu lokasi dan hari.
class DataAstronomi {
  const DataAstronomi({
    required this.matahari,
    required this.bulan,
    required this.lamaSiang,
    required this.terangBulan,
    required this.fase,
  });

  final PeristiwaLangit matahari;
  final PeristiwaLangit bulan;

  /// Selang dari matahari terbit sampai terbenam; null bila salah satunya
  /// tidak terjadi.
  final Duration? lamaSiang;

  /// Bagian piringan bulan yang terang, 0..1.
  final double terangBulan;
  final FaseBulan fase;
}

/// Perhitungan astronomi dan cuaca turunan yang dilakukan di dalam aplikasi,
/// tanpa jaringan dan tanpa data BMKG.
///
/// Ketelitiannya cukup untuk tampilan cuaca: jam matahari sekitar satu menit,
/// jam bulan beberapa menit. Rumus posisi matahari dari Astronomical Almanac,
/// posisi bulan dari deret ringkas Paul Schlyter.
abstract final class Astronomi {
  static const _rad = math.pi / 180;

  // Tinggi pusat piringan saat terbit/terbenam: matahari -50' (refraksi dan
  // jari-jari piringan), bulan +7' (paralaks dikurangi refraksi).
  static const _tepiMatahari = -.833;
  static const _tepiBulan = .125;

  /// Hitung untuk [tanggalSetempat] (hari kalender setempat, jamnya diabaikan)
  /// di [lat]/[lon] derajat, dengan zona waktu [selisih] terhadap UTC.
  static DataAstronomi hitung({
    required double lat,
    required double lon,
    required DateTime tanggalSetempat,
    required Duration selisih,
  }) {
    final awalHari = DateTime.utc(
      tanggalSetempat.year,
      tanggalSetempat.month,
      tanggalSetempat.day,
    ).subtract(selisih);

    PeristiwaLangit cari(double Function(double jd) tinggi, double tepi) {
      DateTime? terbit;
      DateTime? terbenam;
      const langkahMenit = 10;
      var t0 = awalHari;
      var f0 = tinggi(_jd(t0)) - tepi;
      for (var m = langkahMenit; m <= 24 * 60; m += langkahMenit) {
        final t1 = awalHari.add(Duration(minutes: m));
        final f1 = tinggi(_jd(t1)) - tepi;
        if ((f0 < 0) != (f1 < 0)) {
          final saat = _belah(tinggi, tepi, t0, t1);
          final lokal = saat.add(selisih);
          if (f1 >= 0) {
            terbit ??= lokal;
          } else {
            terbenam ??= lokal;
          }
        }
        t0 = t1;
        f0 = f1;
      }
      return PeristiwaLangit(terbit: terbit, terbenam: terbenam);
    }

    final matahari = cari(
      (jd) => _tinggi(_posisiMatahari(jd), jd, lat, lon),
      _tepiMatahari,
    );
    final bulan = cari(
      (jd) => _tinggi(_posisiBulan(jd), jd, lat, lon),
      _tepiBulan,
    );

    // Fase di tengah hari setempat.
    final siang = awalHari.add(const Duration(hours: 12));
    final jdSiang = _jd(siang);
    final elongasi = _normal(
      _posisiBulan(jdSiang).bujurEkliptika -
          _posisiMatahari(jdSiang).bujurEkliptika,
    );
    final terang = (1 - math.cos(elongasi * _rad)) / 2;
    final indeks = ((elongasi + 22.5) / 45).floor() % 8;

    final t = matahari.terbit;
    final b = matahari.terbenam;
    return DataAstronomi(
      matahari: matahari,
      bulan: bulan,
      lamaSiang: t != null && b != null && b.isAfter(t)
          ? b.difference(t)
          : null,
      terangBulan: terang,
      fase: FaseBulan.values[indeks],
    );
  }

  /// Titik embun (°C) dari suhu (°C) dan kelembapan relatif (%), rumus
  /// Magnus. Nilai turunan, bukan pengukuran.
  static double titikEmbun(double suhuC, int kelembapan) {
    const a = 17.62;
    const b = 243.12;
    final rh = kelembapan.clamp(1, 100) / 100;
    final g = math.log(rh) + a * suhuC / (b + suhuC);
    return b * g / (a - g);
  }

  // ── Waktu ──────────────────────────────────────────────────────────────

  static double _jd(DateTime utc) =>
      utc.millisecondsSinceEpoch / 86400000 + 2440587.5;

  static DateTime _dariJd(double jd) => DateTime.fromMillisecondsSinceEpoch(
    ((jd - 2440587.5) * 86400000).round(),
    isUtc: true,
  );

  static double _normal(double derajat) {
    final n = derajat % 360;
    return n < 0 ? n + 360 : n;
  }

  /// Cari saat tinggi melewati [tepi] di antara [a] dan [b] (bagi dua).
  static DateTime _belah(
    double Function(double jd) tinggi,
    double tepi,
    DateTime a,
    DateTime b,
  ) {
    var lo = _jd(a);
    var hi = _jd(b);
    final naikDariBawah = tinggi(lo) - tepi < 0;
    for (var i = 0; i < 24; i++) {
      final mid = (lo + hi) / 2;
      final bawah = tinggi(mid) - tepi < 0;
      if (bawah == naikDariBawah) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return _dariJd((lo + hi) / 2);
  }

  // ── Posisi ─────────────────────────────────────────────────────────────

  /// Tinggi benda (derajat di atas horizon) dari posisi ekuatorialnya.
  static double _tinggi(_Posisi p, double jd, double lat, double lon) {
    final gmst = _normal(280.46061837 + 360.98564736629 * (jd - 2451545.0));
    final h = (gmst + lon - p.asensioRekta) * _rad;
    final f = lat * _rad;
    final d = p.deklinasi * _rad;
    final s =
        math.sin(f) * math.sin(d) + math.cos(f) * math.cos(d) * math.cos(h);
    return math.asin(s.clamp(-1.0, 1.0)) / _rad;
  }

  static _Posisi _posisiMatahari(double jd) {
    final n = jd - 2451545.0;
    final l = _normal(280.460 + 0.9856474 * n);
    final g = _normal(357.528 + 0.9856003 * n) * _rad;
    final bujur = _normal(l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g));
    final miring = (23.439 - 0.0000004 * n) * _rad;
    final lam = bujur * _rad;
    final ra = math.atan2(math.cos(miring) * math.sin(lam), math.cos(lam));
    final dek = math.asin(math.sin(miring) * math.sin(lam));
    return _Posisi(_normal(ra / _rad), dek / _rad, bujur);
  }

  static _Posisi _posisiBulan(double jd) {
    final d = jd - 2451543.5; // hari sejak 0 Januari 2000
    final nn = _normal(125.1228 - 0.0529538083 * d);
    const i = 5.1454;
    final w = _normal(318.0634 + 0.1643573223 * d);
    const a = 60.2666;
    const e = 0.054900;
    final m = _normal(115.3654 + 13.0649929509 * d);

    // Persamaan Kepler.
    final mr = m * _rad;
    var ek = m + e / _rad * math.sin(mr) * (1 + e * math.cos(mr));
    for (var k = 0; k < 5; k++) {
      final er = ek * _rad;
      final delta = (ek - e / _rad * math.sin(er) - m) / (1 - e * math.cos(er));
      ek -= delta;
      if (delta.abs() < 1e-4) break;
    }
    final er = ek * _rad;
    final xv = a * (math.cos(er) - e);
    final yv = a * math.sqrt(1 - e * e) * math.sin(er);
    final v = math.atan2(yv, xv) / _rad;
    var r = math.sqrt(xv * xv + yv * yv);

    final nr = nn * _rad;
    final vw = (v + w) * _rad;
    final ir = i * _rad;
    final xh =
        r *
        (math.cos(nr) * math.cos(vw) -
            math.sin(nr) * math.sin(vw) * math.cos(ir));
    final yh =
        r *
        (math.sin(nr) * math.cos(vw) +
            math.cos(nr) * math.sin(vw) * math.cos(ir));
    final zh = r * math.sin(vw) * math.sin(ir);
    var bujur = math.atan2(yh, xh) / _rad;
    var lintang = math.atan2(zh, math.sqrt(xh * xh + yh * yh)) / _rad;

    // Gangguan terbesar (matahari dan bentuk orbit).
    final ms = _normal(356.0470 + 0.9856002585 * d);
    final ws = 282.9404 + 4.70935e-5 * d;
    final ls = ms + ws;
    final lm = m + w + nn;
    final dd = (lm - ls) * _rad;
    final ff = (lm - nn) * _rad;
    final mm = m * _rad;
    final msr = ms * _rad;
    bujur +=
        -1.274 * math.sin(mm - 2 * dd) +
        0.658 * math.sin(2 * dd) -
        0.186 * math.sin(msr) -
        0.059 * math.sin(2 * mm - 2 * dd) -
        0.057 * math.sin(mm - 2 * dd + msr) +
        0.053 * math.sin(mm + 2 * dd) +
        0.046 * math.sin(2 * dd - msr) +
        0.041 * math.sin(mm - msr) -
        0.035 * math.sin(dd) -
        0.031 * math.sin(mm + msr) -
        0.015 * math.sin(2 * ff - 2 * dd) +
        0.011 * math.sin(mm - 4 * dd);
    lintang +=
        -0.173 * math.sin(ff - 2 * dd) -
        0.055 * math.sin(mm - ff - 2 * dd) -
        0.046 * math.sin(mm + ff - 2 * dd) +
        0.033 * math.sin(ff + 2 * dd) +
        0.017 * math.sin(2 * mm + ff);
    r += -0.58 * math.cos(mm - 2 * dd) - 0.46 * math.cos(2 * dd);

    // Ekliptika ke ekuator.
    final lonR = bujur * _rad;
    final latR = lintang * _rad;
    final xg = r * math.cos(lonR) * math.cos(latR);
    final yg = r * math.sin(lonR) * math.cos(latR);
    final zg = r * math.sin(latR);
    final miring = (23.4393 - 3.563e-7 * d) * _rad;
    final ye = yg * math.cos(miring) - zg * math.sin(miring);
    final ze = yg * math.sin(miring) + zg * math.cos(miring);
    final ra = math.atan2(ye, xg) / _rad;
    final dek = math.atan2(ze, math.sqrt(xg * xg + ye * ye)) / _rad;
    return _Posisi(_normal(ra), dek, _normal(bujur));
  }
}

class _Posisi {
  const _Posisi(this.asensioRekta, this.deklinasi, this.bujurEkliptika);

  /// Derajat.
  final double asensioRekta;
  final double deklinasi;
  final double bujurEkliptika;
}
