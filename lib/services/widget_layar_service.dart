import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/prakiraan.dart';

/// Tempat menyimpan data untuk widget layar utama. Dipisah dari paket
/// `home_widget` supaya bisa diganti saat pengujian.
abstract class PenyimpanWidget {
  /// Menyimpan pasangan kunci-nilai untuk dibaca widget.
  Future<void> simpan(Map<String, String> data);

  /// Meminta widget menggambar ulang dari data tersimpan.
  Future<void> segarkan();
}

/// Penyimpan nyata (Android): SharedPreferences milik `home_widget` yang
/// dibaca `WidgetCuacaProvider` dan `PembaruWidgetWorker` di sisi native.
class PenyimpanWidgetAndroid implements PenyimpanWidget {
  const PenyimpanWidgetAndroid();

  /// Nama lengkap provider native (namespace aplikasi, bukan applicationId).
  static const namaProvider = 'com.example.app.WidgetCuacaProvider';

  @override
  Future<void> simpan(Map<String, String> data) async {
    for (final e in data.entries) {
      await HomeWidget.saveWidgetData<String>(e.key, e.value);
    }
  }

  @override
  Future<void> segarkan() async {
    await HomeWidget.updateWidget(qualifiedAndroidName: namaProvider);
  }
}

/// Tanpa widget (web, platform lain, atau pengujian): tidak melakukan apa-apa.
class PenyimpanWidgetDiam implements PenyimpanWidget {
  const PenyimpanWidgetDiam();

  @override
  Future<void> simpan(Map<String, String> data) async {}

  @override
  Future<void> segarkan() async {}
}

/// Penyimpan yang sesuai platform saat ini.
PenyimpanWidget penyimpanWidgetBawaan() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? const PenyimpanWidgetAndroid()
    : const PenyimpanWidgetDiam();

/// Menyusun dan mengirim data cuaca untuk widget layar utama.
///
/// Yang dikirim hanya data prakiraan BMKG yang memang sudah tampil di
/// aplikasi, tanpa lokasi tepat perangkat: nama wilayah, kode wilayah
/// (adm4), nilai cuaca, dan koordinat titik pusat WILAYAH (bukan GPS
/// perangkat; dua desimal). Kode adm4 dipakai pekerja latar belakang widget
/// untuk menyegarkan data dari BMKG tiap jam. Koordinat wilayah dipakai
/// menghitung indeks UV dan, dibulatkan ke 0,1 derajat, meminta kualitas
/// udara ke Open-Meteo.
abstract final class WidgetLayar {
  /// Isi yang dibaca widget. Semua nilai berupa teks; kosong = tidak ada.
  static Map<String, String> susun({
    required Prakiraan prakiraan,
    required EntriPrakiraan entri,
    required String bahasa,
    required DateTime diperbarui,
  }) {
    String angka(num? n) => n == null ? '' : n.round().toString();
    final lokasi = prakiraan.lokasi;
    final nama = [
      lokasi.desa,
      lokasi.kotkab,
    ].where((s) => s.isNotEmpty).join(', ');
    return {
      'ada_data': '1',
      'adm4': lokasi.adm4,
      'wilayah': nama,
      'suhu': angka(entri.suhu),
      'kelembapan': angka(entri.kelembapan),
      'angin': angka(entri.kecepatanAngin),
      'kondisi_id': entri.deskripsi,
      'kondisi_en': entri.deskripsiEn,
      'kode': entri.kodeCuaca?.toString() ?? '',
      'awan': entri.tutupanAwan?.toString() ?? '',
      'lat': lokasi.lat?.toStringAsFixed(2) ?? '',
      'lon': lokasi.lon?.toStringAsFixed(2) ?? '',
      'malam': entri.malam ? '1' : '0',
      'bahasa': bahasa,
      'diperbarui_ms': diperbarui.millisecondsSinceEpoch.toString(),
    };
  }

  /// Menyimpan [prakiraan] terbaru lalu menyegarkan widget. Tidak pernah
  /// melempar galat: widget tidak boleh mengganggu aplikasi.
  static Future<void> dorong(
    PenyimpanWidget penyimpan, {
    required Prakiraan prakiraan,
    required String bahasa,
    required DateTime diperbarui,
    DateTime? sekarang,
  }) async {
    try {
      final entri = prakiraan.entriTerdekat(
        (sekarang ?? DateTime.now()).toUtc(),
      );
      if (entri == null) return;
      await penyimpan.simpan(
        susun(
          prakiraan: prakiraan,
          entri: entri,
          bahasa: bahasa,
          diperbarui: diperbarui,
        ),
      );
      await penyimpan.segarkan();
    } catch (e) {
      debugPrint('Widget layar tidak diperbarui: $e');
    }
  }
}
