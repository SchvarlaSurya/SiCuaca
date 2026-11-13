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

/// Pilihan bahasa dan tema, tersimpan di perangkat.
class PengaturanProvider extends ChangeNotifier {
  PengaturanProvider(
    this._prefs, {
    this._bahasa = PilihanBahasa.sistem,
    this._tema = PilihanTema.sistem,
  });

  final PreferencesService _prefs;

  PilihanBahasa _bahasa;
  PilihanTema _tema;

  PilihanBahasa get bahasa => _bahasa;
  PilihanTema get tema => _tema;

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
    notifyListeners();
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
