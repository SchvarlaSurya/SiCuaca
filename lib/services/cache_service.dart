import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Satu isi cache: respons JSON mentah BMKG dan waktu pengambilannya.
class EntriCache {
  const EntriCache(this.json, this.diambil);

  final Map<String, dynamic> json;
  final DateTime diambil;
}

/// Cache offline sederhana di shared_preferences.
///
/// Menyimpan respons JSON mentah (bukan model) supaya parsing tetap satu
/// jalur dengan data dari jaringan. Ukurannya kecil: satu respons prakiraan
/// ±9 KB, tiap daftar gempa ±5 KB, dan prakiraan hanya disimpan untuk
/// wilayah aktif + favorit (lihat [pangkasPrakiraan]).
class CacheService {
  static const String kunciGempaTerbaru = 'gempa.terbaru';
  static const String kunciGempaTerkini = 'gempa.terkini';
  static const String kunciGempaDirasakan = 'gempa.dirasakan';
  static const String _awalanPrakiraan = 'prakiraan.';

  static String kunciPrakiraan(String adm4) => '$_awalanPrakiraan$adm4';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> simpan(
    String kunci,
    Map<String, dynamic> json, {
    DateTime? diambil,
  }) async {
    try {
      final isi = jsonEncode({
        'diambil': (diambil ?? DateTime.now()).toUtc().toIso8601String(),
        'json': json,
      });
      await (await _prefs).setString('${PrefsKeys.cache}$kunci', isi);
    } catch (_) {
      // Cache gagal ditulis tidak boleh mengganggu tampilan data.
    }
  }

  /// Null bila tidak ada atau isinya rusak.
  Future<EntriCache?> baca(String kunci) async {
    try {
      final teks = (await _prefs).getString('${PrefsKeys.cache}$kunci');
      if (teks == null) return null;
      final isi = jsonDecode(teks);
      if (isi is! Map) return null;
      final json = isi['json'];
      final diambil = DateTime.tryParse('${isi['diambil']}');
      if (json is! Map || diambil == null) return null;
      return EntriCache(Map<String, dynamic>.from(json), diambil);
    } catch (_) {
      return null;
    }
  }

  /// Hapus cache prakiraan selain wilayah [dipertahankan] (kode adm4).
  Future<void> pangkasPrakiraan(Set<String> dipertahankan) async {
    try {
      final prefs = await _prefs;
      final awalan = '${PrefsKeys.cache}$_awalanPrakiraan';
      for (final kunci in prefs.getKeys()) {
        if (!kunci.startsWith(awalan)) continue;
        if (!dipertahankan.contains(kunci.substring(awalan.length))) {
          await prefs.remove(kunci);
        }
      }
    } catch (_) {}
  }
}
