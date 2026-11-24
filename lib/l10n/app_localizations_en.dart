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
  String get errDataTidakAda => 'Data is not available for this location.';

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

  @override
  String get navPengaturan => 'Settings';

  @override
  String get pengaturanTampilan => 'Display';

  @override
  String get tentangJudul => 'About SiCuaca';

  @override
  String get dataTidakTersedia => 'Data is not available for this location.';

  @override
  String get pilihDariDaftar => 'Browse regions';

  @override
  String get pilihDariDaftarKeterangan =>
      'Province, regency/city, district, then village';

  @override
  String get pilihProvinsi => 'Choose province';

  @override
  String get pilihKabKota => 'Choose regency/city';

  @override
  String get pilihKecamatan => 'Choose district';

  @override
  String get pilihDesa => 'Choose village';

  @override
  String get saringDaftar => 'Filter list';

  @override
  String get semuaWilayah => 'Indonesia';

  @override
  String get riwayatJudul => 'Earthquake History';

  @override
  String get riwayatKosong =>
      'No earthquake history yet. Load earthquake data first.';

  @override
  String riwayatJumlah(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events shown',
      one: '1 event shown',
    );
    return '$_temp0';
  }

  @override
  String get riwayatTidakCocok => 'No data matches the filter.';

  @override
  String get semuaMagnitudo => 'All magnitudes';

  @override
  String get dalam100Km => 'Within 100 km';

  @override
  String get statTerbesar => 'Largest';

  @override
  String get statTerdekat => 'Nearest';

  @override
  String get statTotal => 'Total';

  @override
  String get siagaJudul => 'Earthquake Preparedness';

  @override
  String get siagaSebelum => 'Before an earthquake';

  @override
  String get siagaSebelum1 => 'Know the evacuation routes and assembly points.';

  @override
  String get siagaSebelum2 => 'Secure heavy objects so they cannot fall.';

  @override
  String get siagaSebelum3 =>
      'Prepare an emergency bag and save emergency numbers.';

  @override
  String get siagaSaat => 'During an earthquake';

  @override
  String get siagaSaat1 => 'Drop, cover your head, and hold on.';

  @override
  String get siagaSaat2 =>
      'Stay away from glass, cabinets, and objects that can fall.';

  @override
  String get siagaSaat3 => 'Do not use the lift.';

  @override
  String get siagaSetelah => 'After an earthquake';

  @override
  String get siagaSetelah1 => 'Leave calmly once the shaking stops.';

  @override
  String get siagaSetelah2 => 'Check yourself and the people around you.';

  @override
  String get siagaSetelah3 =>
      'If you are near the coast and the shaking was strong, move to high ground at once.';

  @override
  String tasSiagaJudul(String selesai, String total) {
    return 'Emergency bag checklist ($selesai/$total)';
  }

  @override
  String get tas1 => 'Drinking water';

  @override
  String get tas2 => 'Long-lasting food';

  @override
  String get tas3 => 'Torch and batteries';

  @override
  String get tas4 => 'First aid kit and personal medicine';

  @override
  String get tas5 => 'Important documents';

  @override
  String get tas6 => 'Whistle';

  @override
  String get tas7 => 'Face mask';

  @override
  String get tas8 => 'Power bank';

  @override
  String get siagaCatatan =>
      'This guide is for education. Follow official instructions from the government and BMKG during an emergency.';

  @override
  String get salinRingkasan => 'Copy summary';

  @override
  String get ringkasanDisalin => 'Summary copied to the clipboard.';

  @override
  String ringkasanGempa(
    String magnitudo,
    String wilayah,
    String waktu,
    String kedalaman,
  ) {
    return 'M $magnitudo earthquake at $wilayah, $waktu. Depth $kedalaman. Source: BMKG.';
  }

  @override
  String get bagikan => 'Share';

  @override
  String get bagikanCuaca => 'Share weather info';

  @override
  String get bagikanGempa => 'Share earthquake info';

  @override
  String get onboardingLewati => 'Skip';

  @override
  String get onboardingLanjut => 'Next';

  @override
  String get onboardingMulai => 'Get started';

  @override
  String get onboardingCuacaJudul => 'Accurate Weather Forecast';

  @override
  String get onboardingCuacaDeskripsi =>
      'Track current weather and 3-hourly forecasts for every village and district in Indonesia directly from BMKG.';

  @override
  String get onboardingGempaJudul => 'Earthquake Info & Alerts';

  @override
  String get onboardingGempaDeskripsi =>
      'Stay updated on recent earthquakes, magnitude, distance from you, and get automatic alerts when earthquakes strike.';

  @override
  String get onboardingWilayahJudul => 'Easy Region Search';

  @override
  String get onboardingWilayahDeskripsi =>
      'Use GPS to instantly detect your location or browse over 80,000 villages across Indonesia.';

  @override
  String get panduanAplikasi => 'App introduction';

  @override
  String get panduanAplikasiKeterangan =>
      'Revisit the introductory feature slides';

  @override
  String bagikanCuacaJudul(String lokasi) {
    return '🌤️ Weather in $lokasi';
  }

  @override
  String get bagikanGempaJudul => '⚠️ Earthquake info';

  @override
  String get bagikanSumber => 'Source: BMKG · via SiCuaca';

  @override
  String get subjudulBeranda => 'Weather and earthquakes for today';

  @override
  String get subjudulCuaca => 'Local forecast from BMKG';

  @override
  String get subjudulGempa => 'Latest seismic information';

  @override
  String get subjudulPeringatan => 'Set up the notifications you need';

  @override
  String get subjudulPengaturan => 'Customise your SiCuaca experience';

  @override
  String get bandingkanFavorit => 'Compare favourites';

  @override
  String get bandingkanJudul => 'Compare weather';

  @override
  String bandingkanKeterangan(String n) {
    return 'Comparing $n of up to 3 favourite regions.';
  }

  @override
  String get kartuCuaca => 'Weather card';

  @override
  String get bukanResmi => 'SiCuaca is not an official BMKG app.';

  @override
  String ringkasanCuaca(
    String lokasi,
    String kondisi,
    String suhu,
    String catatan,
  ) {
    return 'Weather in $lokasi: $kondisi, $suhu. ${catatan}Source: BMKG. SiCuaca is not an official BMKG app.';
  }

  @override
  String get bagikanKartuCuaca => 'Share weather card';

  @override
  String get salinRingkasanTeks => 'Copy text summary';

  @override
  String get ringkasanCuacaDisalin => 'Weather summary copied';

  @override
  String get gempaSiagaJudul => 'Stay alert, stay calm';

  @override
  String get gempaSiagaKeterangan =>
      'Follow official information and prepare safe steps.';

  @override
  String get pengaturanIntro =>
      'Display, language, and notification choices are stored on this device.';

  @override
  String get peringatanIntro =>
      'Choose a magnitude threshold so the alerts you get stay relevant to you.';

  @override
  String get jejakAktivitas => 'Activity trail';

  @override
  String get cariWilayahGempa => 'Search earthquake region';

  @override
  String get hapusPencarian => 'Clear search';

  @override
  String get rentangGrafik => 'Chart range';

  @override
  String get grafikPerHari => 'Daily chart';

  @override
  String get grafikPerMinggu => 'Weekly chart';

  @override
  String get saringMagnitudo => 'Filter by magnitude';

  @override
  String minimalMagnitudo(String nilai) {
    return 'At least M$nilai';
  }

  @override
  String get gempaDalam100Km => 'Earthquakes within 100 km';

  @override
  String get gempaPerHari => 'Earthquakes per day';

  @override
  String get gempaPerMinggu => 'Earthquakes per week';

  @override
  String get grafikCatatan =>
      'Based on the history stored on this device. This is not the total of all BMKG events.';

  @override
  String mingguKe(String n) {
    return 'Week $n';
  }

  @override
  String jumlahKejadian(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String totalGrafik(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Total on chart: $n events',
      one: 'Total on chart: 1 event',
    );
    return '$_temp0';
  }

  @override
  String get siagaHeroJudul => 'Preparedness starts before an earthquake.';

  @override
  String get siagaHeroKeterangan =>
      'Learn the safe steps and complete your emergency bag bit by bit.';

  @override
  String get grafikSuhuJudul => 'Next 24 hours';

  @override
  String grafikSuhuSemantik(
    String sekarang,
    String tertinggi,
    String terendah,
  ) {
    return 'Temperature for the next 24 hours: now $sekarang degrees, high $tertinggi, low $terendah';
  }

  @override
  String sapaPagi(String lokasi) {
    return 'Good morning, $lokasi';
  }

  @override
  String sapaSiang(String lokasi) {
    return 'Good afternoon, $lokasi';
  }

  @override
  String sapaSore(String lokasi) {
    return 'Good evening, $lokasi';
  }

  @override
  String sapaMalam(String lokasi) {
    return 'Good night, $lokasi';
  }

  @override
  String get riwayatNotifJudul => 'Notification history';

  @override
  String get riwayatNotifKeterangan => 'Earthquakes that notified this device.';

  @override
  String get riwayatNotifKosong =>
      'No earthquake notifications received yet. Pick a magnitude threshold in Alerts to receive them.';

  @override
  String diterimaWaktu(String waktu) {
    return 'Received $waktu';
  }

  @override
  String get hapusRiwayat => 'Clear history';

  @override
  String get hapusRiwayatKonfirmasi =>
      'Delete all notification history on this device? This cannot be undone.';

  @override
  String get aksiBatal => 'Cancel';

  @override
  String get aksiHapus => 'Delete';

  @override
  String get urutanBerandaJudul => 'Home order';

  @override
  String get urutanBerandaKeterangan =>
      'Drag or use the arrow buttons to change the order of the Home sections.';

  @override
  String get urutanBerandaRingkas => 'Arrange Weather, Earthquakes, and Alerts';

  @override
  String get setelUlangUrutan => 'Reset order';

  @override
  String naikkanBagian(String nama) {
    return 'Move $nama up';
  }

  @override
  String turunkanBagian(String nama) {
    return 'Move $nama down';
  }

  @override
  String get riwayatBiasLabel => 'From data stored on this device';

  @override
  String riwayatRentangData(String mulai, String akhir) {
    return 'Stored data: $mulai – $akhir';
  }

  @override
  String get riwayatBiasCatatan =>
      'BMKG only provides a short list of recent earthquakes, so this history only holds earthquakes this device has loaded or received. The numbers are not complete statistics of earthquakes in Indonesia.';

  @override
  String riwayatDariTotal(String n, String total) {
    return '$n of $total stored records';
  }

  @override
  String get statJumlahGempa => 'Earthquakes';

  @override
  String get statLokasiTidakAda => 'Location unavailable';

  @override
  String get statLabelBias => 'Statistics from data stored on this device';

  @override
  String get riwayatGagalMuat =>
      'The earthquake history could not be read from device storage. Try again.';

  @override
  String get riwayatKosongCatatan =>
      'History fills automatically when BMKG earthquake data is loaded or an earthquake notification is received.';

  @override
  String get filterJudul => 'Filter history';

  @override
  String get filterTanggal => 'Date range';

  @override
  String get filterSemuaTanggal => 'All dates';

  @override
  String filterHariTerakhir(String n) {
    return 'Last $n days';
  }

  @override
  String get filterPilihTanggal => 'Pick dates';

  @override
  String get filterPilihTanggalBantuan => 'Pick the date range of the events';

  @override
  String get filterMagnitudo => 'Minimum magnitude';

  @override
  String get filterJarak => 'Maximum distance from you';

  @override
  String get filterSemuaJarak => 'Any distance';

  @override
  String filterJarakKm(String km) {
    return '$km km';
  }

  @override
  String get filterJarakNonaktif =>
      'The distance filter is unavailable because your location is not known. Turn on location to use it.';

  @override
  String get filterTerapkan => 'Apply';

  @override
  String get filterSetelUlang => 'Reset';

  @override
  String filterAktifJumlah(String n) {
    return 'Active filters: $n';
  }
}
