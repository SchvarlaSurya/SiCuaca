import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../models/lokasi.dart';

/// Memuat dataset wilayah lokal (aset TSV) sekali, lalu melayani pencarian
/// nama dan pencarian desa terdekat dari koordinat GPS. Semua di memori,
/// tanpa API pihak ketiga.
class WilayahService {
  WilayahService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  Future<IndeksWilayah>? _muat;

  /// Aman dipanggil berkali-kali; berkas hanya dibaca sekali.
  Future<IndeksWilayah> muat() {
    return _muat ??= _bacaAset().catchError((Object e) {
      _muat = null; // izinkan percobaan ulang
      throw e;
    });
  }

  /// Mulai memuat di latar saat aplikasi dibuka, supaya pencarian pertama
  /// tidak menunggu. Kegagalan diabaikan di sini; [muat] akan mencoba lagi.
  void siapkan() {
    muat().then((_) {}, onError: (_) {});
  }

  Future<IndeksWilayah> _bacaAset() async {
    final teks = await _bundle.loadString(
      WilayahConstants.assetPath,
      cache: false,
    );
    // Parsing ±84 ribu baris dijalankan di isolate lain agar UI tidak macet.
    return compute(parseWilayah, teks);
  }
}

/// Hasil pemetaan koordinat ke desa terdekat.
class DesaTerdekat {
  const DesaTerdekat(this.lokasi, this.jarakKm);

  final Lokasi lokasi;
  final double jarakKm;
}

class IndeksWilayah {
  IndeksWilayah._(this._desa, this._namaDesa, this._namaKec, this._kunci);

  final List<Lokasi> _desa;
  final List<String> _namaDesa;
  final List<String> _namaKec;

  /// "desa kecamatan kabkota provinsi" yang sudah dinormalkan.
  final List<String> _kunci;

  int get jumlahDesa => _desa.length;

  /// Cari desa/kelurahan berdasarkan nama desa, kecamatan, kab/kota, atau
  /// provinsi. Semua kata pada [query] harus muncul. Hasil diurutkan:
  /// nama desa sama persis, diawali query, mengandung query, lalu sisanya.
  List<Lokasi> cari(
    String query, {
    int batas = WilayahConstants.batasHasilCari,
  }) {
    final q = normalkan(query);
    if (q.length < WilayahConstants.minimalHurufCari) return const [];
    final kata = q.split(' ');

    final cocok = <(int, int)>[]; // (skor, indeks)
    for (var i = 0; i < _kunci.length; i++) {
      final kunci = _kunci[i];
      if (!kata.every(kunci.contains)) continue;
      final desa = _namaDesa[i];
      final int skor;
      if (desa == q) {
        skor = 0;
      } else if (desa.startsWith(q)) {
        skor = 1;
      } else if (desa.contains(q)) {
        skor = 2;
      } else if (_namaKec[i].startsWith(q)) {
        skor = 3;
      } else {
        skor = 4;
      }
      cocok.add((skor, i));
    }

    cocok.sort((a, b) {
      final s = a.$1.compareTo(b.$1);
      if (s != 0) return s;
      return _namaDesa[a.$2].length.compareTo(_namaDesa[b.$2].length);
    });
    return [for (final c in cocok.take(batas)) _desa[c.$2]];
  }

  /// Desa yang titik tengahnya paling dekat dengan koordinat.
  DesaTerdekat? terdekat(double lat, double lon) {
    final cosLat = math.cos(lat * math.pi / 180);
    Lokasi? terbaik;
    var jarakTerbaik = double.infinity;
    for (final d in _desa) {
      final dLat = d.lat;
      final dLon = d.lon;
      if (dLat == null || dLon == null) continue;
      final dy = dLat - lat;
      final dx = (dLon - lon) * cosLat;
      final jarak = dx * dx + dy * dy;
      if (jarak < jarakTerbaik) {
        jarakTerbaik = jarak;
        terbaik = d;
      }
    }
    if (terbaik == null) return null;
    return DesaTerdekat(terbaik, math.sqrt(jarakTerbaik) * 111.32);
  }

  static String normalkan(String s) => s
      .toLowerCase()
      .replaceAll("'", '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

/// Membaca TSV dari `tool/build_wilayah.py`. Fungsi tingkat atas agar bisa
/// dijalankan lewat [compute].
IndeksWilayah parseWilayah(String tsv) {
  final induk = <String, String>{};
  final desa = <Lokasi>[];
  final namaDesa = <String>[];
  final namaKec = <String>[];
  final kunci = <String>[];

  for (final mentah in tsv.split('\n')) {
    // Toleran terhadap CRLF bila berkas sempat diubah oleh editor/git.
    final baris = mentah.endsWith('\r')
        ? mentah.substring(0, mentah.length - 1)
        : mentah;
    if (baris.isEmpty) continue;
    final kolom = baris.split('\t');
    if (kolom.length < 2) continue;
    final kode = kolom[0];

    if (kode.length != 13) {
      induk[kode] = kolom[1];
      continue;
    }

    // Baris induk (prov, kab, kec) selalu muncul sebelum desanya karena
    // berkas diurutkan menurut kode.
    final lokasi = Lokasi(
      adm4: kode,
      desa: kolom[1],
      kecamatan: induk[kode.substring(0, 8)] ?? '',
      kotkab: induk[kode.substring(0, 5)] ?? '',
      provinsi: induk[kode.substring(0, 2)] ?? '',
      lat: kolom.length > 2 ? double.tryParse(kolom[2]) : null,
      lon: kolom.length > 3 ? double.tryParse(kolom[3]) : null,
    );
    final nDesa = IndeksWilayah.normalkan(lokasi.desa);
    final nKec = IndeksWilayah.normalkan(lokasi.kecamatan);
    desa.add(lokasi);
    namaDesa.add(nDesa);
    namaKec.add(nKec);
    kunci.add(
      '$nDesa $nKec ${IndeksWilayah.normalkan(lokasi.kotkab)} '
      '${IndeksWilayah.normalkan(lokasi.provinsi)}',
    );
  }
  return IndeksWilayah._(desa, namaDesa, namaKec, kunci);
}
