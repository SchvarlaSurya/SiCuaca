// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SiCuaca';

  @override
  String get sumberBmkg => 'Source: BMKG';

  @override
  String get cobaLagi => 'Try again';

  @override
  String get navBeranda => 'Home';

  @override
  String get navCuaca => 'Weather';

  @override
  String get navGempa => 'Earthquakes';

  @override
  String get navPeringatan => 'Alerts';

  @override
  String get navTentang => 'About';

  @override
  String get errTidakAdaInternet =>
      'No internet connection. Check your network and try again.';

  @override
  String get errTimeout =>
      'The BMKG server took too long to respond. Try again in a moment.';

  @override
  String errStatusHttp(String kode) {
    return 'The BMKG server returned HTTP status $kode.';
  }

  @override
  String get errDataTidakAda => 'BMKG has no weather data for this area yet.';

  @override
  String get errFormat => 'The data format from BMKG was not recognised.';

  @override
  String get errTakTerduga => 'Something went wrong while loading data.';

  @override
  String get modeOffline => 'Offline mode: showing saved data.';

  @override
  String diperbarui(String waktu) {
    return 'Updated: $waktu';
  }

  @override
  String get berandaJudul => 'Home';

  @override
  String get berandaKeterangan =>
      'Weather forecasts and earthquake information for Indonesia.';

  @override
  String get gempaTabTerbaru => 'Latest';

  @override
  String get gempaTabTerkini => 'M 5.0+';

  @override
  String get gempaTabDirasakan => 'Felt';

  @override
  String get gempaTerbaruJudul => 'Latest earthquake';

  @override
  String get gempaTerbaruKeterangan =>
      'The most recent earthquake recorded by BMKG.';

  @override
  String get gempaTerkiniKeterangan =>
      'The last 15 earthquakes of magnitude 5.0 or more.';

  @override
  String get gempaDirasakanKeterangan =>
      'The last 15 earthquakes felt by people.';

  @override
  String get memuatGempa => 'Loading earthquake data…';

  @override
  String get gempaKosong => 'No earthquake data yet.';

  @override
  String get gempaDetailJudul => 'Earthquake details';

  @override
  String get magnitudo => 'Magnitude';

  @override
  String get kedalaman => 'Depth';

  @override
  String get waktuKejadian => 'Time';

  @override
  String get koordinat => 'Coordinates';

  @override
  String get pusatGempa => 'Epicentre';

  @override
  String get potensi => 'Potential';

  @override
  String get dirasakanDi => 'Felt in';

  @override
  String get jarakDariAnda => 'Distance from you';

  @override
  String get shakemapJudul => 'Shake map';

  @override
  String get shakemapTidakTersedia =>
      'No shake map is available for this earthquake.';

  @override
  String get jarakAjak =>
      'Turn on location to see how far each earthquake is from you.';

  @override
  String jarakKm(String km) {
    return '± $km km from you';
  }

  @override
  String kedalamanSingkat(String nilai) {
    return 'Depth $nilai';
  }

  @override
  String get baruSaja => 'Just now';

  @override
  String menitLalu(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String jamLalu(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String hariLalu(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get cuacaSaatIni => 'Current weather';

  @override
  String get memuatCuaca => 'Loading weather forecast…';

  @override
  String get kelembapan => 'Humidity';

  @override
  String get angin => 'Wind';

  @override
  String get waktuSetempat => 'Local time';

  @override
  String get tidakAdaPrakiraan => 'No forecast data yet.';

  @override
  String pukul(String waktu) {
    return 'At $waktu';
  }

  @override
  String kecepatanAngin(String kecepatan, String arah) {
    return '$kecepatan km/h from the $arah';
  }

  @override
  String kecepatanAnginSaja(String kecepatan) {
    return '$kecepatan km/h';
  }

  @override
  String get hariIni => 'Today';

  @override
  String get besok => 'Tomorrow';

  @override
  String get arahN => 'north';

  @override
  String get arahNE => 'northeast';

  @override
  String get arahE => 'east';

  @override
  String get arahSE => 'southeast';

  @override
  String get arahS => 'south';

  @override
  String get arahSW => 'southwest';

  @override
  String get arahW => 'west';

  @override
  String get arahNW => 'northwest';

  @override
  String get pilihWilayahJudul => 'Choose an area';

  @override
  String get pilihWilayahKeterangan =>
      'Allow location access or search for a village to see the weather forecast.';

  @override
  String get gunakanLokasiSaya => 'Use my location';

  @override
  String get cariWilayah => 'Search area';

  @override
  String get gantiWilayah => 'Change area';

  @override
  String get mencariLokasi => 'Finding your location…';

  @override
  String get cariHint => 'Search village or district';

  @override
  String get cariMinimal => 'Type at least 3 letters.';

  @override
  String get cariTidakAdaHasil => 'No area found.';

  @override
  String get memuatDataWilayah => 'Loading area data…';

  @override
  String get gagalMemuatDataWilayah =>
      'Area data could not be loaded. Reinstall the app if this keeps happening.';

  @override
  String get favorit => 'Favourites';

  @override
  String get belumAdaFavorit =>
      'No favourite areas yet. Tap the star icon to save one.';

  @override
  String get tambahFavorit => 'Add to favourites';

  @override
  String get hapusFavorit => 'Remove from favourites';

  @override
  String get gpsLayananMati =>
      'Location services (GPS) are off. Turn them on and try again, or search for an area manually.';

  @override
  String get gpsDitolak =>
      'Location permission was denied. You can still search for an area manually.';

  @override
  String get gpsDitolakPermanen =>
      'Location permission is permanently denied. Enable it in app settings, or search for an area manually.';

  @override
  String get gpsGagal =>
      'Your location could not be determined. Please choose an area manually.';

  @override
  String get gpsDiluarWilayah =>
      'Your location does not match any village in Indonesia. Please choose an area manually.';

  @override
  String get bukaPengaturanAplikasi => 'Open app settings';

  @override
  String get bukaPengaturanLokasi => 'Open location settings';

  @override
  String get channelGempaNama => 'Earthquakes';

  @override
  String get channelGempaDeskripsi =>
      'New earthquake alerts above the magnitude you chose.';

  @override
  String get notifJudul => 'Earthquake notifications';

  @override
  String get notifKeterangan =>
      'Notify me about earthquakes with a magnitude of at least:';

  @override
  String get notifMati => 'Off';

  @override
  String get notifMatiKeterangan => 'Don\'t receive earthquake notifications';

  @override
  String get notifM4 => 'M 4.0 and above';

  @override
  String get notifM5 => 'M 5.0 and above';

  @override
  String get notifM6 => 'M 6.0 and above';

  @override
  String get notifM4Keterangan => 'Includes small earthquakes that are felt';

  @override
  String get notifM5Keterangan => 'Moderate to strong earthquakes';

  @override
  String get notifM6Keterangan => 'Strong earthquakes only';

  @override
  String get notifBelumAktif =>
      'Notifications are not available on this device: Firebase is not configured or the platform is not supported.';

  @override
  String get notifIzinDitolak =>
      'Notification permission was denied. Enable it in app settings so earthquake alerts can appear.';

  @override
  String get notifGagalLangganan =>
      'Notification settings could not be saved. Check your internet connection and try again.';

  @override
  String get notifSumber =>
      'Notifications are sent by the SiCuaca server based on the latest earthquake data. Source: BMKG';

  @override
  String get notifBahasaCatatan =>
      'Notification text is sent by the server in Indonesian.';

  @override
  String get peringatanDiniSegera => 'Severe weather warnings: coming soon';

  @override
  String get peringatanKeterangan =>
      'Early warnings for extreme weather in your area.';

  @override
  String get tentangKeterangan =>
      'Weather forecast and earthquake information app for Indonesia.';

  @override
  String get tentangSumber =>
      'Data source: BMKG (Indonesian Agency for Meteorology, Climatology, and Geophysics). SiCuaca is not an official BMKG app.';

  @override
  String get tentangDataWilayah =>
      'Area codes and coordinates: cahyadsn/wilayah and cahyadsn/wilayah_boundaries (MIT licence), following Ministry of Home Affairs Decree No 300.2.2-2430 of 2025.';

  @override
  String get tentangPengaturan => 'Settings';

  @override
  String get tentangKredit => 'Credits and data sources';

  @override
  String get tentangBahasa => 'Language';

  @override
  String get tentangTema => 'Theme';

  @override
  String get tentangVersi => 'App version';

  @override
  String versiAplikasi(String versi, String build) {
    return '$versi (build $build)';
  }

  @override
  String get ikutiSistem => 'System default';

  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';

  @override
  String get bahasaInggris => 'English';

  @override
  String get temaTerang => 'Light';

  @override
  String get temaGelap => 'Dark';

  @override
  String get lisensiSumberTerbuka => 'Open source licences';

  @override
  String get lisensiDataWilayah => 'Area data (cahyadsn)';

  @override
  String get selengkapnya => 'See more';

  @override
  String dataTerakhir(String waktu) {
    return 'Data last updated $waktu';
  }

  @override
  String get prakiraanPer3Jam => '3-hourly forecast';

  @override
  String get magKecil => 'Minor';

  @override
  String get magRingan => 'Light';

  @override
  String get magSedang => 'Moderate';

  @override
  String get magKuat => 'Strong';

  @override
  String get magBesar => 'Major';

  @override
  String get magTakDiketahui => 'Unknown';

  @override
  String magnitudoSemantik(String nilai, String tingkat) {
    return 'Magnitude $nilai, $tingkat';
  }
}
