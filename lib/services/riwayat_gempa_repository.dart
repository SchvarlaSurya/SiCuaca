import 'package:flutter/foundation.dart';

import '../models/gempa.dart';

/// Satu baris riwayat: gempa + catatan kapan masuk/diubah dan dari mana.
class BarisRiwayat {
  const BarisRiwayat({
    required this.gempa,
    required this.dicatat,
    required this.diperbarui,
    required this.sumber,
  });

  final Gempa gempa;

  /// Saat pertama kali masuk riwayat. Tidak berubah saat data direvisi.
  final DateTime dicatat;

  /// Saat terakhir isinya berubah (revisi magnitudo, kedalaman, dsb).
  final DateTime diperbarui;

  /// 'bmkg' (daftar BMKG), 'notifikasi', atau 'impor' (data lama).
  final String sumber;

  BarisRiwayat salinDengan({Gempa? gempa, DateTime? diperbarui}) =>
      BarisRiwayat(
        gempa: gempa ?? this.gempa,
        dicatat: dicatat,
        diperbarui: diperbarui ?? this.diperbarui,
        sumber: sumber,
      );
}

/// Penyimpanan baris riwayat. Hanya operasi dasar; semua aturan (kunci,
/// revisi, batas simpan) ada di [RiwayatGempaRepository] supaya bisa diuji
/// tanpa SQL.
abstract class RiwayatGempaStore {
  Future<BarisRiwayat?> ambil(String kunci);

  /// Menyimpan baru atau mengganti baris dengan [kunci] yang sama.
  Future<void> simpan(String kunci, BarisRiwayat baris);

  /// Semua baris, kejadian terbaru di atas.
  Future<List<BarisRiwayat>> semua();

  /// Menghapus baris yang kejadiannya sebelum [batas]; jumlah terhapus.
  Future<int> hapusSebelum(DateTime batas);

  /// Menyisakan [maks] baris dengan kejadian terbaru; jumlah terhapus.
  Future<int> hapusLebihDari(int maks);

  Future<void> hapusSemua();

  Future<String?> meta(String kunci);
  Future<void> setMeta(String kunci, String nilai);
}

/// Penyimpanan di memori: untuk web (tidak persisten) dan pengujian.
class MemoriRiwayatStore implements RiwayatGempaStore {
  final Map<String, BarisRiwayat> _baris = {};
  final Map<String, String> _meta = {};

  @override
  Future<BarisRiwayat?> ambil(String kunci) async => _baris[kunci];

  @override
  Future<void> simpan(String kunci, BarisRiwayat baris) async =>
      _baris[kunci] = baris;

  @override
  Future<List<BarisRiwayat>> semua() async => _urut(_baris.values.toList());

  List<BarisRiwayat> _urut(List<BarisRiwayat> daftar) =>
      daftar..sort((a, b) => b.gempa.waktuUtc!.compareTo(a.gempa.waktuUtc!));

  @override
  Future<int> hapusSebelum(DateTime batas) async {
    final hapus = [
      for (final e in _baris.entries)
        if (e.value.gempa.waktuUtc!.isBefore(batas)) e.key,
    ];
    hapus.forEach(_baris.remove);
    return hapus.length;
  }

  @override
  Future<int> hapusLebihDari(int maks) async {
    final urut = _urut(_baris.values.toList());
    if (urut.length <= maks) return 0;
    final simpan = urut.take(maks).toSet();
    final hapus = [
      for (final e in _baris.entries)
        if (!simpan.contains(e.value)) e.key,
    ];
    hapus.forEach(_baris.remove);
    return hapus.length;
  }

  @override
  Future<void> hapusSemua() async => _baris.clear();

  @override
  Future<String?> meta(String kunci) async => _meta[kunci];

  @override
  Future<void> setMeta(String kunci, String nilai) async =>
      _meta[kunci] = nilai;
}

/// Hasil satu kali pencatatan.
class HasilCatat {
  const HasilCatat({this.baru = 0, this.diperbarui = 0, this.diabaikan = 0});

  /// Gempa yang belum pernah ada, sekarang tersimpan.
  final int baru;

  /// Gempa yang sudah ada dan isinya berubah (mis. revisi magnitudo).
  final int diperbarui;

  /// Duplikat tanpa perubahan, terlalu lama, atau datanya tidak cukup.
  final int diabaikan;

  bool get adaPerubahan => baru > 0 || diperbarui > 0;
}

/// Riwayat gempa di perangkat ini. Hanya berisi gempa yang pernah dimuat
/// atau diterima aplikasi, jadi BUKAN catatan lengkap kejadian BMKG.
///
/// Aturan:
/// - Kunci = waktu kejadian (detik UTC) + koordinat (2 desimal). Gempa tanpa
///   waktu atau koordinat yang terbaca tidak disimpan.
/// - Kunci sama dengan isi berubah: baris di-UPDATE (bukan baris baru),
///   waktu "dicatat" tetap. Isi baru yang kosong tidak menimpa isi lama.
/// - Batas simpan: [maksHari] hari atau [maksBaris] baris, mana yang lebih
///   ketat.
/// - Tidak pernah melempar error ke pemanggil: kegagalan penyimpanan hanya
///   dicatat di log dan dianggap "tidak ada data".
///
/// Memberi tahu pendengar setiap kali isinya berubah.
class RiwayatGempaRepository extends ChangeNotifier {
  RiwayatGempaRepository(this._store, {DateTime Function()? sekarang})
    : _sekarang = sekarang ?? DateTime.now;

  static const int maksHari = 30;
  static const int maksBaris = 100;

  final RiwayatGempaStore _store;
  final DateTime Function() _sekarang;
  bool _dibuang = false;

  /// Kunci deduplikasi, atau null bila waktu/koordinat tidak terbaca.
  static String? kunciDari(Gempa g) {
    final waktu = g.waktuUtc;
    final lat = g.lat;
    final lon = g.lon;
    if (waktu == null || lat == null || lon == null) return null;
    final detik = waktu.toUtc().millisecondsSinceEpoch ~/ 1000;
    return '$detik|${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';
  }

  DateTime get _batasUsia =>
      _sekarang().toUtc().subtract(const Duration(days: maksHari));

  /// Mencatat [daftar]. Aman dipanggil berulang dengan data yang sama.
  Future<HasilCatat> catat(
    Iterable<Gempa> daftar, {
    String sumber = 'bmkg',
  }) async {
    try {
      final hasil = await _catat(daftar, sumber);
      if (hasil.adaPerubahan) _beritahu();
      return hasil;
    } catch (e) {
      debugPrint('Riwayat gempa gagal dicatat: $e');
      return const HasilCatat();
    }
  }

  Future<HasilCatat> _catat(Iterable<Gempa> daftar, String sumber) async {
    var baru = 0;
    var diperbarui = 0;
    var diabaikan = 0;
    final sekarang = _sekarang();
    final batas = _batasUsia;

    // Dalam satu kumpulan, entri terakhir untuk kunci yang sama yang dipakai.
    final unik = <String, Gempa>{};
    for (final g in daftar) {
      final kunci = kunciDari(g);
      if (kunci == null || g.waktuUtc!.isBefore(batas)) {
        diabaikan++;
        continue;
      }
      unik[kunci] = g;
    }

    for (final e in unik.entries) {
      final ada = await _store.ambil(e.key);
      if (ada == null) {
        await _store.simpan(
          e.key,
          BarisRiwayat(
            gempa: e.value,
            dicatat: sekarang,
            diperbarui: sekarang,
            sumber: sumber,
          ),
        );
        baru++;
        continue;
      }
      final gabungan = _gabung(ada.gempa, e.value);
      if (_sama(ada.gempa, gabungan)) {
        diabaikan++;
        continue;
      }
      await _store.simpan(
        e.key,
        ada.salinDengan(gempa: gabungan, diperbarui: sekarang),
      );
      diperbarui++;
    }

    if (baru > 0) await _store.hapusLebihDari(maksBaris);
    return HasilCatat(baru: baru, diperbarui: diperbarui, diabaikan: diabaikan);
  }

  /// Isi baru menang bila tidak kosong; yang kosong tidak menghapus isi lama
  /// (mis. notifikasi tanpa `dirasakan` tidak boleh menimpa data BMKG).
  static Gempa _gabung(Gempa lama, Gempa baru) {
    String pilih(String b, String l) => b.isNotEmpty ? b : l;
    return Gempa(
      tanggal: pilih(baru.tanggal, lama.tanggal),
      jam: pilih(baru.jam, lama.jam),
      koordinat: pilih(baru.koordinat, lama.koordinat),
      lintang: pilih(baru.lintang, lama.lintang),
      bujur: pilih(baru.bujur, lama.bujur),
      magnitudo: pilih(baru.magnitudo, lama.magnitudo),
      kedalaman: pilih(baru.kedalaman, lama.kedalaman),
      wilayah: pilih(baru.wilayah, lama.wilayah),
      potensi: pilih(baru.potensi, lama.potensi),
      dirasakan: pilih(baru.dirasakan, lama.dirasakan),
      shakemap: pilih(baru.shakemap, lama.shakemap),
      waktuUtc: lama.waktuUtc,
      lat: lama.lat,
      lon: lama.lon,
    );
  }

  static bool _sama(Gempa a, Gempa b) => mapEquals(a.toJson(), b.toJson());

  /// Semua baris riwayat, kejadian terbaru di atas. Kosong bila gagal.
  Future<List<BarisRiwayat>> baris() async {
    try {
      return await _store.semua();
    } catch (e) {
      debugPrint('Riwayat gempa gagal dibaca: $e');
      return const [];
    }
  }

  /// Seperti [baris] tetapi melempar error, untuk layar yang perlu
  /// menampilkan keadaan gagal dengan tombol coba lagi.
  Future<List<BarisRiwayat>> barisAtauGalat() => _store.semua();

  /// Pembersihan saat aplikasi dimulai: buang yang lebih tua dari
  /// [maksHari] hari, lalu sisakan [maksBaris] terbaru. Jumlah terhapus.
  Future<int> bersihkan() async {
    try {
      final a = await _store.hapusSebelum(_batasUsia);
      final b = await _store.hapusLebihDari(maksBaris);
      if (a + b > 0) _beritahu();
      return a + b;
    } catch (e) {
      debugPrint('Pembersihan riwayat gagal: $e');
      return 0;
    }
  }

  /// Memindahkan riwayat lama (versi shared_preferences) ke penyimpanan
  /// ini satu kali. Mengembalikan true bila sudah/berhasil dipindah, sehingga
  /// pemanggil boleh menghapus data lamanya. Bila gagal, data lama dibiarkan
  /// dan percobaan diulang pada pemuatan berikutnya.
  Future<bool> imporDariLama(Iterable<Gempa> lama) async {
    try {
      if (await _store.meta('impor_prefs') == '1') return true;
      await _catat(lama, 'impor');
      await _store.setMeta('impor_prefs', '1');
      _beritahu();
      return true;
    } catch (e) {
      debugPrint('Impor riwayat lama gagal: $e');
      return false;
    }
  }

  Future<void> hapusSemua() async {
    try {
      await _store.hapusSemua();
      _beritahu();
    } catch (e) {
      debugPrint('Riwayat gempa gagal dihapus: $e');
    }
  }

  void _beritahu() {
    if (!_dibuang) notifyListeners();
  }

  @override
  void dispose() {
    _dibuang = true;
    super.dispose();
  }
}
