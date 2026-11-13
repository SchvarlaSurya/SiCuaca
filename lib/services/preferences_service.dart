import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/ambang_gempa.dart';
import '../models/lokasi.dart';

/// Penyimpanan lokal kecil: wilayah terakhir dan wilayah favorit.
/// Data rusak diabaikan, tidak membuat aplikasi crash.
class PreferencesService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Lokasi?> wilayahTerakhir() async {
    try {
      final teks = (await _prefs).getString(PrefsKeys.wilayahTerakhir);
      if (teks == null) return null;
      final json = jsonDecode(teks);
      if (json is! Map) return null;
      final lokasi = Lokasi.fromJson(Map<String, dynamic>.from(json));
      return lokasi.adm4.isEmpty ? null : lokasi;
    } catch (_) {
      return null;
    }
  }

  Future<void> simpanWilayahTerakhir(Lokasi lokasi) async {
    try {
      await (await _prefs).setString(
        PrefsKeys.wilayahTerakhir,
        jsonEncode(lokasi.toJson()),
      );
    } catch (_) {}
  }

  Future<List<Lokasi>> favorit() async {
    try {
      final daftar = (await _prefs).getStringList(PrefsKeys.wilayahFavorit);
      if (daftar == null) return [];
      final hasil = <Lokasi>[];
      for (final teks in daftar) {
        try {
          final json = jsonDecode(teks);
          if (json is! Map) continue;
          final lokasi = Lokasi.fromJson(Map<String, dynamic>.from(json));
          if (lokasi.adm4.isNotEmpty) hasil.add(lokasi);
        } catch (_) {
          // lewati entri rusak
        }
      }
      return hasil;
    } catch (_) {
      return [];
    }
  }

  Future<AmbangGempa> ambangGempa() async {
    try {
      final nama = (await _prefs).getString(PrefsKeys.ambangGempa);
      return AmbangGempa.dariNama(nama);
    } catch (_) {
      return AmbangGempa.mati;
    }
  }

  Future<void> simpanAmbangGempa(AmbangGempa ambang) async {
    try {
      await (await _prefs).setString(PrefsKeys.ambangGempa, ambang.name);
    } catch (_) {}
  }

  Future<void> simpanFavorit(List<Lokasi> daftar) async {
    try {
      await (await _prefs).setStringList(PrefsKeys.wilayahFavorit, [
        for (final l in daftar) jsonEncode(l.toJson()),
      ]);
    } catch (_) {}
  }
}
