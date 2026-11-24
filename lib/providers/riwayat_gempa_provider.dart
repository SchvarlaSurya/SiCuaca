import 'package:flutter/foundation.dart';

import '../core/geo.dart';
import '../models/gempa.dart';
import '../services/riwayat_gempa_repository.dart';

/// Saringan riwayat. Semua opsional; kosong = tidak menyaring.
@immutable
class FilterRiwayat {
  const FilterRiwayat({
    this.mulai,
    this.selesai,
    this.magnitudoMin,
    this.jarakMaksKm,
    this.kataKunci = '',
  });

  /// Rentang tanggal kejadian (tanggal lokal perangkat, keduanya ikut).
  final DateTime? mulai;
  final DateTime? selesai;

  /// Magnitudo paling kecil yang ditampilkan.
  final double? magnitudoMin;

  /// Jarak paling jauh dari posisi pengguna, km. Diabaikan bila posisi
  /// pengguna tidak tersedia.
  final double? jarakMaksKm;

  /// Potongan nama wilayah.
  final String kataKunci;

  bool get rentangTanggal => mulai != null || selesai != null;

  bool get aktif =>
      rentangTanggal ||
      magnitudoMin != null ||
      jarakMaksKm != null ||
      kataKunci.trim().isNotEmpty;

  /// Jumlah saringan di luar kata kunci (untuk penanda di tombol filter).
  int get jumlahSaringan =>
      (rentangTanggal ? 1 : 0) +
      (magnitudoMin != null ? 1 : 0) +
      (jarakMaksKm != null ? 1 : 0);

  FilterRiwayat tanpa({
    bool tanggal = false,
    bool magnitudo = false,
    bool jarak = false,
  }) => FilterRiwayat(
    mulai: tanggal ? null : mulai,
    selesai: tanggal ? null : selesai,
    magnitudoMin: magnitudo ? null : magnitudoMin,
    jarakMaksKm: jarak ? null : jarakMaksKm,
    kataKunci: kataKunci,
  );

  FilterRiwayat denganKataKunci(String kata) => FilterRiwayat(
    mulai: mulai,
    selesai: selesai,
    magnitudoMin: magnitudoMin,
    jarakMaksKm: jarakMaksKm,
    kataKunci: kata,
  );

  @override
  bool operator ==(Object other) =>
      other is FilterRiwayat &&
      other.mulai == mulai &&
      other.selesai == selesai &&
      other.magnitudoMin == magnitudoMin &&
      other.jarakMaksKm == jarakMaksKm &&
      other.kataKunci == kataKunci;

  @override
  int get hashCode =>
      Object.hash(mulai, selesai, magnitudoMin, jarakMaksKm, kataKunci);
}

/// Ringkasan angka dari hasil saringan.
@immutable
class StatistikRiwayat {
  const StatistikRiwayat({
    required this.jumlah,
    this.terbesar,
    this.terdekat,
    this.jarakTerdekatKm,
    required this.adaLokasi,
  });

  /// Jumlah gempa pada hasil saringan.
  final int jumlah;

  /// Gempa dengan magnitudo terbesar; null bila daftar kosong.
  final Gempa? terbesar;

  /// Gempa terdekat dengan pengguna; null bila daftar kosong atau posisi
  /// pengguna tidak tersedia.
  final Gempa? terdekat;
  final double? jarakTerdekatKm;

  /// False bila posisi pengguna belum diketahui (jarak tidak bisa dihitung).
  final bool adaLokasi;
}

/// Rentang tanggal data yang benar-benar tersimpan.
@immutable
class RentangData {
  const RentangData(this.tertua, this.terbaru);
  final DateTime tertua;
  final DateTime terbaru;
}

enum StatusRiwayat { memuat, siap, gagal }

typedef PosisiPengguna = ({double lat, double lon})?;

/// Riwayat gempa untuk layar: memuat dari [RiwayatGempaRepository],
/// menyaring, dan menghitung statistik.
///
/// PENTING: riwayat hanya berisi gempa yang pernah dimuat/diterima di
/// perangkat ini (BMKG hanya memberi daftar pendek), sehingga semua angka di
/// sini adalah "dari data yang tersimpan di perangkat ini", bukan statistik
/// kejadian gempa yang lengkap.
class RiwayatGempaProvider extends ChangeNotifier {
  RiwayatGempaProvider(this._repo, {required this._posisi, this._ubahPosisi}) {
    _repo.addListener(_dataBerubah);
    _ubahPosisi?.addListener(_posisiBerubah);
  }

  final RiwayatGempaRepository _repo;
  final PosisiPengguna Function() _posisi;
  final Listenable? _ubahPosisi;
  bool _dibuang = false;

  StatusRiwayat _status = StatusRiwayat.memuat;
  List<BarisRiwayat> _semua = const [];
  FilterRiwayat _filter = const FilterRiwayat();
  List<BarisRiwayat> _hasil = const [];
  StatistikRiwayat _statistik = const StatistikRiwayat(
    jumlah: 0,
    adaLokasi: false,
  );

  StatusRiwayat get status => _status;

  /// Semua baris yang tersimpan (tanpa saringan).
  List<BarisRiwayat> get semua => _semua;
  FilterRiwayat get filter => _filter;

  /// Baris yang lolos saringan, kejadian terbaru di atas.
  List<BarisRiwayat> get hasil => _hasil;
  StatistikRiwayat get statistik => _statistik;

  /// Jumlah seluruh data tersimpan (sebelum disaring).
  int get jumlahTersimpan => _semua.length;

  /// Data tertua dan terbaru yang benar-benar ada; null bila kosong.
  RentangData? get rentangData => rentangDari(_semua);

  /// True bila jarak bisa dihitung (posisi pengguna diketahui).
  bool get adaLokasi => _posisi() != null;

  double? jarakKm(Gempa g) => jarakDari(_posisi(), g);

  /// Memuat ulang dari penyimpanan. [sunyi] = tanpa menampilkan keadaan
  /// "memuat" (dipakai saat data berubah di latar).
  Future<void> muat({bool sunyi = false}) async {
    if (!sunyi) {
      _status = StatusRiwayat.memuat;
      _beritahu();
    }
    try {
      _semua = await _repo.barisAtauGalat();
      _status = StatusRiwayat.siap;
    } catch (e) {
      debugPrint('Riwayat gempa gagal dimuat: $e');
      _status = StatusRiwayat.gagal;
    }
    _hitungUlang();
    _beritahu();
  }

  void aturFilter(FilterRiwayat baru) {
    if (baru == _filter) return;
    _filter = baru;
    _hitungUlang();
    _beritahu();
  }

  void setelUlangFilter() => aturFilter(const FilterRiwayat());

  void _dataBerubah() {
    muat(sunyi: true);
  }

  void _posisiBerubah() {
    _hitungUlang();
    _beritahu();
  }

  void _hitungUlang() {
    final posisi = _posisi();
    _hasil = saring(_semua, _filter, posisi);
    _statistik = hitung(_hasil, posisi);
  }

  // ---- Fungsi murni (diuji langsung) -------------------------------------

  static double? jarakDari(PosisiPengguna posisi, Gempa g) {
    final lat = g.lat;
    final lon = g.lon;
    if (posisi == null || lat == null || lon == null) return null;
    return jarakKmAntara(posisi.lat, posisi.lon, lat, lon);
  }

  /// Menyaring [baris] dengan [filter]. Saringan jarak diabaikan bila
  /// [posisi] tidak diketahui. Urutan terbaru di atas dipertahankan.
  static List<BarisRiwayat> saring(
    List<BarisRiwayat> baris,
    FilterRiwayat filter,
    PosisiPengguna posisi,
  ) {
    final kata = filter.kataKunci.trim().toLowerCase();
    DateTime? hari(DateTime? t) =>
        t == null ? null : DateTime(t.year, t.month, t.day);
    final mulai = hari(filter.mulai);
    final selesai = hari(filter.selesai);

    return [
      for (final b in baris)
        if (_lolos(b.gempa, filter, kata, mulai, selesai, posisi)) b,
    ];
  }

  static bool _lolos(
    Gempa g,
    FilterRiwayat f,
    String kata,
    DateTime? mulai,
    DateTime? selesai,
    PosisiPengguna posisi,
  ) {
    if (kata.isNotEmpty && !g.wilayah.toLowerCase().contains(kata)) {
      return false;
    }
    final min = f.magnitudoMin;
    if (min != null) {
      final m = g.magnitudoAngka;
      if (m == null || m < min) return false;
    }
    if (mulai != null || selesai != null) {
      final w = g.waktuUtc?.toLocal();
      if (w == null) return false;
      final tgl = DateTime(w.year, w.month, w.day);
      if (mulai != null && tgl.isBefore(mulai)) return false;
      if (selesai != null && tgl.isAfter(selesai)) return false;
    }
    final maks = f.jarakMaksKm;
    if (maks != null && posisi != null) {
      final j = jarakDari(posisi, g);
      if (j == null || j > maks) return false;
    }
    return true;
  }

  /// Statistik dari [hasil]: jumlah, magnitudo terbesar, gempa terdekat.
  static StatistikRiwayat hitung(
    List<BarisRiwayat> hasil,
    PosisiPengguna posisi,
  ) {
    Gempa? terbesar;
    double? mTerbesar;
    Gempa? terdekat;
    double? jTerdekat;
    for (final b in hasil) {
      final g = b.gempa;
      final m = g.magnitudoAngka;
      if (m != null && (mTerbesar == null || m > mTerbesar)) {
        mTerbesar = m;
        terbesar = g;
      }
      final j = jarakDari(posisi, g);
      if (j != null && (jTerdekat == null || j < jTerdekat)) {
        jTerdekat = j;
        terdekat = g;
      }
    }
    return StatistikRiwayat(
      jumlah: hasil.length,
      terbesar: terbesar,
      terdekat: terdekat,
      jarakTerdekatKm: jTerdekat,
      adaLokasi: posisi != null,
    );
  }

  static RentangData? rentangDari(List<BarisRiwayat> baris) {
    DateTime? tertua;
    DateTime? terbaru;
    for (final b in baris) {
      final w = b.gempa.waktuUtc;
      if (w == null) continue;
      if (tertua == null || w.isBefore(tertua)) tertua = w;
      if (terbaru == null || w.isAfter(terbaru)) terbaru = w;
    }
    if (tertua == null || terbaru == null) return null;
    return RentangData(tertua.toLocal(), terbaru.toLocal());
  }

  void _beritahu() {
    if (!_dibuang) notifyListeners();
  }

  @override
  void dispose() {
    _dibuang = true;
    _repo.removeListener(_dataBerubah);
    _ubahPosisi?.removeListener(_posisiBerubah);
    super.dispose();
  }
}
