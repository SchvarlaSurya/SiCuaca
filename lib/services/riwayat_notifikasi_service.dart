import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/gempa.dart';

/// Satu notifikasi gempa yang pernah diterima perangkat.
class CatatanNotifikasi {
  const CatatanNotifikasi({required this.gempa, required this.diterima});

  final Gempa gempa;

  /// Saat aplikasi mencatatnya (waktu perangkat).
  final DateTime diterima;

  Map<String, dynamic> toJson() => {
    'gempa': gempa.toJson(),
    'diterima': diterima.toUtc().toIso8601String(),
  };

  static CatatanNotifikasi? dariJson(Object? json) {
    if (json is! Map) return null;
    final g = json['gempa'];
    final waktu = DateTime.tryParse('${json['diterima']}');
    if (g is! Map || waktu == null) return null;
    return CatatanNotifikasi(
      gempa: Gempa.fromJson(Map<String, dynamic>.from(g)),
      diterima: waktu.toLocal(),
    );
  }
}

/// Riwayat notifikasi gempa yang tersimpan di perangkat (maksimal 50,
/// terbaru di atas). Dicatat saat notifikasi tiba di depan, di latar
/// belakang, maupun saat diketuk; gempa yang sama tidak dicatat dua kali.
///
/// Dipakai juga dari isolate latar belakang FCM, jadi tidak bergantung pada
/// provider atau pohon widget. Semua operasi aman: kegagalan hanya dicatat
/// di log dan tidak melempar error.
class RiwayatNotifikasiService {
  static const int batas = 50;

  Future<SharedPreferences> _prefs({bool segarkan = false}) async {
    final prefs = await SharedPreferences.getInstance();
    // Isolate latar belakang menulis lewat instance lain: baca ulang dari disk.
    if (segarkan) await prefs.reload();
    return prefs;
  }

  Future<List<CatatanNotifikasi>> baca() async {
    try {
      final prefs = await _prefs(segarkan: true);
      final teks = prefs.getString(PrefsKeys.riwayatNotifikasi);
      if (teks == null) return const [];
      final isi = jsonDecode(teks);
      if (isi is! List) return const [];
      return [for (final item in isi) ?CatatanNotifikasi.dariJson(item)];
    } catch (e) {
      debugPrint('Riwayat notifikasi tidak terbaca: $e');
      return const [];
    }
  }

  /// Mencatat data FCM (`RemoteMessage.data`). Mengembalikan true bila
  /// dicatat; false bila bukan pesan gempa atau sudah ada.
  Future<bool> catat(Map<String, dynamic>? data, {DateTime? diterima}) async {
    final gempa = Gempa.dariPayload(data);
    if (gempa == null) return false;
    try {
      final daftar = await baca();
      if (daftar.any((c) => c.gempa.kunci == gempa.kunci)) return false;
      final baru = [
        CatatanNotifikasi(gempa: gempa, diterima: diterima ?? DateTime.now()),
        ...daftar,
      ].take(batas).toList();
      await (await _prefs()).setString(
        PrefsKeys.riwayatNotifikasi,
        jsonEncode([for (final c in baru) c.toJson()]),
      );
      return true;
    } catch (e) {
      debugPrint('Riwayat notifikasi gagal disimpan: $e');
      return false;
    }
  }

  Future<void> hapusSemua() async {
    try {
      await (await _prefs()).remove(PrefsKeys.riwayatNotifikasi);
    } catch (e) {
      debugPrint('Riwayat notifikasi gagal dihapus: $e');
    }
  }
}
