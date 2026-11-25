import '../models/prakiraan.dart';

/// Ringkasan satu hari dari prakiraan 3-jam BMKG.
class RingkasHari {
  const RingkasHari({
    required this.tanggal,
    required this.wakil,
    required this.tertinggi,
    required this.terendah,
  });

  /// Jam dinding setempat (tanggal saja yang dipakai).
  final DateTime tanggal;

  /// Entri yang mewakili kondisi hari itu: yang paling dekat pukul 12.00
  /// setempat (siang), agar ikonnya menggambarkan siang hari.
  final EntriPrakiraan wakil;
  final double? tertinggi;
  final double? terendah;
}

/// Satu ringkasan per hari prakiraan (urutan sama dengan BMKG). Hari tanpa
/// waktu setempat dilewati. Suhu tertinggi/terendah dari semua entri hari
/// itu; null bila tidak ada suhu sama sekali.
List<RingkasHari> ringkasHarian(Prakiraan prakiraan) {
  final hasil = <RingkasHari>[];
  for (final hari in prakiraan.hari) {
    final berwaktu = hari.where((e) => e.waktuLokal != null).toList();
    if (berwaktu.isEmpty) continue;
    var wakil = berwaktu.first;
    var selisihTerbaik = 1 << 30;
    for (final e in berwaktu) {
      final w = e.waktuLokal!;
      final selisih = ((w.hour * 60 + w.minute) - 12 * 60).abs();
      if (selisih < selisihTerbaik) {
        selisihTerbaik = selisih;
        wakil = e;
      }
    }
    final suhu = [
      for (final e in hari)
        if (e.suhu != null) e.suhu!,
    ];
    hasil.add(
      RingkasHari(
        tanggal: berwaktu.first.waktuLokal!,
        wakil: wakil,
        tertinggi: suhu.isEmpty ? null : suhu.reduce((a, b) => a > b ? a : b),
        terendah: suhu.isEmpty ? null : suhu.reduce((a, b) => a < b ? a : b),
      ),
    );
  }
  return hasil;
}
