import '../models/gempa.dart';
import 'format.dart';
import 'l10n.dart';

/// Ringkasan satu gempa untuk dibagikan atau disalin. Aman untuk data tidak
/// lengkap: baris yang datanya kosong dilewati (tidak ada "M ," kosong), dan
/// sumber BMKG serta penegasan "bukan aplikasi resmi" selalu ada.
///
/// [jarakKm] opsional (null bila posisi pengguna tidak diketahui).
String susunRingkasanGempa(
  AppLocalizations l,
  Gempa g, {
  double? jarakKm,
  DateTime? sekarang,
}) {
  String? isi(String label, String nilai) =>
      nilai.trim().isEmpty ? null : '$label: ${nilai.trim()}';

  final waktu = g.waktuUtc != null
      ? Format.waktuLengkap(l, g.waktuUtc)
      : '${g.tanggal} ${g.jam}'.trim();

  final baris = <String?>[
    l.bagikanGempaJudul,
    '',
    isi(l.magnitudo, g.magnitudo),
    isi(l.pusatGempa, g.wilayah),
    isi(l.waktuKejadian, waktu),
    isi(l.kedalaman, g.kedalaman),
    isi(l.potensi, g.potensi),
    isi(l.dirasakanDi, g.dirasakan),
    if (jarakKm != null) l.jarakKm(Format.jarak(l, jarakKm)),
    '',
    l.bagikanSumber,
    l.bukanResmi,
  ];
  return baris.whereType<String>().join('\n');
}
