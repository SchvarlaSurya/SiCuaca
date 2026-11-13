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
}
