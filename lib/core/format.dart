import 'strings.dart';

/// Pemformat angka dan waktu untuk tampilan (tanpa paket intl).
class Format {
  const Format._();

  static String suhu(double? c) =>
      c == null ? Str.tandaKosong : '${c.round()}${Str.satuanSuhu}';

  static String persen(int? n) => n == null ? Str.tandaKosong : '$n%';

  /// Angka desimal ala Indonesia: 5.5 -> "5,5", 12.0 -> "12".
  static String desimal(double? n) {
    if (n == null) return Str.tandaKosong;
    final teks = n == n.roundToDouble()
        ? n.toStringAsFixed(0)
        : n.toStringAsFixed(1);
    return teks.replaceAll('.', ',');
  }

  static String angin(double? kecepatan, String arah) =>
      Str.kecepatanAngin(desimal(kecepatan), Str.arahAngin[arah] ?? arah);

  static String jam(DateTime? waktu) {
    if (waktu == null) return Str.tandaKosong;
    String dua(int n) => n.toString().padLeft(2, '0');
    return '${dua(waktu.hour)}:${dua(waktu.minute)}';
  }

  /// WIB/WITA/WIT dari selisih terhadap UTC; kosong bila tidak dikenal.
  static String zona(Duration? selisih) =>
      selisih == null ? '' : Str.zonaWaktu[selisih.inHours] ?? '';

  /// "Hari ini", "Besok", atau "Sabtu, 15 Nov".
  ///
  /// [tanggal] dan [hariIni] sama-sama jam dinding setempat.
  static String labelHari(DateTime? tanggal, DateTime hariIni) {
    if (tanggal == null) return Str.tandaKosong;
    final a = DateTime.utc(tanggal.year, tanggal.month, tanggal.day);
    final b = DateTime.utc(hariIni.year, hariIni.month, hariIni.day);
    final selisih = a.difference(b).inDays;
    if (selisih == 0) return Str.hariIni;
    if (selisih == 1) return Str.besok;
    return '${Str.namaHari[tanggal.weekday - 1]}, ${tanggal.day} '
        '${Str.namaBulanPendek[tanggal.month - 1]}';
  }

  /// "Baru saja", "12 menit lalu", "3 jam lalu", "2 hari lalu".
  static String waktuRelatif(DateTime? waktu, DateTime sekarang) {
    if (waktu == null) return Str.tandaKosong;
    final selisih = sekarang.difference(waktu);
    if (selisih.inMinutes < 1) return Str.baruSaja;
    if (selisih.inHours < 1) return Str.menitLalu(selisih.inMinutes);
    if (selisih.inDays < 1) return Str.jamLalu(selisih.inHours);
    return Str.hariLalu(selisih.inDays);
  }

  /// Waktu lengkap di zona waktu perangkat, mis.
  /// "Jumat, 13 Nov 2026, 14:31:39 WIB".
  static String waktuLengkap(DateTime? utc) {
    if (utc == null) return Str.tandaKosong;
    final w = utc.toLocal();
    String dua(int n) => n.toString().padLeft(2, '0');
    return '${Str.namaHari[w.weekday - 1]}, ${w.day} '
        '${Str.namaBulanPendek[w.month - 1]} ${w.year}, '
        '${dua(w.hour)}:${dua(w.minute)}:${dua(w.second)} '
        '${zonaPerangkat(w.timeZoneOffset)}';
  }

  /// WIB/WITA/WIT bila cocok, selain itu "UTC+x".
  static String zonaPerangkat(Duration offset) {
    final kenal = Str.zonaWaktu[offset.inHours];
    if (kenal != null && offset.inMinutes % 60 == 0) return kenal;
    final tanda = offset.isNegative ? '-' : '+';
    final menit = offset.inMinutes.abs();
    final jam = menit ~/ 60;
    final sisa = menit % 60;
    return Str.zonaUtc(
      sisa == 0
          ? '$tanda$jam'
          : '$tanda$jam:${sisa.toString().padLeft(2, '0')}',
    );
  }

  /// Jarak dibulatkan: "8,4" (di bawah 10 km) atau "1.234".
  static String jarak(double km) {
    if (km < 10) return desimal((km * 10).round() / 10);
    final bulat = km.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < bulat.length; i++) {
      if (i > 0 && (bulat.length - i) % 3 == 0) buf.write('.');
      buf.write(bulat[i]);
    }
    return buf.toString();
  }

  /// "-5.56, 102.24" dari angka; tanda negatif = LS / BB.
  static String koordinat(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
}
