import 'package:intl/intl.dart';

import 'l10n.dart';

/// Pemformat angka dan waktu untuk tampilan, mengikuti bahasa aktif.
class Format {
  const Format._();

  static const String tandaKosong = '-';
  static const String satuanSuhu = '°C';

  /// Nama zona waktu Indonesia dipakai di kedua bahasa.
  static const Map<int, String> zonaWaktu = {7: 'WIB', 8: 'WITA', 9: 'WIT'};

  static String suhu(double? c) =>
      c == null ? tandaKosong : '${c.round()}$satuanSuhu';

  static String persen(int? n) => n == null ? tandaKosong : '$n%';

  /// Desimal satu angka: "5,5" (id) atau "5.5" (en); bilangan bulat tanpa
  /// desimal.
  static String desimal(AppLocalizations l, double? n) {
    if (n == null) return tandaKosong;
    return NumberFormat('#,##0.#', l.localeName).format(n);
  }

  static String angin(AppLocalizations l, double? kecepatan, String arah) {
    final k = desimal(l, kecepatan);
    return arah.isEmpty
        ? l.kecepatanAnginSaja(k)
        : l.kecepatanAngin(k, l.arahAngin(arah));
  }

  static String jam(DateTime? waktu) {
    if (waktu == null) return tandaKosong;
    String dua(int n) => n.toString().padLeft(2, '0');
    return '${dua(waktu.hour)}:${dua(waktu.minute)}';
  }

  /// WIB/WITA/WIT dari selisih terhadap UTC; kosong bila tidak dikenal.
  static String zona(Duration? selisih) =>
      selisih == null ? '' : zonaWaktu[selisih.inHours] ?? '';

  /// "Hari ini", "Besok", atau "Sabtu, 15 Nov" / "Saturday, 15 Nov".
  ///
  /// [tanggal] dan [hariIni] sama-sama jam dinding setempat.
  static String labelHari(
    AppLocalizations l,
    DateTime? tanggal,
    DateTime hariIni,
  ) {
    if (tanggal == null) return tandaKosong;
    final a = DateTime.utc(tanggal.year, tanggal.month, tanggal.day);
    final b = DateTime.utc(hariIni.year, hariIni.month, hariIni.day);
    final selisih = a.difference(b).inDays;
    if (selisih == 0) return l.hariIni;
    if (selisih == 1) return l.besok;
    return DateFormat('EEEE, d MMM', l.localeName).format(tanggal);
  }

  /// "Baru saja", "12 menit lalu" / "12 minutes ago", dst.
  static String waktuRelatif(
    AppLocalizations l,
    DateTime? waktu,
    DateTime sekarang,
  ) {
    if (waktu == null) return tandaKosong;
    final selisih = sekarang.difference(waktu);
    if (selisih.inMinutes < 1) return l.baruSaja;
    if (selisih.inHours < 1) return l.menitLalu(selisih.inMinutes);
    if (selisih.inDays < 1) return l.jamLalu(selisih.inHours);
    return l.hariLalu(selisih.inDays);
  }

  /// Waktu lengkap di zona waktu perangkat, mis.
  /// "Jumat, 13 Nov 2026, 14:31:39 WIB".
  static String waktuLengkap(AppLocalizations l, DateTime? utc) {
    if (utc == null) return tandaKosong;
    final w = utc.toLocal();
    final teks = DateFormat('EEEE, d MMM y, HH:mm:ss', l.localeName).format(w);
    return '$teks ${zonaPerangkat(w.timeZoneOffset)}';
  }

  /// Tanggal singkat + jam untuk label "Diperbarui", mis. "13 Nov, 14:05".
  static String waktuSingkat(AppLocalizations l, DateTime waktu) {
    final w = waktu.toLocal();
    return '${DateFormat('d MMM, HH:mm', l.localeName).format(w)} '
        '${zonaPerangkat(w.timeZoneOffset)}';
  }

  /// WIB/WITA/WIT bila cocok, selain itu "UTC+x".
  static String zonaPerangkat(Duration offset) {
    final kenal = zonaWaktu[offset.inHours];
    if (kenal != null && offset.inMinutes % 60 == 0) return kenal;
    final tanda = offset.isNegative ? '-' : '+';
    final menit = offset.inMinutes.abs();
    final jam = menit ~/ 60;
    final sisa = menit % 60;
    return sisa == 0
        ? 'UTC$tanda$jam'
        : 'UTC$tanda$jam:${sisa.toString().padLeft(2, '0')}';
  }

  /// Jarak dibulatkan: "8,4" (di bawah 10 km) atau "1.234" (id) /
  /// "8.4", "1,234" (en).
  static String jarak(AppLocalizations l, double km) {
    if (km < 10) return desimal(l, (km * 10).round() / 10);
    return NumberFormat('#,##0', l.localeName).format(km.round());
  }

  /// "-5.56, 102.24"; tanda negatif = LS / BB.
  static String koordinat(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
}
