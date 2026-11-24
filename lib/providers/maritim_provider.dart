import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/maritim.dart';
import '../services/bmkg_repository.dart';
import '../services/maritim_repository.dart';
import '../services/preferences_service.dart';

enum StatusMaritim { awal, memuat, perluPilih, berhasil, gagal }

enum AsalPerairan { terdekat, pilihan }

/// Cuaca maritim untuk satu wilayah perairan: pilihan pengguna (tersimpan)
/// atau, bila belum memilih, perairan terdekat dari lokasi.
///
/// Tidak memuat apa pun sampai layar maritim dibuka ([muat]), supaya
/// aplikasi tidak memanggil API maritim tanpa perlu.
class MaritimProvider extends ChangeNotifier {
  MaritimProvider(
    this._repo,
    this._prefs, {
    required this._posisi,
    this._ubahPosisi,
  }) {
    _ubahPosisi?.addListener(_posisiBerubah);
  }

  final MaritimRepository _repo;
  final PreferencesService _prefs;
  final ({double lat, double lon})? Function() _posisi;
  final Listenable? _ubahPosisi;

  StatusMaritim _status = StatusMaritim.awal;
  DataBmkg<PrakiraanMaritim>? _data;
  Object? _galat;
  AsalPerairan? _asal;
  double? _jarakKm;
  String? _kode;
  String? _nama;

  List<AreaPerairan>? _daftar;
  Object? _galatDaftar;
  bool _memuatDaftar = false;

  StatusMaritim get status => _status;
  DataBmkg<PrakiraanMaritim>? get data => _data;
  Object? get galat => _galat;
  AsalPerairan? get asal => _asal;
  double? get jarakKm => _jarakKm;
  String? get kode => _kode;
  String? get nama => _nama;
  List<AreaPerairan>? get daftar => _daftar;
  Object? get galatDaftar => _galatDaftar;
  bool get memuatDaftar => _memuatDaftar;

  int _urutan = 0;

  void _posisiBerubah() {
    // Lokasi baru tersedia saat layar menunggu: cari perairan terdekat.
    if (_status == StatusMaritim.perluPilih && _posisi() != null) muat();
  }

  Future<void> muat() async {
    final ini = ++_urutan;
    _status = StatusMaritim.memuat;
    _galat = null;
    notifyListeners();
    try {
      final pilihan = _bacaPilihan(
        await _prefs.bacaTeks(PrefsKeys.maritimPerairan),
      );
      if (pilihan != null) {
        _kode = pilihan.id;
        _nama = pilihan.nama;
        _asal = AsalPerairan.pilihan;
        _jarakKm = null;
      } else {
        final p = _posisi();
        final dekat = p == null ? null : await _repo.terdekat(p.lat, p.lon);
        if (ini != _urutan) return;
        if (dekat == null) {
          _status = StatusMaritim.perluPilih;
          notifyListeners();
          return;
        }
        _kode = dekat.id;
        _nama = dekat.nama;
        _asal = AsalPerairan.terdekat;
        _jarakKm = dekat.jarakKm;
      }
      final hasil = await _repo.prakiraan(_kode!);
      if (ini != _urutan) return;
      _data = hasil;
      _nama = hasil.data.nama;
      _status = StatusMaritim.berhasil;
    } catch (e) {
      if (ini != _urutan) return;
      _galat = e;
      _status = StatusMaritim.gagal;
    }
    notifyListeners();
  }

  Future<void> pilih(AreaPerairan area) async {
    await _prefs.simpanTeks(
      PrefsKeys.maritimPerairan,
      '${area.id}|${area.nama}',
    );
    await muat();
  }

  Future<void> pakaiTerdekat() async {
    await _prefs.hapusKunci(PrefsKeys.maritimPerairan);
    await muat();
  }

  Future<void> muatDaftar() async {
    if (_memuatDaftar) return;
    _memuatDaftar = true;
    _galatDaftar = null;
    notifyListeners();
    try {
      _daftar = (await _repo.daftarPerairan()).data;
    } catch (e) {
      _galatDaftar = e;
    }
    _memuatDaftar = false;
    notifyListeners();
  }

  static ({String id, String nama})? _bacaPilihan(String? teks) {
    if (teks == null || teks.isEmpty) return null;
    final i = teks.indexOf('|');
    final id = (i < 0 ? teks : teks.substring(0, i)).trim();
    if (id.isEmpty) return null;
    final nama = i < 0 ? id : teks.substring(i + 1).trim();
    return (id: id, nama: nama.isEmpty ? id : nama);
  }

  /// Saring daftar perairan berdasarkan nama perairan atau provinsi.
  static List<AreaPerairan> saring(List<AreaPerairan> daftar, String kata) {
    final k = kata.trim().toLowerCase();
    if (k.isEmpty) return daftar;
    return [
      for (final a in daftar)
        if (a.nama.toLowerCase().contains(k) ||
            a.provinsi.toLowerCase().contains(k))
          a,
    ];
  }

  @override
  void dispose() {
    _ubahPosisi?.removeListener(_posisiBerubah);
    super.dispose();
  }
}
