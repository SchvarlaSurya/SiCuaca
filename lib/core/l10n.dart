import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../models/prakiraan.dart';
import '../providers/lokasi_provider.dart';
import 'exceptions.dart';

export '../l10n/app_localizations.dart';

/// Bahasa yang didukung; Indonesia default.
const List<Locale> bahasaDidukung = [Locale('id'), Locale('en')];

extension L10nKonteks on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension L10nTambahan on AppLocalizations {
  bool get inggris => localeName.startsWith('en');

  /// Sapaan menurut jam setempat wilayah (bukan jam perangkat):
  /// 04-10 pagi, 11-14 siang, 15-17 sore, selain itu malam.
  String sapaan(int jam, String lokasi) {
    if (jam >= 4 && jam < 11) return sapaPagi(lokasi);
    if (jam >= 11 && jam < 15) return sapaSiang(lokasi);
    if (jam >= 15 && jam < 18) return sapaSore(lokasi);
    return sapaMalam(lokasi);
  }

  /// Teks error untuk pengguna dari jenis [ApiException].
  String pesanGalat(Object? galat) {
    if (galat is! ApiException) return errTakTerduga;
    return switch (galat.type) {
      ApiErrorType.noInternet => errTidakAdaInternet,
      ApiErrorType.timeout => errTimeout,
      ApiErrorType.badStatus => errStatusHttp('${galat.statusCode ?? '-'}'),
      ApiErrorType.notFound => errDataTidakAda,
      ApiErrorType.badFormat => errFormat,
      ApiErrorType.unknown => errTakTerduga,
    };
  }

  /// Deskripsi cuaca sesuai bahasa: `weather_desc_en` dari BMKG untuk
  /// Inggris (bila ada), selain itu `weather_desc` asli.
  String deskripsiCuaca(EntriPrakiraan e) {
    if (!inggris) return e.deskripsi;
    if (e.deskripsiEn.isNotEmpty) return e.deskripsiEn;
    // Cadangan bila BMKG tidak mengirim weather_desc_en.
    return _cuacaInggris[e.deskripsi.trim().toLowerCase()] ?? e.deskripsi;
  }

  /// Teks kegagalan deteksi lokasi; null bila tidak ada masalah.
  String? pesanLokasi(StatusLokasi status) => switch (status) {
    StatusLokasi.layananMati => gpsLayananMati,
    StatusLokasi.ditolak => gpsDitolak,
    StatusLokasi.ditolakPermanen => gpsDitolakPermanen,
    StatusLokasi.gagal => gpsGagal,
    StatusLokasi.diluarWilayah => gpsDiluarWilayah,
    StatusLokasi.idle || StatusLokasi.mencari || StatusLokasi.berhasil => null,
  };

  /// Teks cuaca maritim BMKG (bahasa Indonesia) sesuai bahasa aplikasi.
  String cuacaTeks(String teksBmkg) {
    if (!inggris) return teksBmkg;
    return _cuacaInggris[teksBmkg.trim().toLowerCase()] ?? teksBmkg;
  }

  /// Nama arah BMKG dalam bahasa Indonesia ("Barat Laut") sesuai bahasa
  /// aplikasi. Nama tak dikenal dikembalikan apa adanya.
  String arahNama(String nama) {
    final kode = switch (nama.trim().toLowerCase()) {
      'utara' => 'N',
      'timur laut' => 'NE',
      'timur' => 'E',
      'tenggara' => 'SE',
      'selatan' => 'S',
      'barat daya' => 'SW',
      'barat' => 'W',
      'barat laut' => 'NW',
      _ => null,
    };
    return kode == null ? nama : arahAngin(kode);
  }

  /// Nama arah mata angin dari kode BMKG (N, NE, ...). Kode tak dikenal
  /// dikembalikan apa adanya.
  String arahAngin(String kode) => switch (kode.toUpperCase()) {
    'N' => arahN,
    'NE' => arahNE,
    'E' => arahE,
    'SE' => arahSE,
    'S' => arahS,
    'SW' => arahSW,
    'W' => arahW,
    'NW' => arahNW,
    _ => kode,
  };
}

/// Terjemahan deskripsi cuaca BMKG yang umum (cadangan saja).
const Map<String, String> _cuacaInggris = {
  'cerah': 'Sunny',
  'cerah berawan': 'Partly Cloudy',
  'berawan': 'Mostly Cloudy',
  'berawan tebal': 'Overcast',
  'udara kabur': 'Haze',
  'asap': 'Smoke',
  'kabut': 'Fog',
  'hujan ringan': 'Light Rain',
  'hujan sedang': 'Moderate Rain',
  'hujan lebat': 'Heavy Rain',
  'hujan lokal': 'Isolated Rain',
  'hujan petir': 'Thunderstorm',
  'petir': 'Thunderstorm',
};

/// Mencari [AppLocalizations] tanpa BuildContext (mis. nama channel
/// notifikasi sebelum runApp). Bahasa tak didukung jatuh ke Indonesia.
AppLocalizations l10nUntuk(Locale locale) => lookupAppLocalizations(
  locale.languageCode == 'en' ? const Locale('en') : const Locale('id'),
);
