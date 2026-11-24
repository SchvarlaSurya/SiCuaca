import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/preferences_service.dart';

enum PilihanBahasa {
  sistem(null),
  indonesia(Locale('id')),
  inggris(Locale('en'));

  const PilihanBahasa(this.locale);

  /// Null = ikuti bahasa sistem.
  final Locale? locale;
}

enum PilihanTema {
  sistem(ThemeMode.system),
  terang(ThemeMode.light),
  gelap(ThemeMode.dark);

  const PilihanTema(this.mode);

  final ThemeMode mode;
}

/// Bagian-bagian di Beranda yang urutannya bisa diatur pengguna.
enum SeksiBeranda { cuaca, gempa, peringatan }

/// Pilihan bahasa, tema, dan urutan bagian Beranda, tersimpan di perangkat.
class PengaturanProvider extends ChangeNotifier {
  PengaturanProvider(
    this._prefs, {
    this._bahasa = PilihanBahasa.sistem,
    this._tema = PilihanTema.sistem,
  });

  final PreferencesService _prefs;

  PilihanBahasa _bahasa;
  PilihanTema _tema;

  List<SeksiBeranda> _urutanBeranda = SeksiBeranda.values;

  PilihanBahasa get bahasa => _bahasa;
  PilihanTema get tema => _tema;

  /// Urutan bagian Beranda; selalu berisi semua bagian tepat sekali.
  List<SeksiBeranda> get urutanBeranda => _urutanBeranda;

  bool get urutanBerandaBawaan =>
      _urutanBeranda.indexed.every((e) => SeksiBeranda.values[e.$1] == e.$2);

  /// Mengubah nama tersimpan jadi urutan lengkap: nama tak dikenal dan
  /// duplikat dibuang, bagian yang hilang ditaruh di akhir (mis. setelah
  /// pembaruan aplikasi menambah bagian baru).
  static List<SeksiBeranda> normalkanUrutan(Iterable<String>? nama) {
    final hasil = <SeksiBeranda>[];
    for (final n in nama ?? const <String>[]) {
      final seksi = SeksiBeranda.values.where((s) => s.name == n);
      if (seksi.isNotEmpty && !hasil.contains(seksi.first)) {
        hasil.add(seksi.first);
      }
    }
    for (final s in SeksiBeranda.values) {
      if (!hasil.contains(s)) hasil.add(s);
    }
    return List.unmodifiable(hasil);
  }

  Future<void> muat() async {
    _bahasa = _dariNama(
      PilihanBahasa.values,
      await _prefs.bacaTeks(PrefsKeys.bahasa),
      PilihanBahasa.sistem,
    );
    _tema = _dariNama(
      PilihanTema.values,
      await _prefs.bacaTeks(PrefsKeys.tema),
      PilihanTema.sistem,
    );
    _urutanBeranda = normalkanUrutan(await _prefs.urutanBeranda());
    notifyListeners();
  }

  Future<void> aturUrutanBeranda(List<SeksiBeranda> urutan) async {
    _urutanBeranda = normalkanUrutan([for (final s in urutan) s.name]);
    notifyListeners();
    await _prefs.simpanUrutanBeranda([for (final s in _urutanBeranda) s.name]);
  }

  Future<void> setelUlangUrutanBeranda() async {
    _urutanBeranda = SeksiBeranda.values;
    notifyListeners();
    await _prefs.hapusUrutanBeranda();
  }

  Future<void> pilihBahasa(PilihanBahasa bahasa) async {
    if (bahasa == _bahasa) return;
    _bahasa = bahasa;
    notifyListeners();
    await _prefs.simpanTeks(PrefsKeys.bahasa, bahasa.name);
  }

  Future<void> pilihTema(PilihanTema tema) async {
    if (tema == _tema) return;
    _tema = tema;
    notifyListeners();
    await _prefs.simpanTeks(PrefsKeys.tema, tema.name);
  }

  static T _dariNama<T extends Enum>(List<T> nilai, String? nama, T bawaan) =>
      nilai.firstWhere((e) => e.name == nama, orElse: () => bawaan);
}
