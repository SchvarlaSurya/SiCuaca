/// Pembaca nilai JSON yang toleran: tipe berbeda atau null tidak membuat
/// crash, hasilnya null atau string kosong.
class Baca {
  const Baca._();

  static String teks(Object? value) => value?.toString().trim() ?? '';

  static String? teksAtauNull(Object? value) {
    final s = teks(value);
    return s.isEmpty ? null : s;
  }

  static double? angka(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  static int? bulat(Object? value) => angka(value)?.round();

  /// Map dengan kunci String, atau null bila bukan Map.
  static Map<String, dynamic>? peta(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static List<dynamic> daftar(Object? value) =>
      value is List ? value : const [];

  /// Tanggal tanpa zona waktu, mis. `2026-11-13 10:00:00`. Dibaca apa adanya
  /// (jam dinding setempat), bukan dikonversi ke zona perangkat.
  static DateTime? waktuSetempat(Object? value) {
    final s = teks(value);
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s.replaceFirst(' ', 'T'));
    if (dt == null) return null;
    return DateTime.utc(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }

  /// Tanggal ISO dengan zona (mis. `2026-11-13T03:00:00Z`), hasil dalam UTC.
  static DateTime? waktuUtc(Object? value) =>
      DateTime.tryParse(teks(value))?.toUtc();
}
