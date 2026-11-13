/// Ambang magnitudo notifikasi gempa yang dipilih pengguna.
///
/// Setiap ambang = satu topic FCM. Backend mengirim secara kumulatif
/// (gempa M 5.5 ke gempa_m4 dan gempa_m5), jadi aplikasi cukup subscribe ke
/// SATU topic. Nama topic harus sama dengan config/sicuaca.php di backend.
enum AmbangGempa {
  mati(null),
  m4('gempa_m4'),
  m5('gempa_m5'),
  m6('gempa_m6');

  const AmbangGempa(this.topik);

  /// Topic FCM, atau null bila notifikasi dimatikan.
  final String? topik;

  static AmbangGempa dariNama(String? nama) => AmbangGempa.values.firstWhere(
    (a) => a.name == nama,
    orElse: () => AmbangGempa.mati,
  );
}
