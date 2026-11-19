import 'package:share_plus/share_plus.dart';

/// Layanan untuk membagikan informasi cuaca dan gempa bumi ke aplikasi lain
/// (WhatsApp, Telegram, media sosial, dll.) menggunakan SharePlus.
abstract final class ShareService {
  /// Membagikan data cuaca terkini.
  static Future<void> bagikanCuaca({
    required String desa,
    required String induk,
    required String kondisi,
    required String suhu,
    required String kelembapan,
    required String angin,
  }) async {
    final lokasi = induk.isNotEmpty ? '$desa, $induk' : desa;
    final teks = '''
🌤️ Cuaca di $lokasi

🌡️ Suhu: $suhu
☁️ Kondisi: $kondisi
💧 Kelembapan: $kelembapan
🌬️ Angin: $angin

Sumber: BMKG · via SiCuaca''';

    await SharePlus.instance.share(ShareParams(text: teks.trim()));
  }

  /// Membagikan data gempa bumi.
  static Future<void> bagikanGempa({
    required String magnitudo,
    required String wilayah,
    required String kedalaman,
    required String waktu,
    String? potensi,
    String? dirasakan,
    String? jarakDariAnda,
  }) async {
    final baris = <String>[
      '⚠️ Info Gempa Bumi',
      '',
      '📏 Magnitudo: $magnitudo',
      if (wilayah.isNotEmpty) '📍 Pusat: $wilayah',
      if (waktu.isNotEmpty) '⏰ Waktu: $waktu',
      if (kedalaman.isNotEmpty) '🔽 Kedalaman: $kedalaman',
      if (potensi != null && potensi.isNotEmpty) '🌊 Potensi: $potensi',
      if (dirasakan != null && dirasakan.isNotEmpty) '👥 Dirasakan: $dirasakan',
      if (jarakDariAnda != null && jarakDariAnda.isNotEmpty) '📐 $jarakDariAnda',
      '',
      'Sumber: BMKG · via SiCuaca',
    ];

    await SharePlus.instance.share(ShareParams(text: baris.join('\n')));
  }
}
