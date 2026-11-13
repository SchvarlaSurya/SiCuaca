import 'package:flutter/foundation.dart';

import '../models/lokasi.dart';
import '../services/preferences_service.dart';

/// Daftar wilayah favorit, tersimpan di perangkat.
class FavoritProvider extends ChangeNotifier {
  FavoritProvider(this._prefs);

  final PreferencesService _prefs;
  List<Lokasi> _daftar = const [];

  List<Lokasi> get daftar => _daftar;

  Future<void> muat() async {
    _daftar = List.unmodifiable(await _prefs.favorit());
    notifyListeners();
  }

  bool isFavorit(Lokasi lokasi) => _daftar.contains(lokasi);

  Future<void> toggle(Lokasi lokasi) async {
    _daftar = List.unmodifiable(
      isFavorit(lokasi)
          ? _daftar.where((l) => l != lokasi)
          : [..._daftar, lokasi],
    );
    notifyListeners();
    await _prefs.simpanFavorit(_daftar);
  }
}
