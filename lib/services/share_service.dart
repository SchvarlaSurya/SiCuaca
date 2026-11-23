import 'package:share_plus/share_plus.dart';

import '../core/l10n.dart';

/// Layanan untuk membagikan informasi cuaca dan gempa bumi ke aplikasi lain
/// (WhatsApp, Telegram, media sosial, dll.) menggunakan SharePlus.
/// Teksnya mengikuti bahasa aplikasi.
abstract final class ShareService {
  /// Membagikan data cuaca terkini.
  static Future<void> bagikanCuaca(
    AppLocalizations l, {
    required String desa,
    required String induk,
    required String kondisi,
    required String suhu,
    required String kelembapan,
    required String angin,
  }) async {
    final lokasi = induk.isNotEmpty ? '$desa, $induk' : desa;
    final baris = <String>[
      l.bagikanCuacaJudul(lokasi),
      '',
      '🌡️ $suhu',
      '☁️ $kondisi',
      '💧 ${l.kelembapan}: $kelembapan',
      '🌬️ ${l.angin}: $angin',
      '',
      l.bagikanSumber,
    ];
    await SharePlus.instance.share(ShareParams(text: baris.join('\n')));
  }

  /// Membagikan data gempa bumi.
  static Future<void> bagikanGempa(
    AppLocalizations l, {
    required String magnitudo,
    required String wilayah,
    required String kedalaman,
    required String waktu,
    String? potensi,
    String? dirasakan,
    String? jarakDariAnda,
  }) async {
    final baris = <String>[
      l.bagikanGempaJudul,
      '',
      '📏 ${l.magnitudo}: $magnitudo',
      if (wilayah.isNotEmpty) '📍 ${l.pusatGempa}: $wilayah',
      if (waktu.isNotEmpty) '⏰ ${l.waktuKejadian}: $waktu',
      if (kedalaman.isNotEmpty) '🔽 ${l.kedalaman}: $kedalaman',
      if (potensi != null && potensi.isNotEmpty) '🌊 ${l.potensi}: $potensi',
      if (dirasakan != null && dirasakan.isNotEmpty)
        '👥 ${l.dirasakanDi}: $dirasakan',
      if (jarakDariAnda != null && jarakDariAnda.isNotEmpty)
        '📐 $jarakDariAnda',
      '',
      l.bagikanSumber,
    ];
    await SharePlus.instance.share(ShareParams(text: baris.join('\n')));
  }
}
