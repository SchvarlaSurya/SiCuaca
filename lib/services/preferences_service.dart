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

  /// Nilai mentah pengaturan teks (bahasa, tema); null bila belum ada.
  Future<String?> bacaTeks(String kunci) async {
    try {
      return (await _prefs).getString(kunci);
    } catch (_) {
      return null;
    }
  }

  Future<void> simpanTeks(String kunci, String nilai) async {
    try {
      await (await _prefs).setString(kunci, nilai);
    } catch (_) {}
  }

  Future<void> simpanFavorit(List<Lokasi> daftar) async {
    try {
      await (await _prefs).setStringList(PrefsKeys.wilayahFavorit, [
        for (final l in daftar) jsonEncode(l.toJson()),
      ]);
    } catch (_) {}
  }

  /// Nama bagian Beranda sesuai urutan pilihan pengguna; null bila belum
  /// pernah diatur.
  Future<List<String>?> urutanBeranda() async {
    try {
      return (await _prefs).getStringList(PrefsKeys.urutanBeranda);
    } catch (_) {
      return null;
    }
  }

  Future<void> simpanUrutanBeranda(List<String> nama) async {
    try {
      await (await _prefs).setStringList(PrefsKeys.urutanBeranda, nama);
    } catch (_) {}
  }

  Future<void> hapusUrutanBeranda() async {
    try {
      await (await _prefs).remove(PrefsKeys.urutanBeranda);
    } catch (_) {}
  }

  /// Daftar teks di bawah [kunci]; null bila belum ada atau tidak terbaca.
  Future<List<String>?> bacaDaftar(String kunci) async {
    try {
      return (await _prefs).getStringList(kunci);
    } catch (_) {
      return null;
    }
  }

  Future<void> simpanDaftar(String kunci, List<String> nilai) async {
    try {
      await (await _prefs).setStringList(kunci, nilai);
    } catch (_) {}
  }

  Future<void> hapusKunci(String kunci) async {
    try {
      await (await _prefs).remove(kunci);
    } catch (_) {}
  }

  Future<bool> sudahOnboarding() async {
    try {
      return (await _prefs).getBool(PrefsKeys.sudahOnboarding) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setSudahOnboarding([bool sudah = true]) async {
    try {
      await (await _prefs).setBool(PrefsKeys.sudahOnboarding, sudah);
    } catch (_) {}
  }
}
